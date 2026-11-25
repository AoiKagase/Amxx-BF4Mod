# BattleField 4 Mod
This is an attempt to recreate the BF4 game system in CS1.6.

## Class System
* Choose from four classes: Assault/Support/Recon/Engineer.
* Each can have different weapons. In addition, there is equipment that is exclusive to each class.

## [W.I.P] Weapon System
* Select the weapon to be used when joining.

- ASSAULT CLASS
  - PRIMARY: 
    - Assault Rifle / Sub Machine Gun / Shot Gun
  - SECONDARY: 
    - HandGun
  - SPECIAL: 
    - Defibrillator (Menu is hidden because it is standard equipment.)

- SUPPORT CLASS
  - PRIMARY: 
    - Sub Machine Gun / Light Machine Gun
  - SECONDARY: 
    - HandGun
  - SPECIAL: 
    - Ammobox (Menu is hidden because it is standard equipment.)
    - Claymore

- RECON CLASS
  - PRIMARY: 
    - Sniper RIfle / DMR
  - SECONDARY: 
    - HandGun
  - SPECIAL: 
    - M32 MGL (TODO)

- ENGINEER CLASS
  - PRIMARY: 
    - Sub Machine Gun / Shot Gun
  - SECONDARY: 
    - HandGun
  - SPECIAL: 
    - GusBurner (Menu is hidden because it is standard equipment.)
    - (CT)LAWS / (T) RPG-7
    - Claymore

## Capture Area System

* Independent Domination and Conquest rules: capture/neutralize points, ticket bleed, safe redeployment and rank events.
* Configure the mode and real per-map layouts before enabling. CS Flags and the old Conquest prototype must remain disabled.
* Offline verification does not establish live-server gameplay. See [モード設定・導入・受入](docs/OBJECTIVE_MODES.md).
## Rank System
* XP, ranks, ribbons and medals are managed by the standalone BF4 progression plugin.
* ReAPI and CSWM remain required; OciXCrom's Rank System is a legacy migration source, not a runtime dependency.
* Preserve `RankSystem.ini` rank thresholds and reward values when migrating. Disable the old XP plugin before enabling the new writer.
* Missing award sprites fall back to text/audio. Weapon and map assets must still be installed on the server.

## 開発・移行

* [固定環境でのビルド・テスト](docs/BUILD.md)
* [旧XP・実績データの移行](docs/MIGRATION.md)
* [再設計と検証記録](docs/REDESIGN.md)
* [検証結果と未実施の受入](docs/VERIFICATION.md)

```powershell
rtk proxy python tools/prepare_dependencies.py
rtk proxy python tools/build_plugins.py
```

本番サーバーへの配置・停止・データ切替は自動実行しません。まず検証環境で移行前後の値とゲーム内動作を確認してください。

# Credits
AlliedModder Discord Members.
* DarkDeviL
* DarthMan
* gabuch2
* Goodbay
* LeviN
* LKING1543
* N.O.V.A
* Th3-822
* thEsp
* Windows user
* wOOw
* Zeky
