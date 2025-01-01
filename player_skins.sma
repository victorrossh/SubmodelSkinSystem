#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <fakemeta_util>
#include <hamsandwich>


const m_iId = 43 // int
#define WEAPON_ENT(%0) (get_pdata_int(%0, m_iId, XO_WEAPON))

//Linux diff
const XO_WEAPON = 4

// CBasePlayerItem
const m_pPlayer = 41 // CBasePlayer *

native cs_set_viewmodel_body(iPlayer, iValue);
native cs_get_viewmodel_body(iPlayer);
forward change_skin(iPlayer, iEnt);

new g_iKnifeID[MAX_PLAYERS];

new g_iKnife[MAX_PLAYERS];
new g_iButcher[MAX_PLAYERS];
new g_iBayonet[MAX_PLAYERS];
new g_iDagger[MAX_PLAYERS];
new g_iKatana[MAX_PLAYERS];
new g_iUsp[MAX_PLAYERS];
new g_szSkin[MAX_PLAYERS][64];

new bool:g_bHideKnife[MAX_PLAYERS];
new bool:g_bHideUsp[MAX_PLAYERS];

new g_iVault;

new g_szKnifeModel[][] = { "models/llg3/v_def.mdl", "models/llg3/v_butcher.mdl", "models/llg3/v_vip.mdl", "models/llg3/v_premium.mdl" };
new g_szUspModel[] = "models/llg3/v_usp.mdl";

public plugin_init()
{
	//RegisterHam(Ham_Item_Deploy, "weapon_knife", "ItemDeployPost", 1);
	//RegisterHam(Ham_Item_Deploy, "weapon_usp", "ItemDeployPost", 1);

	register_event("ResetHUD", "ResetModel_Hook", "b");

	g_iVault = nvault_open("player_skins4");
}

public plugin_precache()
{
	for (new i; i < sizeof g_szKnifeModel; i++)
	{
		precache_model(g_szKnifeModel[i]);
	}

	precache_model(g_szUspModel);
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
	new submodel = get_param(2);

	g_iKnife[id] = submodel;

	SaveSkins(id);
}

public set_user_butcher_native(numParams)
{
	new id = get_param(1);
	new submodel = get_param(2);

	g_iButcher[id] = submodel;

	SaveSkins(id);
}

public set_user_bayonet_native(numParams)
{
	new id = get_param(1);
	new submodel = get_param(2);

	g_iBayonet[id] = submodel;

	SaveSkins(id);
}

public set_user_dagger_native(numParams)
{
	new id = get_param(1);
	new submodel = get_param(2);

	g_iDagger[id] = submodel;

	SaveSkins(id);
}

public set_user_katana_native(numParams)
{
	new id = get_param(1);
	new submodel = get_param(2);

	g_iKatana[id] = submodel;

	SaveSkins(id);
}

public set_user_usp_native(numParams)
{
	new id = get_param(1);
	new submodel = get_param(2);

	g_iUsp[id] = submodel;

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

public change_skin(iPlayer, iEnt)
{
	new iWpn = WEAPON_ENT(iEnt);

	if(iWpn == CSW_USP && g_bHideUsp[iPlayer]) return HAM_IGNORED;

	if(iWpn == CSW_KNIFE && g_bHideKnife[iPlayer]) return HAM_IGNORED;

	if(iWpn == CSW_USP)
	{
		cs_set_viewmodel_body(iPlayer, g_iUsp[iPlayer]);
		SetSkinUSP(iPlayer);

		return HAM_IGNORED;
	}

	if(g_iKnifeID[iPlayer] == 0)
		cs_set_viewmodel_body(iPlayer, g_iKnife[iPlayer]);
	if(g_iKnifeID[iPlayer] == 1)
		cs_set_viewmodel_body(iPlayer, g_iButcher[iPlayer]);
	if(g_iKnifeID[iPlayer] == 2)
		cs_set_viewmodel_body(iPlayer, g_iBayonet[iPlayer]);
	if(g_iKnifeID[iPlayer] == 3)
		cs_set_viewmodel_body(iPlayer, g_iDagger[iPlayer]);
	if(g_iKnifeID[iPlayer] == 4)
		cs_set_viewmodel_body(iPlayer, g_iKatana[iPlayer]);

	SetSkinKnife(iPlayer);

	return HAM_IGNORED;
}

/*
public ItemDeployPost(iWeapon)
{	
	static id;
	id = get_pdata_cbase(iWeapon, m_pPlayer, XO_WEAPON);

	new iWpn = WEAPON_ENT(iWeapon);

	if(!is_user_alive(id)) return HAM_IGNORED;
		
	if(iWpn != CSW_USP && iWpn != CSW_KNIFE) return HAM_IGNORED;
		
	if(iWpn == CSW_USP && g_bHideUsp[id]) return HAM_IGNORED;

	if(iWpn == CSW_KNIFE && g_bHideKnife[id]) return HAM_IGNORED;
	
	if(iWpn == CSW_USP)
	{
		cs_set_viewmodel_body(id, g_iUsp[id]);

		set_task(0.01, "SetSkinUSP", id);

		return HAM_IGNORED;
	}

	if(g_iKnifeID[id] == 0)
		cs_set_viewmodel_body(id, g_iKnife[id]);
	if(g_iKnifeID[id] == 1)
		cs_set_viewmodel_body(id, g_iButcher[id]);
	if(g_iKnifeID[id] == 2)
		cs_set_viewmodel_body(id, g_iBayonet[id]);
	if(g_iKnifeID[id] == 3)
		cs_set_viewmodel_body(id, g_iDagger[id]);
	if(g_iKnifeID[id] == 4)
		cs_set_viewmodel_body(id, g_iKatana[id]);

	set_task(0.01, "SetSkinKnife", id);

	return HAM_IGNORED;
}
*/
public SetSkinUSP(id)
{
	new wpn = get_user_weapon(id);
	if(wpn != CSW_USP)
		return;

	//server_print("Set model: %s", g_szUspModel);
	set_pev(id, pev_viewmodel2, g_szUspModel);
	set_pev(id, pev_body, g_iUsp[id]);
	
}

public SetSkinKnife(id)
{
	if(g_iKnifeID[id] >= sizeof g_szKnifeModel)
		g_iKnifeID[id] = 0;

	new wpn = get_user_weapon(id);
	if(wpn != CSW_KNIFE)
		return;

	set_pev(id, pev_viewmodel2, g_szKnifeModel[g_iKnifeID[id]]);
	if(g_iKnifeID[id] == 0)
		set_pev(id, pev_body, g_iKnife[id]);
	if(g_iKnifeID[id] == 1)
		set_pev(id, pev_body, g_iButcher[id]);
	if(g_iKnifeID[id] == 2)
		set_pev(id, pev_body, g_iBayonet[id]);
	if(g_iKnifeID[id] == 3)
		set_pev(id, pev_body, g_iDagger[id]);
	if(g_iKnifeID[id] == 4)
		set_pev(id, pev_body, g_iKatana[id]);

	//server_print("Set model: %s", g_szKnifeModel[g_iKnifeID[id]]);
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
	formatex(key, charsmax(key), "%s", name);

	// Format all integers into a single string
	formatex(data, charsmax(data), "%d %d %d %d %d %d", 
		g_iKnife[id], g_iButcher[id], g_iUsp[id], 
		g_iBayonet[id], g_iDagger[id], g_iKatana[id]);

	nvault_set(g_iVault, key, data);

	formatex(key, charsmax(key), "%s_player", name);
	
	nvault_set(g_iVault, key, g_szSkin[id]);
}

public LoadSkins(id) {
	new name[30];
	new key[30];
	new data[128];
	new temp[10];
	new remaining[128];

	get_user_name(id, name, charsmax(name));
	formatex(key, charsmax(key), "%s", name);

	// Load the single formatted string from nvault
	if (nvault_get(g_iVault, key, data, charsmax(data))) {
		// Parse each integer from the loaded string using strtok
		strtok(data, temp, charsmax(temp), remaining, charsmax(remaining), ' ');
		g_iKnife[id] = str_to_num(temp);

		strtok(remaining, temp, charsmax(temp), data, charsmax(data), ' ');
		g_iButcher[id] = str_to_num(temp);

		strtok(data, temp, charsmax(temp), remaining, charsmax(remaining), ' ');
		g_iUsp[id] = str_to_num(temp);

		strtok(data, temp, charsmax(temp), remaining, charsmax(remaining), ' ');
		g_iBayonet[id] = str_to_num(temp);

		strtok(remaining, temp, charsmax(temp), data, charsmax(data), ' ');
		g_iDagger[id] = str_to_num(temp);

		strtok(data, temp, charsmax(temp), remaining, charsmax(remaining), ' ');
		g_iKatana[id] = str_to_num(temp);
	}

	// Retrieve additional skin data as needed
	formatex(key, charsmax(key), "%s_player", name);
	nvault_get(g_iVault, key, g_szSkin, charsmax(g_szSkin[]));
}
