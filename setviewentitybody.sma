#include <amxmodx>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <reapi>

#define PLUGIN	"SetViewEntityBody"
#define VERSION	"2"
#define AUTHOR	"Hanna"	//Builds by Hanna https://forums.alliedmods.net/showthread.php?t=287754, profile https://forums.alliedmods.net/member.php?u=273346

#define TASK_ID 48318

//Natives
native cs_set_viewmodel_body(iPlayer, iValue);
native cs_get_viewmodel_body(iPlayer);
/*native cs_set_user_sex(iPlayer, iValue);
native cs_get_user_sex(iPlayer);*/

//Linux diff
//const XO_WEAPON = 4
//const XO_PLAYER = 5

//Spectator options
//const NULLENT = -1
#define OBS_IN_EYE 4

//Player base
#define MAXPLAYERS 32
#define TRUE 1
#define FALSE 0

//Weapon State
#define WPNSTATE_GLOCK18_BURST_MODE (1<<1)
#define WPNSTATE_FAMAS_BURST_MODE (1<<4)
#define WPNSTATE_M4A1_SILENCED (1<<2)
#define WPNSTATE_USP_SILENCED (1<<0)
#define WPNSTATE_ELITE_LEFT (1<<3)

const UNSIL = 0
const SILENCED = 1

//Weapon type
#define WEAPONTYPE_ELITE 1
#define WEAPONTYPE_GLOCK18 2
#define WEAPONTYPE_FAMAS 3
#define WEAPONTYPE_OTHER 4
#define WEAPONTYPE_M4A1 5
#define WEAPONTYPE_USP 6

//Weapon anims
#define IDLE_ANIM 0
#define GLOCK18_SHOOT2 4
#define GLOCK18_SHOOT3 5
#define AK47_SHOOT1 3
#define AUG_SHOOT1 3
#define AWP_SHOOT2 2
#define DEAGLE_SHOOT1 2
#define ELITE_SHOOTLEFT5 6	//TODO
#define ELITE_SHOOTRIGHT5 12
#define CLARION_SHOOT2 4
#define CLARION_SHOOT3 3
#define FIVESEVEN_SHOOT1 1
#define G3SG1_SHOOT 1
#define GALIL_SHOOT3 5
#define M3_FIRE2 2
#define XM1014_FIRE2 2
#define M4A1_SHOOT3 3
#define M4A1_UNSIL_SHOOT3 10
#define M249_SHOOT2 2
#define MAC10_SHOOT1 3
#define MP5N_SHOOT1 3
#define P90_SHOOT1 3
#define P228_SHOOT2 2
#define SCOUT_SHOOT 1
#define SG550_SHOOT 1
#define SG552_SHOOT2 4
#define TMP_SHOOT3 5
#define UMP45_SHOOT2 4
#define USP_UNSIL_SHOOT3 11
#define USP_SHOOT3 3

const USP_SHOOT1_SHIELD1 = 1
const GLOCK18_SHOOT1_SHIELD = 1

const m_bOwnsShield = 2043

//#define HasUserShield(%0) get_pdata_bool(%0, m_bOwnsShield)
#define HasUserShield(%0) get_member(%0, m_bOwnsShield)

//Weapon Sounds
#define DRYFIRE_PISTOL "weapons/dryfire_pistol.wav"
#define DRYFIRE_RIFLE "weapons/dryfire_rifle.wav"
#define GLOCK18_BURST_SOUND "weapons/glock18-1.wav"
#define GLOCK18_SHOOT_SOUND "weapons/glock18-2.wav"
#define AK47_SHOOT_SOUND "weapons/ak47-1.wav"
#define AUG_SHOOT_SOUND "weapons/aug-1.wav"
#define AWP_SHOOT_SOUND "weapons/awp1.wav"
#define DEAGLE_SHOOT_SOUND "weapons/deagle-2.wav"
#define ELITE_SHOOT_SOUND "weapons/elite_fire.wav"
#define CLARION_BURST_SOUND "weapons/famas-burst.wav"
#define CLARION_SHOOT_SOUND "weapons/famas-1.wav"
#define FIVESEVEN_SHOOT_SOUND "weapons/fiveseven-1.wav"
#define G3SG1_SHOOT_SOUND "weapons/g3sg1-1.wav"
#define GALIL_SHOOT_SOUND "weapons/galil-1.wav"
#define M3_SHOOT_SOUND "weapons/m3-1.wav"
#define XM1014_SHOOT_SOUND "weapons/xm1014-1.wav"
#define M4A1_SILENT_SOUND "weapons/m4a1-1.wav"
#define M4A1_SHOOT_SOUND "weapons/m4a1_unsil-1.wav"
#define M249_SHOOT_SOUND "weapons/m249-1.wav"
#define MAC10_SHOOT_SOUND "weapons/mac10-1.wav"
#define MP5_SHOOT_SOUND "weapons/mp5-1.wav"
#define P90_SHOOT_SOUND "weapons/p90-1.wav"
#define P228_SHOOT_SOUND "weapons/p228-1.wav"
#define SCOUT_SHOOT_SOUND "weapons/scout_fire-1.wav"
#define SG550_SHOOT_SOUND "weapons/sg550-1.wav"
#define SG552_SHOOT_SOUND "weapons/sg552-1.wav"
#define TMP_SHOOT_SOUND "weapons/tmp-1.wav"
#define UMP45_SHOOT_SOUND "weapons/ump45-1.wav"
#define USP_SHOOT_SOUND "weapons/usp_unsil-1.wav"
#define USP_SILENT_SOUND "weapons/usp1.wav"

//Shell Models
#define SHELL_MODEL	"models/pshell.mdl"
#define SHOTGUN_SHELL_MODEL "models/shotgunshell.mdl"

//Macros
#define WEAPON_STRING(%0,%1) (pev(%0, pev_classname, %1, charsmax(%1)))
//#define WEAPON_ENT(%0) (get_pdata_int(%0, m_iId, XO_WEAPON))
#define WEAPON_ENT(%0) (get_member(%0, m_iId))
#define CLIENT_DATA(%0,%1,%2) (get_user_info(%0, %1, %2, charsmax(%2)))
#define HOOK_DATA(%0,%1,%2) (set_user_info(%0, %1, %2))

// CBasePlayerItem
const m_pPlayer = 41 // CBasePlayer *
const m_iId = 43 // int

// CBasePlayerWeapon
const m_flNextPrimaryAttack = 46 // float
const m_iClip = 51 // int
const m_iShellId = 57 // int
const m_iShotsFired = 64 // int
const m_iWeaponState = 74 // int
const m_flLastEventCheck = 38 // float

// CBasePlayer
const m_flEjectBrass = 111 // float
const m_pActiveItem = 373 // CBasePlayerItem *

//Weapon ents
/*
new WeaponNames[][] = { "weapon_knife", "weapon_glock18", "weapon_ak47", "weapon_aug", "weapon_awp", "weapon_c4", "weapon_deagle", "weapon_elite", "weapon_famas", 
	"weapon_fiveseven", "weapon_flashbang", "weapon_g3sg1", "weapon_galil", "weapon_hegrenade", "weapon_m3", "weapon_xm1014", "weapon_m4a1", "weapon_m249", "weapon_mac10", 
	"weapon_mp5navy", "weapon_p90", "weapon_p228", "weapon_scout", "weapon_sg550", "weapon_sg552", "weapon_smokegrenade", "weapon_tmp", "weapon_ump45", "weapon_usp" }
*/

// We use this only for knife and usp
new WeaponNames[][] = { "weapon_knife", "weapon_usp" }

new g_fwChangeSkin;

//World decals
new TraceBullets[][] = { "func_breakable", "func_wall", "func_door", "func_plat", "func_rotating", "worldspawn", "func_door_rotating" }

new iBodyIndex[MAXPLAYERS + 1]
const GUN_SHOT_DECAL_NUM = 5
new /*iSex[MAXPLAYERS + 1], */g_szModName[8], g_iGunShotDecalNums[GUN_SHOT_DECAL_NUM]

new iShellRifle, iShellShotgun;

new g_bDebugMode;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);
	
	for (new i; i < sizeof WeaponNames; i++)
	{
		RegisterHam(Ham_Item_Deploy, WeaponNames[i], "HamF_Item_Deploy_Post", TRUE);
		RegisterHam(Ham_CS_Weapon_SendWeaponAnim, WeaponNames[i], "HamF_CS_Weapon_SendWeaponAnim_Post", TRUE);
		RegisterHam(Ham_Weapon_PrimaryAttack, WeaponNames[i], "HamF_Weapon_PrimaryAttack");
	}
	
	for (new i; i < sizeof TraceBullets; i++)		
		RegisterHam(Ham_TraceAttack, TraceBullets[i], "HamF_TraceAttack_Post", TRUE);
	
	register_forward(FM_UpdateClientData, "FM_Hook_UpdateClientData_Post", TRUE);
	register_forward(FM_PlaybackEvent, "Forward_PlaybackEvent");
	register_forward(FM_ClientUserInfoChanged, "Forward_ClientUserInfoChanged");

	new ent = fm_create_entity("info_target");

	set_pev(ent, pev_classname, "weapondeploy_think");
	set_pev(ent, pev_nextthink, get_gametime() + 1.0);
	RegisterHam(Ham_Think, "info_target", "weapondeploy_think", 1);
	
	get_modname(g_szModName, charsmax(g_szModName))
	// Gun Shot decals
	if (equali(g_szModName,"cstrike"))
	{	
		g_iGunShotDecalNums = {38, 39, 40, 41, 42}
	}
	else if (equali(g_szModName,"czero"))
	{
		g_iGunShotDecalNums = {53, 54, 55, 56, 57}
	}

	g_fwChangeSkin = CreateMultiForward("change_skin", ET_IGNORE, FP_CELL, FP_CELL);

	g_bDebugMode = bool:(plugin_flags() & AMX_FLAG_DEBUG);
}

public plugin_precache()
{
	iShellRifle = engfunc(EngFunc_PrecacheModel, SHELL_MODEL);
	iShellShotgun = engfunc(EngFunc_PrecacheModel, SHOTGUN_SHELL_MODEL);
}

new g_iDeployWeaponSwitch[MAX_PLAYERS] = {0};

public HamF_Item_Deploy_Post(iEnt)
{
	static iPlayer;	
	//iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);
	iPlayer = get_member(iEnt, m_pPlayer);	//CBasePlayerItem::m_pPlayer
	if(!is_user_alive(iPlayer))
	{
		if(g_bDebugMode)
			log_amx("HamF_Item_Deploy_Post: Invalid iPlayer=%d, iEnt=%d", iPlayer, iEnt);
		return;
	}
		
	set_pev(iPlayer, pev_viewmodel2, "");	//Because we unprecached our default viewmodels or we don't want to show the original bodyid

	g_iDeployWeaponSwitch[iPlayer] = 1;
	//if(task_exists(iPlayer + TASK_ID)) remove_task(iPlayer + TASK_ID);
	//set_task(0.1, "DeployWeaponSwitch", iPlayer + TASK_ID);	//Set with a bit delay to prevent bug, m_flLastEventCheck need delay too
}

public weapondeploy_think(ent)
{	
	static classname[64];
	static i;
	pev(ent, pev_classname, classname, 63);
	// Really hacky way, but it works...
	if(equal(classname, "weapondeploy_think")){
		for(i = 0;i<MAX_PLAYERS;i++){
			if(g_iDeployWeaponSwitch[i] == 1){
				g_iDeployWeaponSwitch[i] = 2;
			}
			else if(g_iDeployWeaponSwitch[i] == 2){
				DeployWeaponSwitch(i);
				g_iDeployWeaponSwitch[i] = 0;
			}
			
		}

		set_pev(ent, pev_nextthink, get_gametime() + 0.01);
	}
}

public HamF_CS_Weapon_SendWeaponAnim_Post(iEnt, iAnim, Skiplocal)
{
	static iPlayer;
	//iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);
	iPlayer = get_member(iEnt, m_pPlayer);	//CBasePlayerItem::m_pPlayer
	if(!is_user_alive(iPlayer))
	{
		if(g_bDebugMode)
			log_amx("HamF_CS_Weapon_SendWeaponAnim_Post: Invalid iPlayer=%d, iEnt=%d", iPlayer, iEnt);
		return;
	}
		
	SendWeaponAnim(iPlayer, iAnim, iBodyIndex[iPlayer]);	//Our v_ animations overhaul (reload, sil, unsil and other)
}

public HamF_Weapon_PrimaryAttack(iEnt)
{
	if(g_bDebugMode)
		log_amx("HamF_Weapon_PrimaryAttack: iEnt=%d", iEnt);
	
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_C4, CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE:
		{
			if(g_bDebugMode)
				log_amx("HamF_Weapon_PrimaryAttack: Ignored non-shooting weapon - iEnt=%d", iEnt);
			return HAM_IGNORED;
		}
		default: 
		{
			if(g_bDebugMode)
				log_amx("HamF_Weapon_PrimaryAttack: Calling PrimaryAttackEmulation - iEnt=%d", iEnt);
			PrimaryAttackEmulation(iEnt);
		}
	}
	
	return HAM_IGNORED;
}

public HamF_TraceAttack_Post(iEnt, iAttacker, Float:damage, Float:fDir[3], ptr/*, iDamageType*/)
{
	if(g_bDebugMode)
		log_amx("HamF_TraceAttack_Post: Start - iEnt=%d, iAttacker=%d", iEnt, iAttacker);
	
	if (iAttacker < 1 || iAttacker > MAXPLAYERS)
		return HAM_IGNORED;
	
	static iWeapon, Float:vecEnd[3];	
	//iWeapon = get_pdata_cbase(iAttacker, m_pActiveItem, XO_PLAYER);
	iWeapon = get_member(iAttacker, m_pActiveItem);	//CBasePlayerItem::m_pPlayer
	
	if(!pev_valid(iWeapon)) 
	{
		if(g_bDebugMode)
			log_amx("HamF_TraceAttack_Post: Invalid iWeapon=%d, iAttacker=%d", iWeapon, iAttacker);
		return HAM_IGNORED;
	}
	
	if(g_bDebugMode)
		log_amx("HamF_TraceAttack_Post: Processing - iEnt=%d, iAttacker=%d, weapon=%d", 
			iEnt, iAttacker, WEAPON_ENT(iWeapon));
	
	switch(WEAPON_ENT(iWeapon))
	{
		case CSW_KNIFE: 
		{
			if(g_bDebugMode)
				log_amx("HamF_TraceAttack_Post: Knife ignored - iEnt=%d, iAttacker=%d", iEnt, iAttacker);
			return HAM_IGNORED;
		}
		default:
		{
			if(g_bDebugMode)
				log_amx("HamF_TraceAttack_Post: Getting trace pos - ptr=%d", ptr);
			get_tr2(ptr, TR_vecEndPos, vecEnd);
	
			if(g_bDebugMode)
				log_amx("HamF_TraceAttack_Post: Creating decal - iEnt=%d, pos=(%f, %f, %f)", 
					iEnt, vecEnd[0], vecEnd[1], vecEnd[2]);
			// Decal effects, add here spark, any
			engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecEnd, 0);
			write_byte(TE_GUNSHOTDECAL);
			engfunc(EngFunc_WriteCoord, vecEnd[0]);
			engfunc(EngFunc_WriteCoord, vecEnd[1]);
			engfunc(EngFunc_WriteCoord, vecEnd[2]);
			write_short(iEnt);
			write_byte(g_iGunShotDecalNums[random_num(0, GUN_SHOT_DECAL_NUM - 1)]);
			message_end();			
		}
	}
	
	if(g_bDebugMode)
		log_amx("HamF_TraceAttack_Post: Finished - iEnt=%d, iAttacker=%d", iEnt, iAttacker);
	return HAM_IGNORED;	
}

	enum
	{
		SPEC_MODE,
		SPEC_TARGET,
		SPEC_END
	}; 

//CS weapon animations hook/block fire here. With pev_iuser2 checkout. This code part by fl0wer
public FM_Hook_UpdateClientData_Post(iPlayer, SendWeapons, CD_Handle)
{	
	static aSpecInfo[33][SPEC_END];
	static Float: flGameTime;
	static Float: flLastEventCheck;
	static iTarget;
	static iSpecMode;
	static iActiveItem;
	static iId;
	static iWeaponName[24]
	static bool:validWeapon;

	iTarget = (iSpecMode = pev(iPlayer, pev_iuser1)) ? pev(iPlayer, pev_iuser2) : iPlayer;
	
	if(!pev_valid(iTarget))
		return FMRES_IGNORED

	//iActiveItem = get_pdata_cbase(iTarget, m_pActiveItem, XO_PLAYER);
	iActiveItem = get_member(iTarget, m_pActiveItem);	//CBasePlayer::m_pActiveItem

	if(!pev_valid(iActiveItem))
		return FMRES_IGNORED


	validWeapon = false;
	WEAPON_STRING(iActiveItem, iWeaponName);

	for (new i; i < sizeof WeaponNames; i++)
	{
		if(equali(iWeaponName, WeaponNames[i]))
			validWeapon = true;
	}

	if(!validWeapon)
		return FMRES_IGNORED;

	if(!iActiveItem || iActiveItem == NULLENT || !pev_valid(iActiveItem))
		return FMRES_IGNORED;

	//iId = get_pdata_int(iActiveItem, m_iId, XO_WEAPON);
	iId = get_member(iActiveItem, m_iId);	//CBasePlayerItem::m_iId
	
	if(!iId || iId == FM_NULLENT || !pev_valid(iId))
		return FMRES_IGNORED;

	flGameTime = get_gametime();
	//flLastEventCheck = get_pdata_float(iActiveItem, m_flLastEventCheck, XO_WEAPON);
	flLastEventCheck = get_member(iActiveItem, m_flLastEventCheck);	//CBasePlayerWeapon::m_flLastEventCheck

	if(iSpecMode)
	{		
		if(aSpecInfo[iPlayer][SPEC_MODE] != iSpecMode)
		{
			aSpecInfo[iPlayer][SPEC_MODE] = iSpecMode;
			aSpecInfo[iPlayer][SPEC_TARGET] = FALSE;
		}

		if(iSpecMode == OBS_IN_EYE && aSpecInfo[iPlayer][SPEC_TARGET] != iTarget)
		{
			aSpecInfo[iPlayer][SPEC_TARGET] = iTarget;

			new iTaskData[2];
			iTaskData[0] = iBodyIndex[iTarget];
			iTaskData[1] = IDLE_ANIM;
				
			//Because once pushing LMB u will immediately move to OBS_IN_EYE, the anim message may skip, so let's make delay
			set_task(0.1, "SPEC_OBS_IN_EYE", iPlayer, iTaskData, sizeof(iTaskData));	//Delay 0.1, because with high ping this may skip this 99%
		}
	}

	if(!flLastEventCheck)
	{
		set_cd(CD_Handle, CD_flNextAttack, flGameTime + 0.001);
		set_cd(CD_Handle, CD_WeaponAnim, IDLE_ANIM);
		return FMRES_HANDLED;
	}

	if(flLastEventCheck <= flGameTime)
	{			
		SendWeaponAnim(iTarget, GetWeaponDrawAnim(iActiveItem), iBodyIndex[iTarget]);	//Custom weapon draw anim should go there too	
		//set_pdata_float(iActiveItem, m_flLastEventCheck, 0.0, XO_WEAPON);
		set_member(iActiveItem, m_flLastEventCheck, 0.0);	//m_flLastEventCheck = 0.0;	//Preventing from sending anims to client
	}

	return FMRES_IGNORED;
}
	
public Forward_PlaybackEvent(iFlags, pPlayer/*, iEvent, Float:fDelay, Float:vecOrigin[3], Float:vecAngle[3], Float:flParam1, Float:flParam2, iParam1, iParam2, bParam1, bParam2*/)
{	
	//Fire anim for spectator, don't worry this will not touch anything, except pev_iuser2
	static i, iCount, iSpectator, iszSpectators[32];

	get_players(iszSpectators, iCount, "bch");

	for(i = 0; i < iCount; i++)
	{
		iSpectator = iszSpectators[i];

		if(pev(iSpectator, pev_iuser1) != OBS_IN_EYE || pev(iSpectator, pev_iuser2) != pPlayer) 
			continue;
		
		return FMRES_SUPERCEDE;
	}		
	
	return FMRES_IGNORED;	//Let other things to be pass, such as custom weapons	
}

public Forward_ClientUserInfoChanged(iPlayer)
{
	static iUserInfo[6] = "cl_lw", iClientValue[2], iServerValue[2] = "1";	//Preventing them from enabling server weapons to avoid clientside bugs
	//I guess cl_minmodels block should go here too, will do later
	
	if(CLIENT_DATA(iPlayer, iUserInfo, iClientValue))
	{
		HOOK_DATA(iPlayer, iUserInfo, iServerValue);
		
		//client_print(iPlayer, print_chat, "User Local Weapons Value: %s, Server Local Weapons Value: %s", iClientValue, iServerValue);
				
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

//Natives
public plugin_natives()
{
	register_native("cs_set_viewmodel_body", "ViewBodySwitch", TRUE);
	register_native("cs_get_viewmodel_body", "GetViewBodySwitch", TRUE);
	/*register_native("cs_set_user_sex", "SetSex", TRUE);
	register_native("cs_get_user_sex", "GetSex", TRUE);*/
}

public ViewBodySwitch(iPlayer, iValue)
	iBodyIndex[iPlayer] = iValue;
	
public GetViewBodySwitch(iPlayer)
	return iBodyIndex[iPlayer];	

/*
public SetSex(iPlayer, iValue)
	iSex[iPlayer] = iValue;

public GetSex(iPlayer)
	return iSex[iPlayer];*/


	/***************************************************************************/
	/***************************************************************************/	
	
	/*CUSTOM FUNCTIONS*/

	/***************************************************************************/
	/***************************************************************************/	


//Get .mdl draw anim sequence
GetWeaponDrawAnim(iEntity)
{
	static DrawAnim, iWeaponState;
	iWeaponState = get_member(iEntity, m_Weapon_iWeaponState);
	if(iWeaponState & WPNSTATE_USP_SILENCED || iWeaponState & WPNSTATE_M4A1_SILENCED)
		iWeaponState = SILENCED;
	else if(iWeaponState & WPNSTATE_USP_SILENCED || iWeaponState & WPNSTATE_M4A1_SILENCED)
		iWeaponState = UNSIL;

	// if(get_pdata_int(iEntity, m_iWeaponState, XO_WEAPON) & WPNSTATE_USP_SILENCED || get_pdata_int(iEntity, m_iWeaponState, XO_WEAPON) & WPNSTATE_M4A1_SILENCED)
	// 	iWeaponState = SILENCED
	// else
	// 	iWeaponState = UNSIL	
	
	switch(WEAPON_ENT(iEntity))
	{
		case CSW_XM1014, CSW_M3: DrawAnim = 6;
		case CSW_P228:
		{
			//switch(HasUserShield(get_pdata_cbase(iEntity, m_pPlayer, XO_WEAPON)))
			switch(HasUserShield(get_member(iEntity, m_pPlayer)))
			{
				case false: DrawAnim = 6;
				case true: DrawAnim = 5;
			}
		}
		case CSW_SCOUT, CSW_SG550, CSW_M249, CSW_G3SG1: DrawAnim = 4;
		case CSW_MAC10, CSW_AUG, CSW_UMP45, CSW_GALIL, CSW_FAMAS, CSW_MP5NAVY, CSW_TMP, CSW_SG552, CSW_AK47, CSW_P90: DrawAnim = 2;
		case CSW_ELITE: DrawAnim = 15;
		case CSW_FIVESEVEN, CSW_AWP, CSW_DEAGLE: DrawAnim = 5;
		case CSW_USP:
		{
			// There is no silenced shield variety. So check for silenced, then for shield first.
			if(iWeaponState == SILENCED)
			{
				DrawAnim = 6;
			}
			//else if(HasUserShield(get_pdata_cbase(iEntity, m_pPlayer, XO_WEAPON)))
			else if(HasUserShield(get_member(iEntity, m_pPlayer)))
			{
				DrawAnim = 5;
			}
			else
			{
				DrawAnim = 14;
			}
		}
		case CSW_M4A1:
		{
			switch(iWeaponState)
			{
				case SILENCED: DrawAnim = 5;
				case UNSIL: DrawAnim = 12;
			}
		}	
		case CSW_GLOCK18:
		{
			//switch(HasUserShield(get_pdata_cbase(iEntity, m_pPlayer, XO_WEAPON)))
			switch(HasUserShield(get_member(iEntity, m_pPlayer)))
			{
				case false: DrawAnim = 8;
				case true: DrawAnim = 5;
			}
		}
		
		case CSW_KNIFE, CSW_HEGRENADE, CSW_FLASHBANG, CSW_SMOKEGRENADE: DrawAnim = 3;
		case CSW_C4: DrawAnim = 1;	
	}
		
	return DrawAnim;
}

//Emulation, not attack replace
PrimaryAttackEmulation(iEnt)
{
	if(g_bDebugMode)
		log_amx("PrimaryAttackEmulation: iEnt=%d, weapon=%d", iEnt, WEAPON_ENT(iEnt));
	
	switch(WEAPON_ENT(iEnt))
	{		
		//Func description: WeaponShootInfo(iWeapon, iAnim, const szSoundEmpty[], const szSoundFire[], iAutoShoot, iWeaponType)

		case CSW_GLOCK18: WeaponShootInfo(iEnt, GLOCK18_SHOOT3, DRYFIRE_PISTOL, GLOCK18_SHOOT_SOUND, FALSE, WEAPONTYPE_GLOCK18);
		case CSW_AK47: WeaponShootInfo(iEnt, AK47_SHOOT1, DRYFIRE_RIFLE, AK47_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_AUG: WeaponShootInfo(iEnt, AUG_SHOOT1, DRYFIRE_RIFLE, AUG_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_AWP: WeaponShootInfo(iEnt, AWP_SHOOT2, DRYFIRE_RIFLE, AWP_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_DEAGLE: WeaponShootInfo(iEnt, DEAGLE_SHOOT1, DRYFIRE_PISTOL, DEAGLE_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_ELITE: WeaponShootInfo(iEnt, ELITE_SHOOTRIGHT5, DRYFIRE_PISTOL, ELITE_SHOOT_SOUND, FALSE, WEAPONTYPE_ELITE);
		case CSW_FAMAS: WeaponShootInfo(iEnt, CLARION_SHOOT3, DRYFIRE_RIFLE, CLARION_SHOOT_SOUND, TRUE, WEAPONTYPE_FAMAS);
		case CSW_FIVESEVEN: WeaponShootInfo(iEnt, FIVESEVEN_SHOOT1, DRYFIRE_PISTOL, FIVESEVEN_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_G3SG1: WeaponShootInfo(iEnt, G3SG1_SHOOT, DRYFIRE_RIFLE, G3SG1_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_GALIL: WeaponShootInfo(iEnt, GALIL_SHOOT3, DRYFIRE_RIFLE, GALIL_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_M3: WeaponShootInfo(iEnt, M3_FIRE2, DRYFIRE_RIFLE, M3_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_XM1014: WeaponShootInfo(iEnt, XM1014_FIRE2, DRYFIRE_RIFLE, XM1014_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_M4A1: WeaponShootInfo(iEnt, M4A1_UNSIL_SHOOT3, DRYFIRE_RIFLE, M4A1_SHOOT_SOUND, TRUE, WEAPONTYPE_M4A1);
		case CSW_M249: WeaponShootInfo(iEnt, M249_SHOOT2, DRYFIRE_RIFLE, M249_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_MAC10: WeaponShootInfo(iEnt, MAC10_SHOOT1, DRYFIRE_RIFLE, MAC10_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_MP5NAVY: WeaponShootInfo(iEnt, MP5N_SHOOT1, DRYFIRE_RIFLE, MP5_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_P90: WeaponShootInfo(iEnt, P90_SHOOT1, DRYFIRE_RIFLE, P90_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_P228: WeaponShootInfo(iEnt, P228_SHOOT2, DRYFIRE_PISTOL, P228_SHOOT_SOUND, FALSE, WEAPONTYPE_OTHER);
		case CSW_SCOUT: WeaponShootInfo(iEnt, SCOUT_SHOOT, DRYFIRE_RIFLE, SCOUT_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG550: WeaponShootInfo(iEnt, SG550_SHOOT, DRYFIRE_RIFLE, SG550_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_SG552: WeaponShootInfo(iEnt, SG552_SHOOT2, DRYFIRE_RIFLE, SG552_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_TMP: WeaponShootInfo(iEnt, TMP_SHOOT3, DRYFIRE_RIFLE, TMP_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_UMP45: WeaponShootInfo(iEnt, UMP45_SHOOT2, DRYFIRE_RIFLE, UMP45_SHOOT_SOUND, TRUE, WEAPONTYPE_OTHER);
		case CSW_USP: WeaponShootInfo(iEnt, USP_UNSIL_SHOOT3, DRYFIRE_PISTOL, USP_SHOOT_SOUND, FALSE, WEAPONTYPE_USP);	
	}
	
	if(g_bDebugMode)
		log_amx("PrimaryAttackEmulation: Finished - iEnt=%d", iEnt);
	return HAM_IGNORED;
}

//Set here anims, sounds
WeaponShootInfo(iEnt, iAnim, const szSoundEmpty[], const szSoundFire[], iAutoShoot, iWeaponType)
{
	if(g_bDebugMode)
		log_amx("WeaponShootInfo: Start - iEnt=%d, iAnim=%d, weaponType=%d", iEnt, iAnim, iWeaponType);
	
	static iPlayer, iClip, iWeaponState; 
	//iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);
	iPlayer = get_member(iEnt, m_pPlayer);
	if(!pev_valid(iPlayer)) 
	{
		if(g_bDebugMode)
			log_amx("WeaponShootInfo: Invalid iPlayer=%d, iEnt=%d", iPlayer, iEnt);
		return HAM_SUPERCEDE;
	}
	
	//iClip = get_pdata_int(iEnt, m_iClip, XO_WEAPON);
	iClip = get_member(iEnt, m_Weapon_iClip);
	
	if(!iClip) 
	{	
		if(g_bDebugMode)
			log_amx("WeaponShootInfo: No ammo - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
		emit_sound(iPlayer, CHAN_AUTO, szSoundEmpty, 0.8, ATTN_NORM, 0, PITCH_NORM);
		//set_pdata_float(iEnt, m_flNextPrimaryAttack, 0.2, XO_WEAPON);
		set_member(iEnt, m_Weapon_flNextPrimaryAttack, 0.2);
		return HAM_SUPERCEDE;		
	}
	
	//if(get_pdata_int(iEnt, m_iShotsFired, XO_WEAPON) && !iAutoShoot)
	if(get_member(iEnt, m_Weapon_iShotsFired) && !iAutoShoot)
	{
		if(g_bDebugMode)
			log_amx("WeaponShootInfo: Shots fired, not auto - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
		return HAM_SUPERCEDE;
	}
	
	//iWeaponState = get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON);
	iWeaponState = get_member(iEnt, m_Weapon_iWeaponState);

	switch(iWeaponType)
	{
		case WEAPONTYPE_ELITE:
		{
			if(g_bDebugMode)
				log_amx("WeaponShootInfo: Elite - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
			if(iWeaponState & WPNSTATE_ELITE_LEFT)
				PlayWeaponState(iPlayer, ELITE_SHOOT_SOUND, ELITE_SHOOTLEFT5);
		}	
		case WEAPONTYPE_GLOCK18:
		{
			if(g_bDebugMode)
				log_amx("WeaponShootInfo: Glock18 - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
			if(iWeaponState & WPNSTATE_GLOCK18_BURST_MODE)
				PlayWeaponState(iPlayer, GLOCK18_BURST_SOUND, GLOCK18_SHOOT2);
			else if(HasUserShield(iPlayer))
			{
				PlayWeaponState(iPlayer, GLOCK18_SHOOT_SOUND, GLOCK18_SHOOT1_SHIELD);
				EjectBrass(iPlayer, iEnt);
				return HAM_IGNORED
			}
		}
		case WEAPONTYPE_FAMAS:
		{
			if(g_bDebugMode)
				log_amx("WeaponShootInfo: FAMAS - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
			if(iWeaponState & WPNSTATE_FAMAS_BURST_MODE)
				PlayWeaponState(iPlayer, CLARION_BURST_SOUND, CLARION_SHOOT2);	
		}
		case WEAPONTYPE_M4A1:
		{
			if(g_bDebugMode)
				log_amx("WeaponShootInfo: M4A1 - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
			if(iWeaponState & WPNSTATE_M4A1_SILENCED)
				PlayWeaponState(iPlayer, M4A1_SILENT_SOUND, M4A1_SHOOT3);	
		}
		case WEAPONTYPE_USP:
		{
			if(g_bDebugMode)
				log_amx("WeaponShootInfo: USP - iPlayer=%d, iEnt=%d, silenced=%d, shield=%d", 
					iPlayer, iEnt, 
					(iWeaponState & WPNSTATE_USP_SILENCED) ? 1 : 0, 
					HasUserShield(iPlayer) ? 1 : 0);
			if(iWeaponState & WPNSTATE_USP_SILENCED)
				PlayWeaponState(iPlayer, USP_SILENT_SOUND, USP_SHOOT3);	
			else if(HasUserShield(iPlayer))
			{
				PlayWeaponState(iPlayer, USP_SHOOT_SOUND, USP_SHOOT1_SHIELD1);
				EjectBrass(iPlayer, iEnt);
				return HAM_IGNORED
			}
		}		
	}

	//Second mode disabled or weapontype other
	if(!iWeaponState)
	{
		if(g_bDebugMode)
			log_amx("WeaponShootInfo: Default mode - iPlayer=%d, iEnt=%d, sound=%s", 
				iPlayer, iEnt, szSoundFire);
		PlayWeaponState(iPlayer, szSoundFire, iAnim);	
	}
	
	if(g_bDebugMode)
		log_amx("WeaponShootInfo: Calling EjectBrass - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
	EjectBrass(iPlayer, iEnt);
	
	if(g_bDebugMode)
		log_amx("WeaponShootInfo: Finished - iEnt=%d", iEnt);
	return HAM_IGNORED;	
}

//Play shoot anim and emit fire sounds
PlayWeaponState(iPlayer, const szShootSound[], iWeaponAnim)
{
	if(g_bDebugMode)
		log_amx("PlayWeaponState: Start - iPlayer=%d, sound=%s, anim=%d", 
			iPlayer, szShootSound, iWeaponAnim);
	
	emit_sound(iPlayer, CHAN_WEAPON, szShootSound, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
	
	if(g_bDebugMode)
		log_amx("PlayWeaponState: Calling SendWeaponAnim - iPlayer=%d, anim=%d, body=%d", 
			iPlayer, iWeaponAnim, iBodyIndex[iPlayer]);
	SendWeaponAnim(iPlayer, iWeaponAnim, iBodyIndex[iPlayer])	
	
	if(g_bDebugMode)
		log_amx("PlayWeaponState: Finished - iPlayer=%d", iPlayer);
}

//Animation const (include Spectators check) by fl0wer
SendWeaponAnim(iPlayer, iAnim, iBody)
{
	static i, iCount, iSpectator, iszSpectators[32];
	
	set_pev(iPlayer, pev_weaponanim, iAnim);

	message_begin(MSG_ONE, SVC_WEAPONANIM, _, iPlayer);
	write_byte(iAnim);
	write_byte(iBody);
	message_end();

	if(pev(iPlayer, pev_iuser1))
		return;

	get_players(iszSpectators, iCount, "bch");

	for(i = 0; i < iCount; i++)
	{
		iSpectator = iszSpectators[i];

		if(pev(iSpectator, pev_iuser1) != OBS_IN_EYE || pev(iSpectator, pev_iuser2) != iPlayer) 
			continue;

		set_pev(iSpectator, pev_weaponanim, iAnim);

		message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, _, iSpectator);
		write_byte(iAnim);
		write_byte(iBody);
		message_end();
	}	
}


//Shells, i've searched the client burst shell ejection, but the function does same effect, so let it be
EjectBrass(iPlayer, iEnt)
{
	if(g_bDebugMode)
		log_amx("EjectBrass: Start - iPlayer=%d, iEnt=%d, weapon=%d", 
			iPlayer, iEnt, WEAPON_ENT(iEnt));
	
	if(!pev_valid(iPlayer) || !pev_valid(iEnt)) 
	{
		if(g_bDebugMode)
			log_amx("EjectBrass: Invalid iPlayer=%d or iEnt=%d", iPlayer, iEnt);
		return;
	}
	
	switch(WEAPON_ENT(iEnt))
	{
		case CSW_M3, CSW_XM1014: 
		{
			if(g_bDebugMode)
				log_amx("EjectBrass: Setting shotgun shell - iEnt=%d", iEnt);
			//set_pdata_int(iEnt, m_iShellId, iShellShotgun, XO_WEAPON);
			set_member(iEnt, m_Weapon_iShellId, iShellShotgun);
		}
		case CSW_ELITE: 
		{
			if(g_bDebugMode)
				log_amx("EjectBrass: Skipping elite - iEnt=%d", iEnt);
			return; //Dual Weapon client part side, should do with message, let skip this currently	
		}
		default: 
		{
			if(g_bDebugMode)
				log_amx("EjectBrass: Setting rifle shell - iEnt=%d", iEnt);
			//set_pdata_int(iEnt, m_iShellId, iShellRifle, XO_WEAPON);
			set_member(iEnt, m_Weapon_iShellId, iShellRifle);
		}
	}
	//new state = get_pdata_int(iEnt, m_iWeaponState, XO_WEAPON);
	new state1 = get_member(iEnt, m_Weapon_iClientWeaponState);
	if((state1 & WPNSTATE_FAMAS_BURST_MODE) || (state1 & WPNSTATE_GLOCK18_BURST_MODE))
	{
		if(g_bDebugMode)
			log_amx("EjectBrass: Scheduling additional burst shell - iPlayer=%d", iPlayer);
		set_task(0.1, "EjectAdditionalBurstShell", iPlayer)	//Temporarly, but don't need to create entity through amxx
	}
	
	if(g_bDebugMode)
		log_amx("EjectBrass: Setting eject brass time - iPlayer=%d", iPlayer);
	//set_pdata_float(iPlayer, m_flEjectBrass, get_gametime(), XO_PLAYER);
	set_member(iPlayer, m_flEjectBrass, get_gametime());
	
	if(g_bDebugMode)
		log_amx("EjectBrass: Finished - iPlayer=%d, iEnt=%d", iPlayer, iEnt);
}


	/***************************************************************************/
	/***************************************************************************/	
	
	/*TASK DATA*/

	/***************************************************************************/
	/***************************************************************************/

public DeployWeaponSwitch(iPlayer)
{
	static iEnt;		
	//iEnt = get_pdata_cbase(iPlayer, m_pActiveItem, XO_PLAYER);
	iEnt = get_member(iPlayer, m_pActiveItem);	//CBasePlayer::m_pActiveItem
	
	if(!iEnt || iEnt == FM_NULLENT || !pev_valid(iEnt))
		return;

	new iRet;
	ExecuteForward(g_fwChangeSkin, iRet, iPlayer, iEnt);

	//set_pdata_float(iEnt, m_flLastEventCheck, get_gametime() + 0.001, XO_WEAPON);	//0.001 is good enough
	set_member(iEnt, m_flLastEventCheck, get_gametime() + 0.001);	//0.001 is good enough
	SendWeaponAnim(iPlayer, IDLE_ANIM, iBodyIndex[iPlayer]);	//Slow message	
}	
		
public SPEC_OBS_IN_EYE(iTaskData[], iPlayer)
{
	SendWeaponAnim(iPlayer, iTaskData[1], iTaskData[0]);
}

public EjectAdditionalBurstShell(iPlayer)
{
	//set_pdata_float(iPlayer, m_flEjectBrass, get_gametime(), XO_PLAYER);
	set_member(iPlayer, m_flEjectBrass, get_gametime());
}
	
