
#include <sourcemod>
#include <sdktools>
#include <menus>
#include <cstrike>
#include <smlib>
#include <hosties>
#include <lastrequest>
#include <autoexecconfig>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0.9"

new g_LREntryNum;
new g_This_LR_Type;
new g_LR_Player_Prisoner;
new g_LR_Player_Guard;

new String:g_sLR_Name[64];

new Handle:g_hHealth = INVALID_HANDLE;
new Handle:g_hSpeed = INVALID_HANDLE;
new Handle:g_hAmmo = INVALID_HANDLE;

// menu handler
new Handle:Menu = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "Last Request: Hp Fight",
	author = "EGood & Bara",
	description = "hp and speed fights",
	version = PLUGIN_VERSION,
	url = "http://www.GameX.co.il"
};

public OnPluginStart()
{
	Hosties_CheckGame();

	Hosties_IsLoaded();
	
	// Load translations
	LoadTranslations("hpfight.phrases");
	
	// Name of the LR
	Format(g_sLR_Name, sizeof(g_sLR_Name), "%T", "HP Fight", LANG_SERVER);

	AutoExecConfig_SetFile("lastrequest_hpfight");
	AutoExecConfig_SetCreateFile(true);
	
	// ConVars
	g_hHealth =	AutoExecConfig_CreateConVar("lastrequest_hpfight_health", "1000", "How much health?");
	g_hAmmo =	AutoExecConfig_CreateConVar("lastrequest_hpfight_ammo", "999", "How much ammo?");
	g_hSpeed =	AutoExecConfig_CreateConVar("lastrequest_hpfight_speed", "3.0", "How much speed?");
	
	AutoExecConfig_CleanFile();
	AutoExecConfig_ExecuteFile();
	
	// menu

	decl String:sBuffer1[16], String:sBuffer2[16], String:sBuffer3[16], String:sBuffer4[16], String:sBuffer5[16], String:sBuffer6[16];

	Format(sBuffer1, sizeof(sBuffer1), "%t", "M4A1 Fight", "M4A1");
	Format(sBuffer2, sizeof(sBuffer2), "%t", "AK47 Fight", "AK47");
	if(GetEngineVersion() == Engine_CSS)
	{
		Format(sBuffer3, sizeof(sBuffer3), "%t", "MP5 Fight", "MP5");
	}
	else if(GetEngineVersion() == Engine_CSGO)
	{
		Format(sBuffer3, sizeof(sBuffer3), "%t", "Bizon Fight", "Bizon");
	}
	Format(sBuffer4, sizeof(sBuffer4), "%t", "Galil Fight", "Galil");
	Format(sBuffer5, sizeof(sBuffer5), "%t", "P90 Fight", "P90");
	Format(sBuffer6, sizeof(sBuffer6), "%t", "MachineGun Fight", "MachineGun");

	Menu = CreateMenu(MenuHandler);
	SetMenuTitle(Menu, "HP Fights");
	AddMenuItem(Menu, "M1", sBuffer1);
	AddMenuItem(Menu, "M2", sBuffer2);
	if(GetEngineVersion() == Engine_CSS)
	{
		AddMenuItem(Menu, "M3", sBuffer3);
	}
	else if(GetEngineVersion() == Engine_CSGO)
	{
		AddMenuItem(Menu, "M3", sBuffer3);
	}
	AddMenuItem(Menu, "M4", sBuffer4);
	AddMenuItem(Menu, "M5", sBuffer5);
	AddMenuItem(Menu, "M6", sBuffer6);
	SetMenuExitButton(Menu, true);
}

public OnConfigsExecuted()
{
	static bool:bAddedLRHPFight = false;
	if (!bAddedLRHPFight)
	{
		g_LREntryNum = AddLastRequestToList(LR_Start, LR_Stop, g_sLR_Name, false);
		bAddedLRHPFight = true;
	}   
}

public MenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0) // M4A1
		{
			LR_AfterMenu(0);
		}
		if(param2 == 1) // Ak47
		{
			LR_AfterMenu(1);
		}
		if(param2 == 2) // CSS: MP5 or CSGO: Bizon
		{
			LR_AfterMenu(2);
		}
		if(param2 == 3) // Galil
		{
			LR_AfterMenu(3);
		}
		if(param2 == 4) // P90
		{
			LR_AfterMenu(4);
		}
		if(param2 == 5) // M249
		{
			LR_AfterMenu(5);
		}
	}
}

// The plugin should remove any LRs it loads when it's unloaded
public OnPluginEnd()
{
	RemoveLastRequestFromList(LR_Start, LR_Stop, "HP Fight");
}

public LR_Start(Handle:LR_Array, iIndexInArray)
{
	g_This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType);
	if (g_This_LR_Type == g_LREntryNum)
	{
		g_LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
		g_LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
		
		new LR_Pack_Value = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);   
		switch (LR_Pack_Value)
		{
			case -1:
			{
				PrintToServer("no info included");
			}
		}
		DisplayMenu(Menu, g_LR_Player_Prisoner, 0);
	}
}


public LR_Stop(Type, Prisoner, Guard)
{
	if (Type == g_LREntryNum)
	{
		if (IsClientInGame(Prisoner))
		{
			if (IsPlayerAlive(Prisoner))
			{
				SetEntityGravity(Prisoner, 1.0);
				SetEntityHealth(Prisoner, 100);
				StripAllWeapons(Prisoner);
				GiveItem(Prisoner, "weapon_knife", CS_SLOT_KNIFE);
				PrintToChatAll(CHAT_BANNER, "HF Win", Prisoner);
			}
		}
		if (IsClientInGame(Guard))
		{
			if (IsPlayerAlive(Guard))
			{
				SetEntityGravity(Guard, 1.0);
				SetEntityHealth(Guard, 100);
				StripAllWeapons(Guard);
				GiveItem(Guard, "weapon_knife", CS_SLOT_KNIFE);
				PrintToChatAll(CHAT_BANNER, "HF Win", Guard);
			}
		}
	}
}

public LR_AfterMenu(weapon)
{
	StripAllWeapons(g_LR_Player_Prisoner);
	StripAllWeapons(g_LR_Player_Guard);
	
	SetEntData(g_LR_Player_Prisoner, FindSendPropOffs("CBasePlayer", "m_iHealth"), GetConVarInt(g_hHealth));
	SetEntData(g_LR_Player_Guard, FindSendPropOffs("CBasePlayer", "m_iHealth"), GetConVarInt(g_hHealth));
	
	new wep1;
	new wep2;
	
	switch(weapon)
	{
		case 0:
		{
			wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_m4a1");
			wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_m4a1");
			
			PrintToChatAll(CHAT_BANNER, "LR M4A1 Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
		}
		case 1:
		{
			wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_ak47");
			wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_ak47");
			
			PrintToChatAll(CHAT_BANNER, "LR AK47 Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
		}
		case 2:
		{
			if(GetEngineVersion() == Engine_CSS)
			{
				wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_mp5navy");
				wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_mp5navy");
				
				PrintToChatAll(CHAT_BANNER, "LR MP5 Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
			}
			else if (GetEngineVersion() == Engine_CSGO)
			{
				wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_bizon");
				wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_bizon");
				
				PrintToChatAll(CHAT_BANNER, "LR Bizon Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
			}
		}
		case 3:
		{
			if(GetEngineVersion() == Engine_CSS)
			{
				wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_galil");
				wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_galil");
			}
			else if (GetEngineVersion() == Engine_CSGO)
			{
				wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_galilar");
				wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_galilar");
			}
			
			PrintToChatAll(CHAT_BANNER, "LR Galil Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
		}
		case 4:
		{
			wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_p90");
			wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_p90");
			
			PrintToChatAll(CHAT_BANNER, "LR P90 Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
		}
		case 5:
		{
			wep1 = GivePlayerItem(g_LR_Player_Prisoner, "weapon_m249");
			wep2 = GivePlayerItem(g_LR_Player_Guard, "weapon_m249");
			
			PrintToChatAll(CHAT_BANNER, "LR MGUN Start", g_LR_Player_Prisoner, g_LR_Player_Guard);
		}
	}
	
	SetEntData(wep1, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), GetConVarInt(g_hAmmo));
	SetEntData(wep2, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), GetConVarInt(g_hAmmo));
	
	new ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	SetEntData(g_LR_Player_Prisoner, ammoOffset+(1*4), 0);
	SetEntData(g_LR_Player_Guard, ammoOffset+(1*4), 0);
	
	SetEntityGravity(g_LR_Player_Prisoner, 1.0);
	SetEntityGravity(g_LR_Player_Guard, 1.0);
	
	SetEntPropFloat( g_LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(g_hSpeed) );
	SetEntPropFloat( g_LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", GetConVarFloat(g_hSpeed) );
	
	InitializeLR(g_LR_Player_Prisoner);
}