# BF4 Objective Modes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** CS Flagsを必要としないBF4拠点モード2種を実装する。

**Architecture:** 純粋な状態遷移・設定解析とGoldSrc接続を分離する。ランク通知は独自イベントへ移行する。

**Tech Stack:** Pawn、AMX Mod X 1.10.3-A.K、ReAPI 5.29、既存AMX VMテスト。

**Spec:** `docs/superpowers/specs/2026-10-23-objective-modes-design.md`

## Global Constraints

旧CS Flags・Conquest試作と既存変更を保持する。SQLや保存形式を変えない。本番配置・コミットは行わない。BF4公式初期値と未確認の調整値を区別する。

## Review Focus

占領・勝利の二重通知、蘇生と再出撃の区別、切断スロットの再利用、無人・停止中の時間経過、不正配置・地形内スポーンを確認する。

## Task 1: 純粋ルールと配置解析

- [x] `tests/objective_rules.sma`で未実装includeによる失敗を確認。
- [x] `include/bf4/objective_rules.inc`に占領・減少・勝者・債務判定を実装。
- [x] `include/bf4/objective_config.inc`と配置解析テストを追加。
- [x] Pawn VMで境界値とモード差を確認。

## Task 2: エンジン接続

- [x] `bf4_game_objectives.sma`と`bf4objectives.inc`を追加。定期処理、チケット、HUD、配置、復活、安全検査、標準勝敗抑止、管理コマンドを実装。
- [x] 本番関数のオフラインテストで死亡・蘇生・再出撃・切断とイベント回数を検証。
- [x] 個別ビルドを成功させる。

## Task 3: ランク・導入・検証

- [x] ランク受信を独自イベントへ置き換え、例示ロード順から旧CS Flagsを外す。
- [x] 設定例・配置書式・操作とサーバー受入試験を`docs/OBJECTIVE_MODES.md`へ記載。
- [x] 全ビルド、全テスト、差分検査、ソース一覧更新を実施し、残る実機確認を記録。

## 実行記録

承認済みの構成をこのチャットで直接実装する。チケット値など未確認の公式定数は調整可能な初期値と明記する。既存未コミット変更を引き継ぐため同じチェックアウトを使用する。

実行完了：49/49ビルド（警告0）、Python16件、Pawn5fixtureの115項目成功。独立レビューのC4再開指摘を修正し再確認済み。停止中の切断終端、敵侵入中の復活禁止、遅延蘇生の二重復活を回帰で確認。実サーバー受入・配置作成・本番切替は未実施。最終レポートは build/objective-verified/report.json。
