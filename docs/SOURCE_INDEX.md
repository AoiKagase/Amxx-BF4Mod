# ソース分類・一覧

2026-10-23の現行ファイルを確認。計89本：ゲームプラグイン49本、include 25本、開発ツール6本、テスト9本。

ゲーム側の基点は `cstrike/addons/amxmodx/scripting/` です。表のファイル名から各ソースを開けます。

## 1. ゲーム基盤・ゲームルール（8本）

| ファイル | 役割 |
|---|---|
| [bf4_ranksystem.sma](../cstrike/addons/amxmodx/scripting/bf4_ranksystem.sma) | 独立ランク管理の入口。報酬イベントと内部モジュールを接続。 |
| [bf4_game_objectives.sma](../cstrike/addons/amxmodx/scripting/bf4_game_objectives.sma) | 独自ドミネーション／コンクエスト。拠点・チケット・復活・勝敗を管理。旧CS Flags・Conquest試作とは同時ロードしない。 |
| [bf4_system_class.sma](../cstrike/addons/amxmodx/scripting/bf4_system_class.sma) | 兵科・チーム選択、装備予約とメニューの状態管理。 |
| [bf4_system_weapons.sma](../cstrike/addons/amxmodx/scripting/bf4_system_weapons.sma) | 武器定義の登録、装備制限、選択メニュー、ダメージ通知。 |
| [bf4_system_effects.sma](../cstrike/addons/amxmodx/scripting/bf4_system_effects.sma) | 爆発・範囲ダメージ・画面振動などの共通演出API。 |
| [bf4_system_precache.sma](../cstrike/addons/amxmodx/scripting/bf4_system_precache.sma) | モデル・音声のprecacheフックとリソース登録管理。 |
| [csflags.sma](../cstrike/addons/amxmodx/scripting/csflags.sma) | **外部製作：commonbulletのCS Flags。独自実装への置換対象。** BF4のドミネーション／コンクエストを実現する目的で利用。現行コードは固定拠点の占領・得点・勝敗を管理。 |
| [bf4_game_conquest.sma](../cstrike/addons/amxmodx/scripting/bf4_game_conquest.sma) | Conquestの試作。コンパイル対象だが完成機能として扱わない。 |

## 2. 武器・装備（41本）

ソース内の `BF4_WEAPONCLASS_*` 登録値による分類です。実銃の一般的な分類と異なる場合があります。地雷・蘇生器・ランチャーなどは固有処理を持ちます。

| 登録分類 | 本数 | ソース |
|---|---:|---|
| アサルト系 | 11 | [bf4_weapon_akm.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_akm.sma)、[bf4_weapon_an94.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_an94.sma)、[bf4_weapon_fnc.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_fnc.sma)、[bf4_weapon_g11.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_g11.sma)、[bf4_weapon_hk416.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_hk416.sma)、[bf4_weapon_l85a2.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_l85a2.sma)、[bf4_weapon_m14ebr.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m14ebr.sma)、[bf4_weapon_m16a1.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m16a1.sma)、[bf4_weapon_qbz95b.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_qbz95b.sma)、[bf4_weapon_scar.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_scar.sma)、[bf4_weapon_xm8.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_xm8.sma) |
| サブマシンガン | 3 | [bf4_weapon_kriss.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_kriss.sma)、[bf4_weapon_mp7a1.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_mp7a1.sma)、[bf4_weapon_uzi.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_uzi.sma) |
| 軽機関銃 | 6 | [bf4_weapon_hk121.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_hk121.sma)、[bf4_weapon_hk23.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_hk23.sma)、[bf4_weapon_m60.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m60.sma)、[bf4_weapon_mg3.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_mg3.sma)、[bf4_weapon_mk48.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_mk48.sma)、[bf4_weapon_pkm.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_pkm.sma) |
| スナイパーライフル | 4 | [bf4_weapon_cheytac_m200.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_cheytac_m200.sma)、[bf4_weapon_m95.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m95.sma)、[bf4_weapon_pgm.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_pgm.sma)、[bf4_weapon_r93.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_r93.sma) |
| DMR | 4 | [bf4_weapon_psg1.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_psg1.sma)、[bf4_weapon_sl8.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_sl8.sma)、[bf4_weapon_svd.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_svd.sma)、[bf4_weapon_wa2000.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_wa2000.sma) |
| ショットガン | 3 | [bf4_weapon_spas12.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_spas12.sma)、[bf4_weapon_usas12.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_usas12.sma)、[bf4_weapon_uts15.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_uts15.sma) |
| 拳銃 | 4 | [bf4_weapon_automag5.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_automag5.sma)、[bf4_weapon_fnp45.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_fnp45.sma)、[bf4_weapon_m1911a1.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m1911a1.sma)、[bf4_weapon_python.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_python.sma) |
| 支援装備（登録区分：MELEE） | 2 | [bf4_weapon_briefcase.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_briefcase.sma)、[bf4_weapon_defibrillator.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_defibrillator.sma) |
| 設置・投射装備 | 4 | [bf4_weapon_claymore.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_claymore.sma)、[bf4_weapon_laws.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_laws.sma)、[bf4_weapon_m32mgl.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_m32mgl.sma)、[bf4_weapon_rpg7.sma](../cstrike/addons/amxmodx/scripting/bf4_weapon_rpg7.sma) |

## 3. 共有宣言・内部モジュール（25本）

| ファイル | 役割 |
|---|---|
| [bf4const.inc](../cstrike/addons/amxmodx/scripting/include/bf4const.inc) | BF4共通定数・列挙型。 |
| [bf4objectives.inc](../cstrike/addons/amxmodx/scripting/include/bf4objectives.inc) | 独自拠点モードの公開API・占領／試合終了イベント。 |
| [objective_rules.inc](../cstrike/addons/amxmodx/scripting/include/bf4/objective_rules.inc) | 占領・中立化・過半数減少・チケット・復活条件の純粋ルール。 |
| [objective_config.inc](../cstrike/addons/amxmodx/scripting/include/bf4/objective_config.inc) | マップ配置行・ID・数値の厳格解析。 |
| [bf4classes.inc](../cstrike/addons/amxmodx/scripting/include/bf4classes.inc) | 兵科・チームの公開API。 |
| [bf4weapons.inc](../cstrike/addons/amxmodx/scripting/include/bf4weapons.inc) | 武器登録・装備の公開API。 |
| [bf4progression.inc](../cstrike/addons/amxmodx/scripting/include/bf4progression.inc) | XP・ランク・実績の公開API。 |
| [bf4effects.inc](../cstrike/addons/amxmodx/scripting/include/bf4effects.inc) | 共通演出のnative宣言。 |
| [bf4natives.inc](../cstrike/addons/amxmodx/scripting/include/bf4natives.inc) | 旗・蘇生・リボンなどの既存連携native宣言。 |
| [core_rules.inc](../cstrike/addons/amxmodx/scripting/include/bf4/core_rules.inc) | スロット・メニュー・兵科・武器定義の境界検証。 |
| [session_tasks.inc](../cstrike/addons/amxmodx/scripting/include/bf4/session_tasks.inc) | 接続世代を使う遅延タスクの検証。 |
| [progression_config.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_config.inc) | ランク設定と閾値の読み込み。 |
| [progression_core.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_core.inc) | XP・実績の更新とイベント処理。 |
| [progression_math.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_math.inc) | XPからレベルを算出する計算。 |
| [progression_hud.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_hud.inc) | 報酬表示キュー、HUD・音声通知。 |
| [progression_snapshot.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_snapshot.inc) | 保存レコード、厳格な値解析、保存完了判定。 |
| [progression_storage.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_storage.inc) | SQL／nVault保存、読み込み、再試行・journal。 |
| [progression_import.inc](../cstrike/addons/amxmodx/scripting/include/bf4/progression_import.inc) | 移行TSVの検証・取り込み。 |
| [cswm.inc](../cstrike/addons/amxmodx/scripting/include/cswm.inc) | CSWMの外部API宣言。 |
| [cswm_const.inc](../cstrike/addons/amxmodx/scripting/include/cswm_const.inc) | CSWMの定数・列挙型。 |
| [customentdata.inc](../cstrike/addons/amxmodx/scripting/include/customentdata.inc) | 外部エンティティデータ機能の宣言。 |
| [csflags.inc](../cstrike/addons/amxmodx/scripting/include/csflags.inc) | 外部CS Flagsとの連携宣言。占領・ラウンド勝利・試合勝利の3イベント。独自版で互換性を判断。 |
| [beams.inc](../cstrike/addons/amxmodx/scripting/include/beams.inc) | ビームエンティティ操作のヘルパー。 |
| [crxranks.inc](../cstrike/addons/amxmodx/scripting/include/crxranks.inc) | 旧OciXCromのAPI宣言。独立ランクの実行時依存ではない。 |
| [crxranks_const.inc](../cstrike/addons/amxmodx/scripting/include/crxranks_const.inc) | 旧OciXCromの定数。旧実装・移行の参照用。 |

## 4. 開発ツール・テスト（15本）

| ファイル | 役割 |
|---|---|
| [prepare_dependencies.py](../tools/prepare_dependencies.py) | 固定ハッシュの依存ヘッダーを準備。 |
| [build_plugins.py](../tools/build_plugins.py) | 全プラグインをコンパイルし、結果・ハッシュを記録。 |
| [migrate_progression.py](../tools/migrate_progression.py) | 旧データを読み取り検証し、新保存先向けTSVを出力。 |
| [run_pawn_test.py](../tools/run_pawn_test.py) | Pawnテストをコンパイルし、VMホストで実行。 |
| [pawn_test_runner.cpp](../tools/pawn_test_runner.cpp) | オフラインAMX VMのテストホスト。ゲームサーバーとは別。 |
| [test_all.py](../tools/test_all.py) | Python回帰テストとPawnテストをまとめて実行。 |
| [objective_rules.sma](../tests/objective_rules.sma) | 拠点状態遷移、チケット、モード別復活条件を検証。 |
| [objective_config.sma](../tests/objective_config.sma) | 配置書式、不正値、余分な項目とIDを検証。 |
| [test_objective_runtime.py](../tests/test_objective_runtime.py) | 本番の死亡・蘇生・再出撃・切断とランク通知をVMで検証。 |
| [core_rules.sma](../tests/core_rules.sma) | 兵科・武器・メニューなどの境界検証。 |
| [progression_snapshot.sma](../tests/progression_snapshot.sma) | 保存形式・XP計算・TSV解析と更新確認の検証。 |
| [session_tasks.sma](../tests/session_tasks.sma) | 接続世代と遅延タスクの検証。 |
| [test_migrate_progression.py](../tests/test_migrate_progression.py) | 旧データ形式・衝突・不正値・移行出力の回帰テスト。 |
| [test_migration_pawn.py](../tests/test_migration_pawn.py) | 移行CLIの出力を本番Pawn解析へ渡す工程間テスト。 |
| [test_claymore_runtime.py](../tests/test_claymore_runtime.py) | 地雷の本番判定関数をmock接続し、トレース・ハンドル操作を計数。 |

## 5. 読む順序と対象範囲

ランク変更は `bf4_ranksystem.sma` → `progression_core.inc` → `progression_storage.inc`、装備変更は `bf4_system_class.sma` → `bf4_system_weapons.sma` → 対象の武器ソースを追います。公開APIは対応する `bf4*.inc` を先に確認してください。

モデル・音声・スプライト、設定、ドキュメント、`build/` 内の取得依存・生成物・一時スクリプトはソース集計から除外しています。外部ReAPI・AMX Mod X本体のソースも対象外です。ファイルの移動・名称変更は行っていません。
