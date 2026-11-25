# Repository Guidelines

## プロジェクト構成

CS 1.6上でBattlefield 4の兵科・武器・ランクシステムを再現する、Pawn製のAMX Mod Xプラグイン群です。

- `cstrike/addons/amxmodx/scripting/`：`.sma`ソース。`bf4_ranksystem.sma`がランク関連、`bf4_system_*`が共通システム、`bf4_weapon_*`が個別武器を担当します。
- `bf4_game_objectives.sma`が独自ドミネーション／コンクエストを提供します。設定とマップ配置は`configs/bf4/`、導入は`docs/OBJECTIVE_MODES.md`を参照し、旧CS Flags・Conquest試作とは同時ロードしません。
- `scripting/include/`：共有定数・native宣言と依存ライブラリの`.inc`。上記AMX Mod Xディレクトリを基準とします。
- `cstrike/addons/amxmodx/configs/RankSystem.ini`：ランク、XP保存方法、SQL接続などの設定です。
- `cstrike/models/`、`cstrike/sound/`、`cstrike/sprites/`：ゲーム内アセット。ソース内の参照パスと大文字・小文字を一致させてください。

## ビルド・開発コマンド

コンパイラは同梱していません。検証環境はカスタムAMX Mod X 1.10.3-A.K・ReAPI 5.29・CSWMです。`tools/dependencies.lock.json`と`docs/BUILD.md`に固定版・ハッシュ・環境指定方法を記載しています。OciXCromは旧データ移行の参照元で、実行時には不要です。同梱の`.inc`だけで依存モジュールが導入されるわけではありません。

PowerShellでリポジトリ直下から実行する例です。

```powershell
rtk proxy python tools/prepare_dependencies.py
rtk proxy python tools/build_plugins.py
```

`--only bf4_ranksystem`で個別にコンパイルします。生成物と検証レポートは`build/plugins/`です。検証用サーバーに配置し、依存順序とプラグイン登録を確認してください。

## コーディング規約

既存Pawnコードに合わせ、タブでインデントし、波括弧は独立行、文末はセミコロンとします。定数は`FIRE1_DAMAGE`のような大文字とアンダースコアを使います。ファイル名は`bf4_weapon_<武器名>.sma`または`bf4_system_<機能名>.sma`に従い、共有宣言は対応する`.inc`へ置きます。周辺の命名・整列を尊重し、無関係な再整形を避けてください。専用フォーマッタ・リンターの設定はありません。

## テスト・動作確認

Pythonテストは`tests/test_*.py`、Pawn VMテストは`tests/*.sma`です。`rtk proxy python -m unittest discover -s tests -v`と`tools/run_pawn_test.py`で実行します。VMホストの準備は`docs/BUILD.md`を参照してください。固定カバレッジ基準はありません。共有`.inc`の変更時は利用側も再コンパイルします。

検証用CS 1.6サーバーでロードとアセットの読み込みを確認し、変更に応じて武器の選択・射撃・リロード、兵科切替、XP・ランク更新と再接続後の保存を試します。サーバーとAMX Mod Xのログを確認し、報告ではコンパイル結果、ゲーム内確認結果、未確認項目を分けてください。

## コミット・PR・設定管理

履歴には`Fixed: ...`、`Added: ...`、`Remove Logic`のような短い英語の件名があります。厳密な強制形式ではありませんが、変更対象と意図が分かる件名にし、無関係な変更を混ぜないでください。PRには目的、対象機能、検証結果、必要な設定・アセット・依存関係の変更を記載し、関連Issueがあればリンクします。見た目を変更した場合は画像を添えてください。SQL認証情報はコミットせず、ローカル設定で管理します。

エージェントはシェルコマンドを`rtk`経由で実行してください。既存の未コミット変更を保持し、依頼外のファイルを変更・リセットしないでください。委任時は開始、主要工程、30秒を超える処理の前、完了、問題発生時に親へ報告し、長時間処理中も30秒以内ごとに状況を伝えてください。
