#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <fakemeta_util>
#include <hamsandwich>


const m_iId = 43 // int
#define WEAPON_ENT(%0) (get_pdata_int(%0, m_iId, XO_WEAPON))

//Linux diff
const XO_WEAPON = 4
const XO_PLAYER = 5

// CBasePlayerItem
const m_pPlayer = 41 // CBasePlayer *
const m_pActiveItem = 373 // CBasePlayerItem *

new g_iKnifeID[MAX_PLAYERS];

new g_szKnife[MAX_PLAYERS][128];
new g_szButcher[MAX_PLAYERS][128];
new g_szBayonet[MAX_PLAYERS][128];
new g_szDagger[MAX_PLAYERS][128];
new g_szKatana[MAX_PLAYERS][128];
new g_szUsp[MAX_PLAYERS][128];
new g_szSkin[MAX_PLAYERS][128];

new bool:g_bHideKnife[MAX_PLAYERS];
new bool:g_bHideUsp[MAX_PLAYERS];

new g_iVault;

public plugin_init()
{
	//RegisterHam(Ham_Item_Deploy, "weapon_knife", "ItemDeployPost", 1);
	//RegisterHam(Ham_Item_Deploy, "weapon_usp", "ItemDeployPost", 1);

	register_event("ResetHUD", "ResetModel_Hook", "b");

	g_iVault = nvault_open("player_skins4");
}


public plugin_natives()
{
	register_native("set_user_knife_id", "set_user_knife_id_native");

	register_native("set_user_knife", "set_user_knife_native");
	register_native("set_user_butcher", "set_user_butcher_native");
	register_native("set_user_bayonet", "set_user_bayonet_native");
	register_native("set_user_dagger", "set_user_dagger_native");
	register_native("set_user_katana", "set_user_katana_native");
	register_native("set_user_usp", "set_user_usp_native");
	register_native("set_user_player_skin", "set_user_player_skin_native");

	register_native("toggle_user_knife", "toggle_user_knife_native");
	register_native("toggle_user_usp", "toggle_user_usp_native");
}

public set_user_knife_id_native(numParams)
{
	new id = get_param(1);
	new knifeId = get_param(2);

	g_iKnifeID[id] = knifeId;
}

public set_user_knife_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szKnife[id], charsmax(g_szKnife[]));
	SaveSkins(id);
}

public set_user_butcher_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szButcher[id], charsmax(g_szButcher[]));
	SaveSkins(id);
}

public set_user_bayonet_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szBayonet[id], charsmax(g_szBayonet[]));
	SaveSkins(id);
}

public set_user_dagger_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szDagger[id], charsmax(g_szDagger[]));
	SaveSkins(id);
}

public set_user_katana_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szKatana[id], charsmax(g_szKatana[]));
	SaveSkins(id);
}

public set_user_usp_native(numParams)
{
	new id = get_param(1);
	get_string(2, g_szUsp[id], charsmax(g_szUsp[]));
	SaveSkins(id);
}

public set_user_player_skin_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szSkin[id], charsmax(g_szSkin[]), skin);
	SaveSkins(id);
	cs_set_user_model(id, g_szSkin[id]);
}

public toggle_user_knife_native(numParams)
{
	new id = get_param(1);
	g_bHideKnife[id] = !g_bHideKnife[id];
}

public toggle_user_usp_native(numParams)
{
	new id = get_param(1);
	g_bHideUsp[id] = !g_bHideUsp[id];
}


public DeployWeaponSwitch(iPlayer)
{
	static iEnt;		
	iEnt = get_pdata_cbase(iPlayer, m_pActiveItem, XO_PLAYER);
	new iWpn = WEAPON_ENT(iEnt);
	
	if(iWpn == CSW_USP && g_bHideUsp[iPlayer]) return HAM_IGNORED;

	if(iWpn == CSW_KNIFE && g_bHideKnife[iPlayer]) return HAM_IGNORED;

	if(iWpn == CSW_USP)
	{
		set_pev(iPlayer, pev_viewmodel2, g_szUsp[iPlayer]);

		return HAM_IGNORED;
	}

	if(iWpn != CSW_KNIFE) return HAM_IGNORED;

	if(g_iKnifeID[iPlayer] == 0)
		set_pev(iPlayer, pev_viewmodel2, g_szKnife[iPlayer]);
	if(g_iKnifeID[iPlayer] == 1)
		set_pev(iPlayer, pev_viewmodel2, g_szButcher[iPlayer]);
	if(g_iKnifeID[iPlayer] == 2)
		set_pev(iPlayer, pev_viewmodel2, g_szBayonet[iPlayer]);
	if(g_iKnifeID[iPlayer] == 3)
		set_pev(iPlayer, pev_viewmodel2, g_szDagger[iPlayer]);
	if(g_iKnifeID[iPlayer] == 4)
		set_pev(iPlayer, pev_viewmodel2, g_szKatana[iPlayer]);

	return HAM_IGNORED;
}

public ResetModel_Hook(id, level, cid){
	if(strlen(g_szSkin[id]) && is_user_connected(id)){
		cs_set_user_model(id, g_szSkin[id]);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public client_putinserver(id){
	LoadSkins(id);
	g_bHideKnife[id] = false;
	g_bHideUsp[id] = false;
	g_iKnifeID[id] = 0;
}

public SaveSkins(id) {
	new name[30];
	new key[30];
	new data[128];

	get_user_name(id, name, charsmax(name));

	formatex(key, charsmax(key), "%s_def", name);
	formatex(data, charsmax(data), "%s", g_szKnife[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_but", name);
	formatex(data, charsmax(data), "%s", g_szButcher[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_bat", name);
	formatex(data, charsmax(data), "%s", g_szBayonet[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_kat", name);
	formatex(data, charsmax(data), "%s", g_szKatana[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_dag", name);
	formatex(data, charsmax(data), "%s", g_szDagger[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_player", name);
	nvault_set(g_iVault, key, g_szSkin[id]);
}

public LoadSkins(id) {
	new name[30];
	new key[30];

	get_user_name(id, name, charsmax(name));

	formatex(key, charsmax(key), "%s_def", name);
	nvault_get(g_iVault, key, g_szKnife[id], charsmax(g_szKnife[]));

	formatex(key, charsmax(key), "%s_but", name);
	nvault_get(g_iVault, key, g_szButcher[id], charsmax(g_szButcher[]));

	formatex(key, charsmax(key), "%s_bat", name);
	nvault_get(g_iVault, key, g_szBayonet[id], charsmax(g_szBayonet[]));

	formatex(key, charsmax(key), "%s_kat", name);
	nvault_get(g_iVault, key, g_szKatana[id], charsmax(g_szKatana[]));

	formatex(key, charsmax(key), "%s_dag", name);
	nvault_get(g_iVault, key, g_szDagger[id], charsmax(g_szDagger[]));

	formatex(key, charsmax(key), "%s_player", name);
	nvault_get(g_iVault, key, g_szSkin[id], charsmax(g_szSkin[]));

	if(g_szSkin[id][0])
	{
		cs_set_user_model(id, g_szSkin[id]);
	}
}
