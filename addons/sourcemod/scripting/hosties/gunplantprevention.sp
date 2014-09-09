//Code modified from https://forums.alliedmods.net/showpost.php?p=1966727

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <lastrequest>

new Handle:gH_Cvar_GunplantPreventionEnabled;
new Handle:gH_Cvar_GunplantPreventionTime;
new Handle:gH_Cvar_GunplantPunishment;
new Handle:gH_Cvar_AllowEmptyGunPlants;

new bool:gShadow_GunplantPreventionEnabled;
new Float:gShadow_GunplantPreventionTime;
new gShadow_GunplantPunishment;
new bool:gShadow_AllowEmptyGunPlants;

public GunPlantPrevention_OnPluginStart()
{
	gH_Cvar_GunplantPreventionEnabled = AutoExecConfig_CreateConVar("sm_hosties_gunplant_prevention_enabled", "1", "Enable gunplant prevention? 0 = disable, 1 = enable", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_GunplantPreventionEnabled = true;
	gH_Cvar_GunplantPreventionTime = AutoExecConfig_CreateConVar("sm_hosties_gunplant_prevention_time", "1.337", "Time to prevent a gun plant when a weapon is drop.", FCVAR_PLUGIN, true, 0.1, false);
	gShadow_GunplantPreventionTime = 1.337;
	gH_Cvar_AllowEmptyGunPlants = AutoExecConfig_CreateConVar("sm_hosties_gunplant_prevention_empty", "0", "Allow gunplanting with empty guns. 1 = allow, 1 = disallow", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gShadow_AllowEmptyGunPlants = false;
	gH_Cvar_GunplantPunishment = AutoExecConfig_CreateConVar("sm_hosties_gunplant_punishment", "1", "How to punish gunplanters? 0 = slay, 1 = remove weapon, 2 = both.", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	gShadow_GunplantPunishment = 1;
	
	HookConVarChange(gH_Cvar_GunplantPreventionEnabled, GunplantPrevention_CvarChanged);
	HookConVarChange(gH_Cvar_GunplantPreventionTime, GunplantPrevention_CvarChanged);
	HookConVarChange(gH_Cvar_AllowEmptyGunPlants, GunplantPrevention_CvarChanged);
	HookConVarChange(gH_Cvar_GunplantPunishment, GunplantPrevention_CvarChanged);
}

public Action:CS_OnCSWeaponDrop(client, weapon)
{
	if (gShadow_GunplantPreventionEnabled && IsClientInGame(client) && GetClientTeam(client) == CS_TEAM_CT)
	{
		if (gShadow_AllowEmptyGunPlants && (Weapon_GetPrimaryClip(weapon) == 0 && Weapon_GetSecondaryClip(weapon) == 0))
		{
			return;
		}
		new Handle:data = CreateDataPack();
		WritePackCell(data, client);
		WritePackCell(data, weapon);

		CreateTimer(gShadow_GunplantPreventionTime, Timer_GunPlantPrevention, data);
	}
}

public Action:Timer_GunPlantPrevention(Handle:timer, any:data)
{
	ResetPack(data);
	new original_owner = ReadPackCell(data);
	new weapon = ReadPackCell(data);
	
	if (!IsValidEdict(weapon) || !IsClientInGame(original_owner) || !IsPlayerAlive(original_owner))
		return Plugin_Stop;
		
	new new_owner = GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity");
	if (new_owner == -1 || original_owner == -1)
		return Plugin_Stop;
		
	if (IsClientInGame(new_owner) && GetClientTeam(new_owner) != GetClientTeam(original_owner) && !IsClientInLastRequest(original_owner))
	{
		// GUN PLANT! PANIC!
		switch (gShadow_GunplantPunishment)
		{
			case (0):
			{
				ForcePlayerSuicide(original_owner);
			}
			case (1):
			{
				AcceptEntityInput(weapon, "kill");
			}
			case (2):
			{
				AcceptEntityInput(weapon, "kill");
				ForcePlayerSuicide(original_owner);
			}
		}
	}
	return Plugin_Stop;
}

public GunplantPrevention_CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == gH_Cvar_GunplantPreventionEnabled)
	{
		gShadow_GunplantPreventionEnabled = bool:StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_GunplantPreventionTime)
	{
		gShadow_GunplantPreventionTime = StringToFloat(newValue);
	}
	else if (cvar == gH_Cvar_GunplantPunishment)
	{
		gShadow_GunplantPunishment = StringToInt(newValue);
	}
	else if (cvar == gH_Cvar_AllowEmptyGunPlants)
	{
		gShadow_AllowEmptyGunPlants = bool:StringToInt(newValue);
	}
}