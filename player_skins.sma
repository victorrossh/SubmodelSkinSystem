#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <fakemeta_util>

new g_szKnife[MAX_PLAYERS][64];
new g_szButcher[MAX_PLAYERS][64];
new g_szBayonet[MAX_PLAYERS][64];
new g_szDagger[MAX_PLAYERS][64];
new g_szKatana[MAX_PLAYERS][64];
new g_szUsp[MAX_PLAYERS][64];
new g_szSkin[MAX_PLAYERS][64];

new bool:g_bHideKnife[MAX_PLAYERS];
new bool:g_bHideUsp[MAX_PLAYERS];

new g_iVault;

public plugin_init()
{
	register_event("CurWeapon","Changeweapon_Hook","be","1=1");
	register_event("ResetHUD", "ResetModel_Hook", "b");

	g_iVault = nvault_open("player_skins2");
}

public plugin_natives()
{
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

public set_user_knife_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szKnife[id], charsmax(g_szKnife[]), skin);

	SaveSkins(id);
}

public set_user_butcher_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szButcher[id], charsmax(g_szButcher[]), skin);
	SaveSkins(id);
}

public set_user_bayonet_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szBayonet[id], charsmax(g_szBayonet[]), skin);
	SaveSkins(id);
}

public set_user_dagger_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szDagger[id], charsmax(g_szDagger[]), skin);
	SaveSkins(id);
}

public set_user_katana_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szKatana[id], charsmax(g_szKatana[]), skin);
	SaveSkins(id);
}

public set_user_usp_native(numParams)
{
	new id = get_param(1);
	new skin[64];
	get_string(2, skin, charsmax(skin));

	format(g_szUsp[id], charsmax(g_szUsp[]), skin);
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



//Checking the weapon the player switched to and if he's a vip it'll set a skin on that weapon if it's on the weapons list above
public Changeweapon_Hook(id){
	new model[32];

	pev(id,pev_viewmodel2, model, 31);
	new wpn_id = get_user_weapon(id);

	if(wpn_id == CSW_USP && g_bHideUsp[id])
	{
		set_pev(id,pev_viewmodel2, "");
		return PLUGIN_HANDLED;
	}
	if(wpn_id == CSW_KNIFE && g_bHideKnife[id])
	{
		set_pev(id,pev_viewmodel2, "");
		return PLUGIN_HANDLED;
	}

	if(wpn_id == CSW_USP && strlen(g_szUsp[id]))
		set_pev(id,pev_viewmodel2, g_szUsp[id]);
	if(equali(model,"models/llg/v_knife.mdl") && strlen(g_szKnife[id]))
		set_pev(id,pev_viewmodel2, g_szKnife[id]);
	if(equali(model,"models/llg/v_butcher.mdl") && strlen(g_szButcher[id]))
		set_pev(id,pev_viewmodel2, g_szButcher[id]);
	if(equali(model,"models/llg/v_vip_tigertooth.mdl") && strlen(g_szBayonet[id]))
		set_pev(id,pev_viewmodel2, g_szBayonet[id]);
	if(equali(model,"models/llg/v_premium.mdl") && strlen(g_szDagger[id]))
		set_pev(id,pev_viewmodel2, g_szDagger[id]);
	if(equali(model,"models/llg/v_katana.mdl") && strlen(g_szKatana[id]))
		set_pev(id,pev_viewmodel2, g_szKatana[id]);
	
	return PLUGIN_HANDLED;
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
}

public SaveSkins(id){
	new name[30];
	new keys[7][30];

	get_user_name( id , name , charsmax( name ) );

	formatex(keys[0], charsmax(keys[]), "%s", name);

	for (new i = 1; i < 7; i++) {
		formatex(keys[i], charsmax(keys[]), "%s+%d", name, i);
	}
	
	nvault_set( g_iVault , keys[0] , g_szKnife[id]);
	nvault_set( g_iVault , keys[1] , g_szButcher[id]);
	nvault_set( g_iVault , keys[2] , g_szUsp[id]);
	nvault_set( g_iVault , keys[3] , g_szSkin[id]);
	nvault_set( g_iVault , keys[4] , g_szBayonet[id]);
	nvault_set( g_iVault , keys[5] , g_szDagger[id]);
	nvault_set( g_iVault , keys[6] , g_szKatana[id]);
}
//loads the skins
public LoadSkins(id){

	new name[30];
	new keys[7][30];

	get_user_name( id , name , charsmax( name ) );

	formatex(keys[0], charsmax(keys[]), "%s", name);

	for (new i = 1; i < 7; i++) {
    	formatex(keys[i], charsmax(keys[]), "%s+%d", name, i);
	}

	nvault_get( g_iVault , keys[0] , g_szKnife[id] , 127 );  
	nvault_get( g_iVault , keys[1] , g_szButcher[id] , 127 );
	nvault_get( g_iVault , keys[2] , g_szUsp[id] , 127 );
	nvault_get( g_iVault , keys[3] , g_szSkin[id] , 127 );
	nvault_get( g_iVault , keys[4] , g_szBayonet[id] , 127 );
	nvault_get( g_iVault , keys[5] , g_szDagger[id] , 127 );
	nvault_get( g_iVault , keys[6] , g_szKatana[id] , 127 );

}