# ビルドと検証

## 固定した検証環境

AMX Mod X **1.10.3-A.K**のカスタムビルドを使用します。標準版とAPIが異なり、標準版へ差し替えただけでの互換性は保証しません。コンパイラ、ソースのコミット、CSWM同梱include、公式参照ソースのハッシュは `tools/dependencies.lock.json` を参照してください。

ReAPIヘッダーは **5.29**。実行には対応するReHLDS／ReGameDLL_CS／ReAPI、CSWM、customentdata、AMX Mod X標準モジュールが必要です。ランク保存はSQLXまたはnVaultです。実サーバーのモジュール版・プラグイン順序・マップ設定はまだ採取していません。

## コンパイル

リポジトリ直下で実行します。Python 3.12と、隣接するカスタムAMX Mod Xチェックアウトを既定にしています。別の場所では `--compiler` / `--amxx-include` を指定してください。

```powershell
rtk proxy python tools/prepare_dependencies.py
rtk proxy python tools/build_plugins.py
```

ネットワークを使わず、取得済みアーカイブのハッシュ検証と展開だけを行う場合は `prepare_dependencies.py --offline` を使います。出力・個別ログ・ソースSHA-256付きレポートは `build/plugins/` です。コンパイル失敗時に古い生成物を成功扱いしません。`--only bf4_ranksystem` で対象を絞れます。

## オフラインテスト

```powershell
rtk proxy cmd.exe /c tools\build_pawn_runner.cmd
rtk proxy python -m unittest discover -s tests -v
rtk proxy python tools/run_pawn_test.py tests/progression_snapshot.sma
rtk proxy python tools/run_pawn_test.py tests/session_tasks.sma
rtk proxy python tools/test_all.py
```

Pawn VMホストのビルドにはVisual Studio C++ x86ツールと、隣接するAMX Mod Xの `compiler/amxxpc` ソースを使用します。インストール位置が異なる場合は `build_pawn_runner.cmd` を環境に合わせてください。ホストはチェック関数と明示した算術nativeだけを提供し、未登録nativeで失敗します。GoldSrcの代替サーバーではありません。

地雷テストは本体の判定関数を取り出し、エンジン境界を計数用mockにして実際のPawn bytecodeを実行します。トレース回数・ハンドル寿命の回帰を確認しますが、敵の検知・遮蔽・ゲームの快適性は実機確認が必要です。

## ゲーム内受入

独自ドミネーション／コンクエストの設定・配置・専用受入項目は [OBJECTIVE_MODES.md](OBJECTIVE_MODES.md) を参照してください。旧 `csflags.amxx` とConquest試作を同時ロードせず、`bf4_game_objectives.amxx` を使います。初期設定は `off` です。

1. 同じマップ・設定で旧新を比較し、全武器の登録・装備と兵科制限を確認する。
2. キャンセル、死亡、再接続、同一スロット再利用、蘇生・補給・旗イベントを確認する。
3. XPと38カウンタを旧データと照合し、表示待ち切断でも報酬が失われないことを確認する。
4. DB遅延・切断・復旧、保存中の更新、再起動時の未保存復旧を確認する。
5. 同じ人数・地雷数でフレーム時間とトレース回数を比較する。未測定のFPS改善率を報告しない。

本番切替とサーバー停止は別途承認後に行います。データ移行は `docs/MIGRATION.md` を参照してください。

未完成の `bf4_game_conquest.sma` はコンパイル検証に含めますが、既定の導入対象には含めません。参照する `sprites/bf4_ranks/conquest/{ring,point,guage}.spr` はリポジトリにありません。既存の未追跡ソースは保持しています。
