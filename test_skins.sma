#include <amxmodx>
#include <cstrike>
#include <nvault>
#include <fakemeta_util>
#include <hamsandwich>

//Linux diff
const XO_WEAPON = 4

// CBasePlayerItem
const m_pPlayer = 41 // CBasePlayer *

native cs_set_viewmodel_body(iPlayer, iValue);
native cs_get_viewmodel_body(iPlayer);

new submodel[33];
new submodel2[33];

public plugin_init()
{
	register_clcmd("say", "hook_say");
	register_event("CurWeapon","Changeweapon_Hook","be","1=1");
}

public plugin_precache()
{
	precache_model("models/v_def.mdl");
	precache_model("models/v_usp2.mdl");
}

public client_putinserver(id)
{
	submodel[id] = 0;
	submodel2[id] = 0;
}

public hook_say(id)
{
	new message[192];
   
	read_args (message, 191)
	remove_quotes (message)
	
	if(message[0] == '!')
	{
		submodel[id] = str_to_num(message[1]);
		client_print(id, print_console, "Setting viewmodel %d", submodel[id]);
	}
	if(message[0] == '#')
	{
		submodel2[id] = str_to_num(message[1]);
		client_print(id, print_console, "Setting viewmodel2 %d", submodel2[id]);
		
	}
   
}

public Changeweapon_Hook(id){
	new model[32];

	pev(id,pev_viewmodel2, model, 31);
	new wpn_id = get_user_weapon(id);

	if(wpn_id == CSW_KNIFE)
	{
		cs_set_viewmodel_body(id, submodel[id]);
		set_task(0.1, "SetKnife", id); //this task is needed
	}
	if(wpn_id == CSW_USP)
	{
		cs_set_viewmodel_body(id, submodel2[id]);
		set_task(0.1, "SetPremium", id); //this task is needed
	}
	
	return PLUGIN_HANDLED;
}

public SetKnife(id)
{
	set_pev(id, pev_viewmodel2, "models/v_def.mdl");
	client_print(id, print_console, "Setting skin models/v_def.mdl");
}

public SetPremium(id)
{
	set_pev(id, pev_viewmodel2, "models/v_usp2.mdl");
	client_print(id, print_console, "Setting skin models/v_usp.mdl");
}