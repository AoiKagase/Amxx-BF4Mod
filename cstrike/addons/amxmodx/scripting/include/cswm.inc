/* CSWM Incude File */

#if defined CSWM
	#endinput
#endif
#define CSWM

#if !defined BIT
	#define BIT(%1) (1 << %1)
#endif

#include <cswm_const>

/*
 * Model - Model of the weapon.
 *** Used to retrieve weapon or create it's own model paths (If not exists).
 * Type - Type of the weapon.
 *** Used to specify weapon type. See WType enum in cswm_const.inc
 *** 0=Pistol or P228
 *** 1=Shotgun or XM1014
 *** 2=Rifle or AK47
 *** 3=Sniper or AWP
 * Name - Name of the weapon.
 *** No use, can be retrieved through plugins. Useful for menus.
 ### Returns weapon index.
*/
native CreateWeapon(Model[], any:Type, Name[]);

/*
 * Cost - Cost of the ammo in $.
 *** Used when buying through buyammo1/buyammo2.
 * Amount - Count of ammuniton.
 *** Count of ammo which will be given to player after buying.
 * Max - Max of ammunition.
 *** Player can't buy more than this count of ammo.
 ### Returns ammo index.
*/
native CreateAmmo(Cost, Amount, Max);

/*
 * Weapon - Index of the weapon.
 *** Following models can be precached through custom paths.
 * VModel - View model of the weapon.
 *** View model is weapon model which is shown when holding it.
 * PModel - Player view weapon model of the weapon.
 *** Player view weapon model is type of weapon model which is shown when other player is holding it.
 * WModel - World model of the weapon.
 *** World model of the weapon is shown when weapon is dropped.
*/
native BuildWeaponModels(Weapon, VModel[], PModel[], WModel[]);

/*
 * Weapon - Index of the weapon.
 * Sound - Fire/Shoot sound.
 *** Fire sound should be in path: 'cstrike/sound/'
 *** Example: Path of the fire sound 'weapons/ak47-1.wav' is 'cstrike/sound/weapons/ak47-1.wav'
*/
native BuildWeaponFireSound(Weapon, Sound[]);

/*
 * Weapon - Index of the weapon.
 * WeaponList - Name of weaponlist.
 *** Weaponlist is pack of information that is used to show weapon on hud.
 *** Weaponlist file should be in following path: 'cstrike/sprites/'.
 *** File type of the weaponlist is '.txt' which shoud not be added in name.
 *** Example: Path of the weaponlist 'weapon_ak47' is 'cstrike/sprites/weapon_ak47.txt'
 *** However weaponlist is path so you can put folder in name. (Example: 'cswm/weapon_ak47')
*/
native BuildWeaponList(Weapon, WeaponList[]);

/*
 * Weapon - Index of the weapon.
 * Clip - Weapon clip.
 *** Clip is count of ammo that can be drained from weapon before next reload.
 * AmmoID - Ammo index of the weapon.
 *** Ammo index (PrimaryAmmoType) is type of ammo that is used for current weapon.
 *** Ammo index is required to set which ammo type should be used from player's ammo list.
*/
native BuildWeaponAmmunition(Weapon, Clip, any:AmmoID);

/*
 * Weapon - Index of the weapon.
 * Animation - Animation index of the weapon.
 *** Use model viewer to detect current animation index.
 *** If you are not able to do this set animation to 0.
 *** Setting animation to 0 will result auto detecting it. (However this is not 100% accurate)
 * Duration - Duration time of animation.
 *** This is time after player is able to shoot from weapon.
 *** If you want exact time then set this to 0.0.
*/
native BuildWeaponDeploy(Weapon, Animation, Float:Duration);

/*
 * Weapon - Index of the weapon.
 * Delay - Delay of the weapon.
 *** Time after player is able to shoot again.
 *** If you want to get original time of specified weapon use 'GetWeaponDefaultDelay'
 * Damage - Damage multipier of the weapon.
 *** 1.0 Will not damage enemies by 1.0, it will multiply current weapons damage by 1.0
 *** Current weapon in this case is weapon which is one of default weapons.
 *** Current weapon depends on weapon type specified when creating weapon.
 * Recoil - Recoil multiplier of weapon.
 *** This is multiplier, same as 'Damage', but it is controlling spreading and accuracy.
 * Animation - Animation of shoot.
 *** Shoot animations can be infinite.
 *** If your weapon has shoot animations 3,4 and 5 then pass them as 3,4,5
 *** If you can not detect shoot animations then do not write anything.
 *** Nothing as parameter will result auto detecting shoot animations .(Not 100% Accurate)
*/
native BuildWeaponPrimaryAttack(Weapon, Float:Delay, Float:Damage, Float:Recoil, any:...);

/*
 * Weapon - Index of the weapon.
 * Animation - Animation of reload.
 *** Set to 0 to auto detect.
 * Duration - Time after shoot is allowed.
 *** Set to 0.0 to auto detect.
*/
native BuildWeaponReload(Weapon, Animation, Float:Duration);

/*
 * Weapon - Index of the weapon.
 * Duration - Duration of reload.
 *** Duration is single clip insert time.
 *** 0.55 should be default reload time.
 * Type - Type of reload.
 *** 0=M3 | Reload as M3
 *** 1=XM1014 | Reload as XM1014
 *** 2=Rifle | Reload as anything other, like Rifle.
*/
native BuildWeaponReloadShotgun(Weapon, Float:Duration, any:Type);

/*
 * Weapon - Index of the weapon.
 * Flags - Flag bitsum of weapon flags.
 *** Check WFlag enum in 'cswm_const.inc'
*/
native BuildWeaponFlags(Weapon, any:Flags);

/*
 * Weapon - Index of the weapon.
 * Type = Type of attack2.
 *** Check WAttack2 enum in 'cswm_const.inc'
 * Parameters - Settings of current attack2 type.
 *** Check 'cswm_const.inc' for more details.
*/
native BuildWeaponSecondaryAttack(Weapon, any:Type, any:...);

/*
 * Weapon - Index of the weapon.
 * MaxSpeed - Speed when holding weapon.
*/
native BuildWeaponMaxSpeed(Weapon, Float:MaxSpeed);

/*
 * Builds weapon primary attack specs without animation.
 *
 * Weapon - Index of the weapon.
 * Delay - Delay before next shoot.
 * Recoil - Accuracy, spread multiplier.
 * Damage - Damage multiplier.
*/
native BuildWeaponSpecs(Weapon, Float:Delay, Float:Recoil, Float:Damage);

/*
 * Checks weapon's animations and other parameters that are not valid.
 * Includes clip, ammo type, fire sound, speed, delay.
 *
 * Weapon - Index of the weapon.
*/
native CheckWeaponParams(Weapon);

/*
 * Weapon - Index of the weapon.
 * Forwad - Forward index.
 *** This is event which will be hooked.
 *** Check WForward enum in 'cswm_const.inc'
*/
native RegisterWeaponForward(Weapon, any:Forward, Callback[]);

/*
 * Precaches specified weapon's model's sounds.
 * Same as sv_auto_precache_sounds_in_models, but precache is done when function is called.
 *
 * Weapon - Index of the weapon.
*/
native PrecacheWeaponModelSounds(Weapon);

/*
 * Precaches specified weapon's own hud's sprites.
 *
 * Weapon - Index of the weapon.
*/
native PrecacheWeaponListSprites(Weapon);

/*
 * Model - Model of the weapon.
 *** Model is assigned when creating weapon. ('CreateWeapon' first parameter)
*/
native FindWeaponByModel(Name[]);

/*
 * Name - Name of the weapon.
 *** Name is assigned when creating weapon. ('CreateWeapon' third parameter)
*/
native FindWeaponByName(Name[]);

/*
 * PlayerID - Player index.
 *** Player which will get the weapon.
 * Name - Name of the weapon.
 *** Name is 3rd parameter in 'CreateWeapon'.
*/
native GiveWeaponByName(PlayerID, Name[]);

/*
 * PlayerID - Player index.
 *** Player which will get the weapon.
 * Weapon - Index of the weapon.
*/
native GiveWeaponByID(PlayerID, Weapon);

/*
 * Weapon - Index of the weapon.
 * Data - Weapon data.
 *** Check WData enum in 'cswm_const.inc'.
 *** If data is string then 3rd parameter is string and 4th is string length.
*/
native any:GetWeaponData(Weapon, any:Data, any:...);

/*
 * WeaponEnt - Weapon entity.
 *** Weapon entity is weapon holded by the player.
 * Animation - Animation which should be played.
*/
native SendWeaponAnim(WeaponEnt, Animation);

/*
 * Model - Model of the projectile.
 *** Projectile model will be precached.
 * Gravity - Projectile gravity (1.0=Normal).
 * Speed - Projectile speed (250.0=PlayerMaxSpeed).
 * Callback - Callback/Function which will be executed.
 *** Callback will be executed when projectile touches something.
 * Duration - Duration of projectile.
 *** This is 5th parameter of native which will set duration of projectile.
 *** If projectile is launched through 'ShootProjectileContact' then Duration is unused.
 ### Returns projectile index.
*/
native CreateProjectile(Model[], Float:Gravity, Float:Speed, Callback[], Float:Duration=0.0);

/*
 * Model - Model of effect.
 *** Effect model will be precached.
 * Speed - Speed of effect.
 * Callback - Callback/Function which will be executed.
 *** Callback will be executed when effect expires.
 * Duration - Duration before effect expires after firing.
 ### Returns effect index.
*/
native CreateEffect(Model[], Float:Speed, Callback[], Float:Duration);

/*
 * Removed after expire.
 *
 * Launcher - Launcher entity.
 *** Launcher should be player.
 * Projectile - Index of the projectile.
*/
native ShootProjectileTimed(Launcher, Projectile);

/*
 * Should be removed manually.
 *
 * Launcher - Launcher entity.
 *** Launcher should be player.
 * Projectile - Index of the projectile.
*/
native ShootProjectileContact(Launcher, Projectile);

/*
 * Removed after expire..
 *
 * Launcher - Launcher entity.
 *** Launcher should be player.
 * Effect - Index of the effect.
*/
native ShootEffect(Launcher, Effect);

/*
 * PlayerID - Player entity.
 * AmmoID - Index of ammo.
 * Amount - Amount of ammo should be given.
*/
native GiveAmmo(PlayerID, AmmoID, Amount);

/*
 * Ammo - Index of ammo.
 * Name - Name of ammo.
 *** Makes searchable.
*/
native SetAmmoName(Ammo, Name[]);

/*
 * Name - Ammo name should be searched.
 ### Returns ammo index.
*/
native FindAmmoByName(Name[]);

/*
 ### Returns count of created weapons.
*/
native GetWeaponCount();

/*
 * Weapon - Index of the weapon.
 * Output - Variable where will be stored the name.
 * Length - Length of variable.
 ### Returns true or 1 on success.
*/
native GetWeaponName(Weapon, Output[], Length);

/*
 * Weapon - Index of the weapon.
 * Output - Variable where will be stored the model.
 * Length - Length of variable.
 ### Returns true or 1 on success.
*/
native GetWeaponModel(Weapon, Output[], Length);

/*
 * Path - Path that will be addon while precaching weapon.
 *** This only works when user has not used 'BuildWeaponModels'.
 *** Precached weapon's path looks like:
 *** 'models/<Path Addon>/<Weapon Model>/<V, P or W>.mdl'
*/
native SetWeaponPathAddon(Path[]);

/*
 * Weapon - Index of the weapon.
 ### Returns weapon's flags bit sum.
*/
native GetWeaponFlags(Weapon);

/*
 * Origin - Origin of explosion.
 * Flags - Same as TE_EXPFLAG_* flags.
 *** Explosion also creates TE_WORLDDECAL and TE_SMOKE.
*/
native CreateExplosion(Float:Origin[3], Flags);

/*
 * Origin - Center of radius damage.
 * Radius - Damage radius.
 * Damage - Damage amount.
 * Inflictor - Inflictor entity.
 * Attacker - Attacker entity.
 * DamageBits - Damage bit sum.
 * Flags - Radius damage flags.
 *** See RDFlag enum in 'cswm_const.inc'
*/
native RadiusDamageEx(Float:Origin[3], Float:Radius, Float:Damage, Inflictor, Attacker, DamageBits, RDFlag:Flags);

/*
 * Origin - Center of cleave damage.
 * VAngles - Angles of damage.
 * FOV - Field of view of damage.
 *** Damage done from specified place and specified angle with specified range of view.
 * Accurate - If set will lower range.
 * Damage - Damage of cleave.
 * Radius - Radius of cleave (Maximum length from Origin).
 * Inflictor - Inflictor entity.
 * Attacker - Attacker entity.
 * DamageType - Damage bits sum.
*/
native CleaveDamage(Float:Origin[3], Float:VAngles[3], Float:FOV, bool:Accurate, Float:Damage, Float:Radius, Inflictor, Attacker, DamageType);

/*
 * PlayerID - Player entity.
 * Damage - Damage of cleave.
 * Radius - Radius of cleave (Maximum length from player).
 *** Accurate = FALSE
 *** DamageType = DMG_SLASH
*/
native CleaveDamageByPlayer(PlayerID, Float:Damage, Float:Radius);

/*
 * Entity - Weapon entity.
 *** Check if player can do primary attack through weapon.
 ### Returns true if player is able to shoot, otherwise false.
*/
native CanPrimaryAttack(Entity);

/*
 * Entity - Weapon entity.
 * Duration - Duration after player will be able to shoot again.
 * UpdateTimeWeaponIdle - Also update next idle animation time.
*/
native SetNextAttack(Entity, Float:Duration, bool:UpdateTimeWeaponIdle);

/*
 * Weapon - Index of the weapon.
 * Animation - Animation index.
 *
 * CustomIdleAnim Flag is set to this weapon after using this native.
*/
native SetWeaponIdleAnim(Weapon, Animation);

/*
 * Output - Output string variable.
 * Length - Output string length.
 ### Returns path addon Value.
*/
native GetWeaponPathAddon(Output[], Length);

/*
 * PlayerID - Player entity.
 * ViewModel - View model of the weapon as integer and not string.
*/
native SetPlayerViewModel(PlayerID, ViewModel);

/*
 * PlayerID - Player entity.
 * WeapModel - Weapon model of the weapon as integer and not string.
*/
native SetPlayerWeapModel(PlayerID, WeapModel);

/*
 * Precaches model.
 ### Returns model as integer number.
*/
native PrecacheWeaponModelEx(Model[]);

/*
 * PlayerID - Player entity.
 * Animation - Animation index.
 * Activity - Activity, check ACT enum.
 *** Check 'cswm_const.inc' for activity enum.
 * FrameRate - Frame rate of animation.
 *** Default is 1.0
*/
native SetAnimation(PlayerID, Animation, any:Actvity, Float:FrameRate);

/*
 * WeaponID - Weapon id.
 *** Weapon id is CSW_*.
 ### Returns weapon delay.
*/
native Float:GetWeaponDefaultDelay(WeaponID);

/*
 * Weapon - Index of the weapon.
 * Animation - Animation index.
 ### Returns weapon animation's duration.
*/
native Float:GetWeaponAnimDuration(Weapon, Animation);

/*
 * Weapon - Index of the weapon.
 * ModelID - Id of the model.
 *** 0=View|1=Weap|2=World|3=WeaponList
 * Model - Model that should be assigned and precached.
 *** Note that model can be weaponlist (Sprite).
*/
native BuildWeaponModel(Weapon, ModelID, Model[]);

/*
 * Weapon - Index of the weapon.
 * ModelID - Id of the model.
 *** 0=View|1=Weap|2=World|3=WeaponList
 * Model - Model (Integer) that should be assigned and precached.
 *** Note that model can be weaponlist (Sprite).
*/
native BuildWeaponModelEx(Weapon, ModelID, Model);

/*
 * WeaponEnt - Weapon entity.
 ### Returns weapon clip, if weapon is custom and has SoloClip enabled then will return player's ammo.
*/
native GetWeaponClip(WeaponEnt);

/*
 * WeaponEnt - Weapon entity.
 * Amount - Amount of clip.
 *
 * If weapon is custom and has SoloClip enabled this native
 * will set player's ammo to this value.
*/
native SetWeaponClip(WeaponEnt, Amount);

/*
 * PlayerID - player entity.
 * Type - Type of status icon.
 *** Type is status icon message 1st argument.
 * Number - Number should be shown.
 *** Maximum number is 9 and minimum is 0.
*/
native StatusIconNumber(PlayerID, Type, Number);

/*
 * WeaponEnt - Weapon entity.
 ### Returns whether weapon is custom or not.
*/
native IsCustomWeaponEntity(WeaponEnt);

/*
 * WeaponEnt - Weapon entity.
 ### Returns weapon key if it is custom otherwise -1.
*/
native GetWeaponEntityKey(WeaponEnt);

/*
 * WeaponEnt - Weapon entity.
 * Data - Weapon entity data.
 *** See WEData enum in 'cswm_const.inc'
 ### Returns weapon entity data.
*/
native any:GetWeaponEntityData(WeaponEnt, any:Data);

/*
 * WeaponEnt - Weapon entity.
 * Data - Weapon entity data.
 *** See WEData enum in 'cswm_const.inc'
 * Value - Value of data.
*/
native SetWeaponEntityData(WeaponEnt, any:Data, Value);

/*
 * Weapon - Index of the weapon.
 * Index - Index of body of weapon world model.
 *** This will set submodel of current weapon's world model when it will be dropped.
*/
native SetWeaponWBody(Weapon, Index);

/*
 * PushPower - Power of push for knockback.
 * JumpPower - Z axis power.
 *** Jump power will be also multiplied by push power.
*/
native SetKnockbackInfo(Float:PushPower, Float:JumpPower);

/*
 * PlayerID - Player entity.
 * Origin - Center of knockback.
*/
native PlayerKockback(PlayerID, Float:Origin[3]);

/*
 * Same as Ham_TakeDamage, but with fix of custom weapon's damage
*/
native RegisterTakeDamageForward(Callback[]);