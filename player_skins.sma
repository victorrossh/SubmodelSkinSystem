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

enum enumKnife
{
	eKnife = 0,
	eButcher,
	eBayonet,
	eDagger,
	eKatana
};

new g_iKnifeID[MAX_PLAYERS];

new g_szDefaultKnife[128];
new g_szDefaultButcher[128];
new g_szDefaultBayonet[128];
new g_szDefaultDagger[128];
new g_szDefaultKatana[128];
new g_szDefaultUsp[128];

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
	register_event("ResetHUD", "ResetModel_Hook", "b");

	RegisterHam(Ham_Item_Deploy, "weapon_knife", "HamF_Item_Deploy_Post", 1);
	RegisterHam(Ham_Item_Deploy, "weapon_usp", "HamF_Item_Deploy_Post", 1);

	g_iVault = nvault_open("player_skins");

	formatex(g_szDefaultKnife, charsmax(g_szDefaultKnife), "models/v_knife.mdl");
	formatex(g_szDefaultUsp, charsmax(g_szDefaultUsp), "models/v_usp.mdl");
}

public plugin_natives()
{
	register_native("set_user_knife_id", "set_user_knife_id_native");

	register_native("set_default_knife", 	"set_default_knife_native");
	register_native("set_default_butcher", 	"set_default_butcher_native");
	register_native("set_default_bayonet", 	"set_default_bayonet_native");
	register_native("set_default_dagger", 	"set_default_dagger_native");
	register_native("set_default_katana", 	"set_default_katana_native");
	register_native("set_default_usp", 		"set_default_usp_native");

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

public set_default_knife_native(numParams)
{
	get_string(1, g_szDefaultKnife, charsmax(g_szDefaultKnife));
}

public set_default_butcher_native(numParams)
{
	get_string(1, g_szDefaultButcher, charsmax(g_szDefaultButcher));
}

public set_default_bayonet_native(numParams)
{
	get_string(1, g_szDefaultBayonet, charsmax(g_szDefaultBayonet));
}

public set_default_dagger_native(numParams)
{
	get_string(1, g_szDefaultDagger, charsmax(g_szDefaultDagger));
}

public set_default_katana_native(numParams)
{
	get_string(1, g_szDefaultKatana, charsmax(g_szDefaultKatana));
}

public set_default_usp_native(numParams)
{
	get_string(1, g_szDefaultUsp, charsmax(g_szDefaultUsp));
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

public HamF_Item_Deploy_Post(iEnt)
{
	static iPlayer;	
	iPlayer = get_pdata_cbase(iEnt, m_pPlayer, XO_WEAPON);

	new iWpn = WEAPON_ENT(iEnt);
	
	if(iWpn == CSW_USP && g_bHideUsp[iPlayer])
	{
		set_pev(iPlayer, pev_viewmodel2, "");
		return HAM_IGNORED;
	}

	if(iWpn == CSW_KNIFE && g_bHideKnife[iPlayer]) 
	{
		set_pev(iPlayer, pev_viewmodel2, "");
		return HAM_IGNORED;
	}

	if(iWpn == CSW_USP)
	{
		if(strlen(g_szUsp[iPlayer]))
			set_pev(iPlayer, pev_viewmodel2, g_szUsp[iPlayer]);
		else
			set_pev(iPlayer, pev_viewmodel2, g_szDefaultUsp);

		return HAM_IGNORED;
	}

	if(iWpn != CSW_KNIFE) return HAM_IGNORED;
	
	static model[128];

	switch(g_iKnifeID[iPlayer])
	{
		case eKnife:
			formatex(model, charsmax(model), strlen(g_szKnife[iPlayer])?g_szKnife[iPlayer]:g_szDefaultKnife);
		case eButcher:
			formatex(model, charsmax(model), strlen(g_szButcher[iPlayer])?g_szButcher[iPlayer]:g_szDefaultButcher);
		case eBayonet:
			formatex(model, charsmax(model), strlen(g_szBayonet[iPlayer])?g_szBayonet[iPlayer]:g_szDefaultBayonet);
		case eDagger:
			formatex(model, charsmax(model), strlen(g_szDagger[iPlayer])?g_szDagger[iPlayer]:g_szDefaultDagger);
		case eKatana:
			formatex(model, charsmax(model), strlen(g_szKatana[iPlayer])?g_szKatana[iPlayer]:g_szDefaultKatana);
	}
	
	set_pev(iPlayer, pev_viewmodel2, model);

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
