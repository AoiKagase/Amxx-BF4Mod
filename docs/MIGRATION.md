# 進行データの安全な移行

## 1. 対応形式と出典

`tools/migrate_progression.py` は Python 3 標準ライブラリだけで、停止済みサーバーのバックアップを読み取ります。DBへ接続せず、既存テーブル・vault・設定を書き換えません。実サーバーのデータは未提供のため、実データ一致・本番取り込みは未検証です。

- OciXCrom RankSystem **3.10**：公式 [固定コミット](https://github.com/OciXCrom/RankSystem/blob/70f9f37c1073d8b367cc014c65483b83baebec50/addons/amxmodx/scripting/crx_ranksystem.sma)、`save_or_load()`。SQLは `Player,XP`、nVaultは保存キー→10進数XP。別バージョンや改変版はこの形式との一致を先に確認してください。
- BF4旧形式：`bf4_ranksystem.sma` の `initialize_user_data_sql()` / `initialize_user_data_nvault()` / `client_disconnected()`。SQLは `authid,type,rank_id,value`、nVaultキーは `<authid>_<type>_<rank_id>`、値は10進整数です。
- nVault：AMX Mod X `modules/nvault/NVault.h`、`NVault.cpp`、`Binary.cpp` の0x0200形式。x86 little-endianの magic `0x6E564C54`、version(uint16)、件数(int32)、各レコードの時刻(int32)・キー長(uint8)・値長(uint16)・文字列を検証します。ジャーナルの再生はしません。

旧BF4のtype=0はイベント累計19種、type=1は獲得リボン累計19種です。type=1を「メダル獲得回数」に換算してはいけません。旧ローダーの6桁制限を使わず、32bit符号付き整数の上限まで数値を保持します。

## 2. バックアップと読取専用検証

書込停止・本番停止は管理者の承認後に行い、旧プラグイン・設定・DB・vaultとjournalを同じ時点でバックアップします。nVaultは正常終了後にコピーし、空でない `.journal` が残っている場合は旧環境で正常終了させてコピーし直します。破損、末尾の余剰データ、未知versionは拒否されます。

SQLは読取専用で次の列だけをJSON配列としてエクスポートしてください。DB接続情報や任意SQLダンプはこのツールに渡せません。

```sql
SELECT Player, XP FROM <旧Ociテーブル>;
SELECT authid, type, rank_id, value FROM BF4Ranks;
```

```json
[{"Player":"STEAM_0:1:7","XP":12345}]
```

```json
[{"authid":"STEAM_0:1:7","type":0,"rank_id":18,"value":1234567}]
```

```powershell
rtk proxy python tools/migrate_progression.py --xp backup/xp.json --counters backup/counts.json --save-key steamid
rtk proxy python tools/migrate_progression.py --xp backup/CRXRanks.vault --xp-format oci310-nvault --counters backup/BF4Ranks.vault --counter-format bf4-nvault --save-key steamid
```

既定では検証報告だけを標準出力へ出します。プレイヤー数、XP総和、カウンタ総和、カウンタ未保存人数、入力SHA-256、出力予定SHA-256を確認します。カウンタがあるのにXPが無いプレイヤー、重複、負数、小数、未知type/rank_id、上限超過をエラーにします。XPだけあるプレイヤーの未保存カウンタは、旧ローダーと同じ0として報告に数えます。

Oci `SAVE_TYPE=0/1/2` は `--save-key nickname/ip/steamid` に対応します。BF4は常にSteamIDを使うため、nickname/IPでは `--identity-map backup/identities.json` を必須とします。マップは `{"STEAM_0:1:7":"元の名前"}` のようにBF4 authid→元のOci保存キーです。履歴で確認できない対応は推測しません。複数authidを同一キーに集約するマップと、大文字小文字だけが違う保存キーは拒否します。

nVaultの文字コードは既定UTF-8です。旧サーバーで使用したコードページが分かる場合だけ `--encoding cp932` などを指定します。不正文字を置換して続行することはありません。

## 3. 新ストア用の成果物

検証に成功した同一入力に `--output staging/progression-v2.tsv` を追加すると、新規ファイルだけを作成します。親ディレクトリを先に用意してください。既存出力が完全一致する場合は再実行可能ですが、違う内容の上書き・入力ファイルの上書きは拒否します。

TSVはヘッダーなし、UTF-8、LF、キーの昇順です。行形式は `player_key<TAB>xp<TAB>38個のカンマ区切り整数`、キーは `steam:` / `nick:` / `ip:` の接頭辞付きです。カウンタ順は type0/rank0..18、type1/rank0..18 です。接頭辞込み63 UTF-8バイトを超えるキーと制御文字を拒否します。

これは新ランク側の管理者用インポートに渡す中間形式です。旧vaultへ書き戻したり、Ociと新ランクを同時に書込動作させたりしないでください。新SQLストア `bf4_progression_v2`、新nVault `BF4Ranks_v2` への取り込み可否・空ストア条件・再実行時の扱いは新ランク側で検査します。既存プレイヤーへ加算して二重付与する運用は禁止です。

取り込みは検証用サーバーで先に実施します。旧Ociプラグインを無効にし、設定した新ストアが準備完了してから、TSVを `addons/amxmodx/data/progression-v2.tsv` に配置してください。プレイヤーが0人の状態で、サーバーコンソールから次を実行します。

```text
bf4_import_progression progression-v2.tsv
```

コマンドはサーバーコンソール専用です。全行の形式・重複・既存値との競合を事前検査し、旧保存先へは書き込みません。同一内容の既存行は維持し、異なる既存値には上書きしません。SQL書き込み途中に障害が起きた場合、一部の新規行が既に取り込まれている可能性があります。同一ファイルを再実行して完了させ、取り込み結果を照合してください。

`BOT`、`STEAM_ID_PENDING`、対応未確認の`VALVE_*`などの識別子は推測で移行しません。旧環境で共有されていた曖昧な保存キーは、実データに基づく対応確認が必要です。

## 4. 検証と切替

`rtk proxy python -m unittest discover -s tests -p test_migrate_progression.py` で、SQLエクスポート、既知バイナリfixture、7桁超カウンタ、欠損XP、衝突、不正値、ジャーナル、再出力を検証します。

検証環境で旧新のキーごとのXP・38カウンタを照合し、再接続保存も確認してください。本番切替は最終バックアップ・再移行・照合の後に別途承認を受けます。旧設定・旧データを復帰用に保持し、新ストアから旧ストアへの逆変換は行いません。
