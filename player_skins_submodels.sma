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

enum eWeapon{
	eModel[64],
	eSubmodel
}

new g_iKnifeID[MAX_PLAYERS];

new g_iKnife[MAX_PLAYERS][eWeapon];
new g_iButcher[MAX_PLAYERS][eWeapon];
new g_iBayonet[MAX_PLAYERS][eWeapon];
new g_iDagger[MAX_PLAYERS][eWeapon];
new g_iKatana[MAX_PLAYERS][eWeapon];
new g_iUsp[MAX_PLAYERS][eWeapon];
new g_szSkin[MAX_PLAYERS][64];

new bool:g_bHideKnife[MAX_PLAYERS];
new bool:g_bHideUsp[MAX_PLAYERS];

new g_iVault;

public plugin_init()
{
	//RegisterHam(Ham_Item_Deploy, "weapon_knife", "ItemDeployPost", 1);
	//RegisterHam(Ham_Item_Deploy, "weapon_usp", "ItemDeployPost", 1);

	register_event("ResetHUD", "ResetModel_Hook", "b");

	g_iVault = nvault_open("player_skins5");
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
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iKnife[id][eModel], charsmax(g_iKnife[][eModel]), "%s", model);
	g_iKnife[id][eSubmodel] = submodel;

	SaveSkins(id, "knife", model, submodel);
}

public set_user_butcher_native(numParams)
{
	new id = get_param(1);
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iButcher[id][eModel], charsmax(g_iButcher[][eModel]), "%s", model);
	g_iButcher[id][eSubmodel] = submodel;

	SaveSkins(id, "butcher", model, submodel);
}

public set_user_bayonet_native(numParams)
{
	new id = get_param(1);
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iBayonet[id][eModel], charsmax(g_iBayonet[][eModel]), "%s", model);
	g_iBayonet[id][eSubmodel] = submodel;

	SaveSkins(id, "bayonet", model, submodel);
}

public set_user_dagger_native(numParams)
{
	new id = get_param(1);
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iDagger[id][eModel], charsmax(g_iDagger[][eModel]), "%s", model);
	g_iDagger[id][eSubmodel] = submodel;

	SaveSkins(id, "dagger", model, submodel);
}

public set_user_katana_native(numParams)
{
	new id = get_param(1);
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iKatana[id][eModel], charsmax(g_iKatana[][eModel]), "%s", model);
	g_iKatana[id][eSubmodel] = submodel;

	SaveSkins(id, "katana", model, submodel);
}

public set_user_usp_native(numParams)
{
	new id = get_param(1);
	new model[128];
	get_string(2, model, charsmax(model));
	new submodel = get_param(3);

	formatex(g_iUsp[id][eModel], charsmax(g_iUsp[][eModel]), "%s", model);
	g_iUsp[id][eSubmodel] = submodel;

	SaveSkins(id, "usp", model, submodel);
}

public set_user_player_skin_native(numParams)
{
	new id = get_param(1);
	new model[64];
	get_string(2, model, charsmax(model));

	format(g_szSkin[id], charsmax(g_szSkin[]), model);
	SaveSkins(id, "player", model, -1);
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
		
		SetSkinUSP(iPlayer);

		return HAM_IGNORED;
	}

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
	SetWeaponModel(id, g_iUsp);
}

public SetSkinKnife(id)
{
	new wpn = get_user_weapon(id);
	if(wpn != CSW_KNIFE)
		return;

	switch (g_iKnifeID[id])
	{
		case 0: SetWeaponModel(id, g_iKnife);
		case 1: SetWeaponModel(id, g_iButcher);
		case 2: SetWeaponModel(id, g_iBayonet);
		case 3: SetWeaponModel(id, g_iDagger);
		case 4: SetWeaponModel(id, g_iKatana);
	}

}

public SetWeaponModel(iPlayer, item[MAX_PLAYERS][eWeapon])
{
	cs_set_viewmodel_body(iPlayer, item[iPlayer][eSubmodel]); 
	set_pev(iPlayer, pev_viewmodel2, item[iPlayer][eModel]); 
	set_pev(iPlayer, pev_body, item[iPlayer][eSubmodel]);
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

public LoadSkins(id) {
	new name[32], key[64], data[128];
	get_user_name(id, name, charsmax(name));
	 
	LoadSkin(id, name, "knife", g_iKnife);
	LoadSkin(id, name, "butcher", g_iButcher);
	LoadSkin(id, name, "bayonet", g_iBayonet);
	LoadSkin(id, name, "dagger", g_iDagger);
	LoadSkin(id, name, "katana", g_iKatana);
	LoadSkin(id, name, "usp", g_iUsp);

	LoadSkin(id, name, "katana", g_iKnife);

	formatex(key, charsmax(key), "%s_player_model", name);
	if (nvault_get(g_iVault, key, data, charsmax(data))) {
		formatex(g_szSkin[id], charsmax(g_szSkin[]), "%s", data);
	}
}

public LoadSkin(id, name[], weapon[], item[MAX_PLAYERS][eWeapon])
{	
	new key[64], data[64];

	formatex(key, charsmax(key), "%s_%s_model", name, weapon);
	if (nvault_get(g_iVault, key, data, charsmax(data))) {
		formatex(item[id][eModel], charsmax(item[][eModel]), "%s", data);
	}

	// Load submodel
	formatex(key, charsmax(key), "%s_%s_submodel", name, weapon);
	if (nvault_get(g_iVault, key, data, charsmax(data))) {
		item[id][eSubmodel] = str_to_num(data);
	}
}

public SaveSkins(id, const weapon[], const model[], submodel) {
	new name[32], key[64], data[64];

	get_user_name(id, name, charsmax(name));

	// Save model
	formatex(key, charsmax(key), "%s_%s_model", name, weapon);
	nvault_set(g_iVault, key, model);

	if(submodel < 0 ) return;
	// Save submodel
	formatex(key, charsmax(key), "%s_%s_submodel", name, weapon);
	formatex(data, charsmax(data), "%d", submodel);
	nvault_set(g_iVault, key, data);
}
