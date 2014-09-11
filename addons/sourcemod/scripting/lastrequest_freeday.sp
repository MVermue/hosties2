/*
 * SourceMod Hosties Project
 * by: Bara
 *
 * This file is part of the SM Hosties project.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <cstrike>
#include <hosties>
#include <hosties_logging>
#include <lastrequest>
#include <multicolors>
#include <autoexecconfig>

#pragma semicolon 1

#define FREEDAY_VERSION "1.0.0"

// This global will store the index number for the new Last Request
new g_LREntryNum;

new g_iFreedayMethod = -1;
new g_BeamSprite = -1;
new g_HaloSprite = -1;

new Handle:g_hFreedayMethod = INVALID_HANDLE;
new Handle:g_hBeaconColor = INVALID_HANDLE;
new Handle:g_hPlayerColor = INVALID_HANDLE;

new Handle:g_hBeaconTimer[MAXPLAYERS +1 ] = {INVALID_HANDLE,...};

new bool:g_bThisRound[MAXPLAYERS + 1] = {false, ...};

new String:g_sLR_Name[64];
new String:g_sPlayerColor[16];
new String:g_sBeaconColor[16];

public Plugin:myinfo =
{
	name = "Last Request: Freeday",
	author = "Bara",
	description = "",
	version = FREEDAY_VERSION,
	url = "www.bara.in"
};

public OnPluginStart()
{
	Hosties_CheckGame();
	
	// Load translations
	LoadTranslations("common.phrases");
	LoadTranslations("hosties.phrases");
	
	// Load the name in default server language
	Format(g_sLR_Name, sizeof(g_sLR_Name), "%T", "LR Freeday", LANG_SERVER);
	
	AutoExecConfig_SetFile("lastrequest_freeday");
	AutoExecConfig_SetCreateFile(true);

	// Create any cvars you need here
	g_hFreedayMethod = AutoExecConfig_CreateConVar("sm_freeday_method", "3","What should the player get out in time? 0 - nothing, 1 - playercolor, 2 - beacon, 3 - both", _, true, 0.0, true, 3.0);
	g_iFreedayMethod = 1;
	g_hBeaconColor = AutoExecConfig_CreateConVar("sm_freeday_beacon_color", "255,0,0", "In what color should player to be colored?");
	Format(g_sBeaconColor, sizeof(g_sBeaconColor), "255,0,0");
	g_hPlayerColor = AutoExecConfig_CreateConVar("sm_freeday_player_color", "255,255,0", "In what color should player to be colored?");
	Format(g_sBeaconColor, sizeof(g_sBeaconColor), "255,255,0");

	HookConVarChange(g_hFreedayMethod, ConVarChanged);
	HookConVarChange(g_hBeaconColor, ConVarChanged);
	HookConVarChange(g_hPlayerColor, ConVarChanged);

	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
}

public OnAllPluginsLoaded()
{
	Hosties_IsLoaded();
}

public OnConfigsExecuted()
{
	static bool:bFreedayAdded = false;
	if (!bFreedayAdded)
	{
		g_LREntryNum = AddLastRequestToList(Freeday_Start, Freeday_Stop, g_sLR_Name, false);
		bFreedayAdded = true;
	}	
}

public OnClientDisconnect(client)
{
	g_bThisRound[client] = false;

	if(g_hBeaconTimer[client])
	{
		KillTimer(g_hBeaconTimer[client]);
		g_hBeaconTimer[client] = INVALID_HANDLE;
	}
}

public ConVarChanged(Handle:cvar, const String:oldValue[], const String:newValue[])
{
	if (cvar == g_hFreedayMethod)
	{
		g_iFreedayMethod = StringToInt(newValue);
	}
	else if (cvar == g_hBeaconColor)
	{
		Format(g_sBeaconColor, sizeof(g_sBeaconColor), newValue);
	}
	else if (cvar == g_hPlayerColor)
	{
		Format(g_sPlayerColor, sizeof(g_sPlayerColor), newValue);
	}
}

// The plugin should remove any LRs it loads when it's unloaded
public OnPluginEnd()
{
	RemoveLastRequestFromList(Freeday_Start, Freeday_Stop, g_sLR_Name);
}

public OnMapStart()
{
	if (GetEngineVersion() == Engine_CSS)
	{
		g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt");
		g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	}
	else if (GetEngineVersion() == Engine_CSGO)
	{
		g_BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		g_HaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	}
}

public Freeday_Start(Handle:LR_Array, iIndexInArray)
{
	new This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType);
	if (This_LR_Type == g_LREntryNum)
	{		
		new LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
		
		// check datapack value
		new LR_Pack_Value = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);	
		switch (LR_Pack_Value)
		{
			case -1:
			{
				PrintToServer("no info included");
			}
		}
		
		// check if this the last player
		new count;
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
			{
				count++;
			}
		}
		if(count != 1)
		{
			CPrintToChat(LR_Player_Prisoner, CHAT_BANNER, "LR Freeday T Count");
			return;
		}

		ForcePlayerSuicide(LR_Player_Prisoner);
		g_bThisRound[LR_Player_Prisoner] = true;
		
		CPrintToChatAll(CHAT_BANNER, "LR Freeday Prepare", LR_Player_Prisoner);
		Log_Info("hosties", "freeday", _, CHAT_BANNER, "LR Freeday Prepare", LR_Player_Prisoner);
	}
	return;
}

public Freeday_Stop(This_LR_Type, LR_Player_Prisoner, LR_Player_Guard)
{
	if (This_LR_Type == g_LREntryNum)
	{
		if (IsClientInGame(LR_Player_Prisoner))
		{
			// freeday round when player dies
		}
	}
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsClientInGame(client) && g_bThisRound[client])
	{
		if(g_iFreedayMethod == 1 || g_iFreedayMethod == 3)
		{
			decl String:sBuffer[3][6];
			ExplodeString(g_sPlayerColor, ",", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));

			new iRed = StringToInt(sBuffer[0]);
			new iGreen = StringToInt(sBuffer[1]);
			new iBlue = StringToInt(sBuffer[2]);

			SetEntityRenderColor(client, iRed, iGreen, iBlue);
			SetEntityRenderMode(client, RENDER_NORMAL);
		}

		if(g_iFreedayMethod == 2 || g_iFreedayMethod == 3)
		{
			g_hBeaconTimer[client] = CreateTimer(5.0, Timer_StartBeacon, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsClientInGame(client) && g_bThisRound[client])
	{
		g_bThisRound[client] = false;

		CPrintToChatAll(CHAT_BANNER, "LR Freeday End", client);
		Log_Info("hosties", "freeday", _, CHAT_BANNER, "LR Freeday End", client);
	}
}

public Action:Timer_StartBeacon(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);

	if(!IsPlayerAlive(client))
	{
		if(g_hBeaconTimer[client] != INVALID_HANDLE)
		{
			g_hBeaconTimer[client] = INVALID_HANDLE;
		}
		g_bThisRound[client] = false;
		return Plugin_Stop;
	}

	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		decl String:sBuffer[3][6];
		ExplodeString(g_sBeaconColor, ",", sBuffer, sizeof(sBuffer), sizeof(sBuffer[]));

		new iColor[4];
		iColor[0] = StringToInt(sBuffer[0]);
		iColor[1] = StringToInt(sBuffer[1]);
		iColor[2] = StringToInt(sBuffer[2]);
		iColor[3] = 255;

		new Float:fOrigin[3];
		GetClientAbsOrigin(client, fOrigin);
		fOrigin[2] += 10;

		TE_SetupBeamRingPoint(fOrigin, 10.0, 375.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, iColor, 10, 0);
		TE_SendToAll();
	}

	return Plugin_Continue;
}
