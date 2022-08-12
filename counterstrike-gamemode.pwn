//===========================================================================================================================
/*
 *            Counter Strike Mode v0.1b
 *       (c) Copyright 2013-2013 by Liron
 *
 * GTA-World CS Mode is a gamemode developed by Liron for GTA-World community.
 * this mode belongs to GW (Grand Theft Auto: World) community Only!
 *
 * @author    : Liron
 * @date      : 25rd January 2013
 * @update    : 25rd January 2013
 *
 * Please email me about any bug discovered (my email: liron@gta-world.co.il).
 */
//===========================================================================================================================
//---------------------------------- Includes ------------------------------------

#include "a_samp.inc"
#include "strlib.inc"
//#include "streamer.inc"
#include "dini.inc"
#include "foreach.inc"

//---------------------------------- Settings ------------------------------------

#pragma dynamic 63530
new g_szFormatString[256];
#define SendFormat(%1,%2,%3) SendClientMessage(%1, %2, (format(g_szFormatString, sizeof(g_szFormatString), %3), g_szFormatString))
#define SendFormatToAll(%1,%2) SendClientMessageToAll(%1, (format(g_szFormatString, sizeof(g_szFormatString), %2), g_szFormatString))
#define SendFormatToTeam(%1,%2,%3) foreach(new i : Player) if(pinfo[i][pTeam] == %1) SendFormatToAll(%2,%3)

#define FLOAT_INFINITY (Float:0x7F800000)
#define FLOAT_NEG_INFINITY (Float:0xFF800000)
#define FLOAT_NAN (Float:0x7FFFFFFF)
// Credit to Y_Less

#if !defined MAX_PLAYER_IP
	#define MAX_PLAYER_IP (16)
#endif

#undef MAX_PLAYERS
#define MAX_PLAYERS 50

#define version "0.1b"
#define author "Liron"
#define webrul "www.GTA-World.co.il"
#define csfile "CSSettings.txt"
#define AMX_FILE "CSMode"

// colors:
#define white 0xFFFFFFFF
#define grey 0xAFAFAFFF
#define green 0x33AA33FF
#define red 0xAA3333FF
#define lightred 0xFF0000FF
#define yellow 0xFFFF00FF
#define blue 0x0000FFFF
#define lightblue 0x00FFFFFF
#define orange 0xFF9900FF
#define black 0x000000FF
#define C_white FFFFFF
#define C_grey AFAFAF
#define C_green 33AA33
#define C_red AA3333
#define C_lightred FF0000
#define C_yellow FFFF00
#define C_blue 0000FF
#define C_lblue 00FFFF
#define C_orange FF9900
#define C_black 000000
#define @c(%1) "{"#C_%1"}"

#if !defined stock2
	#define stock2%1(%2) 	forward %1(%2); stock %1(%2) // stock with definition
#endif
#if !defined function
	#define function%1(%2) 		forward %1(%2); public %1(%2) // public forward
#endif

// Dialogs:
#define WEAPON_DIALOG 8
#define STATS_DIALOG 9
#define AL_DIALOG 10
#define RADIO_DIALOG 11
#define HELP_DIALOG 12 // 12-20

// Weapons:
new weaponArray[][2] =
{
	// wid, lvl
	{26, 6},
	{27, 5},
	{23, 4}
};

// teams:
#define INVALID_TEAM -1
#define TEAM_CT 0
#define TEAM_T 1
#define TEAM_S 2
#define FIGHT_TEAMS 2
#define MAX_TEAMS 3
#define MAX_SPAWNS 5
new maxTeamPlayers[FIGHT_TEAMS] = {5,5};
enum RadioEnum { rName[94], rURL[128] };
new RadioList[][RadioEnum] =
{
	{"Plan The Bomb!", "url"},
	{"Plan The Bomb!", "url"},
	{"Plan The Bomb!", "url"},
	{"Plan The Bomb!", "url"},
	{"Plan The Bomb!", "url"}
};
new audioSpree[] =
	{"url", "url", "url", "url"};

new roundVar[3] = {15,0,0};
// round left round number, round timer
// key defines
#define PRESSING(%0,%1) (((%0) & (%1)) == (%1))
#define PRESSED(%0,%1,%2) ((((%0) & (%2)) == (%2)) && (((%1) & (%2)) != (%2)))
#define RELEASED(%0,%1,%2) ((((%0) & (%2)) != (%2)) && (((%1) & (%2)) == (%2)))

// c4 system
#define C4_OBJECT 1252
#define C4_TIMER (60000 * 2) // 2Mins
#define C4_DEFUSETIME 16 // 16Sec (1000 * 16)
#define C4_AREA 2370.7329,-12.7635,27.8438
new c4Var[4] = {0, ...};
// bomber; defuser; object; is planted;

//new cd[2] = {-1,0};
enum teamsEnum { tName[24],tSName[5],cColor,cHexa[8],hexColor,skins[3],weapons[3] };
new g_TeamsData[MAX_TEAMS][teamsEnum] =
{
	{"Counter Terrorist", "CT", 'b', #C_blue, 0x0000FFFF, {285,268,294}, {30,34,26}},
	{"Terrorist", "T", 'r', #C_lightred, 0xFF0000FF, {291,287,112}, {24,30,34}},
	{"Spectator", "Spec", 'w', #C_white, 0xFFFFFFFF, {101}, {0,0,0}}
};
#define tinfo[%0][%1] g_TeamsData[%0][%1]
new Float: g_teamCTSpawns[][3] = {{2375.3477,91.8241,26.4844},{2379.1357,98.9406,26.5369},{2373.2258,98.9383,26.5369},{2373.5842,84.0828,26.4844},{2379.0747,83.9182,26.4844}};
new Float: g_teamTSpawns[][3] = {{2553.9810,44.3465,26.3396},{2547.8904,39.6168,26.3424},{2557.1367,39.6184,26.3359},{2556.9749,49.5711,26.4844},{2548.7979,49.0433,26.4844}};
new bool: antiTK[2] = {false, false};
// player
enum pinfoEnum { pName[MAX_PLAYER_NAME+1],pIP[MAX_PLAYER_IP+1],pTeam,pKills,pDeaths,pLevel,pSpawned,bool:pAdmin,killingSpree[2],bool:IsDied,vMode,tView,pTable, pSpec };
new g_PlayerData[MAX_PLAYERS][pinfoEnum];
#define g_IsPlayerAdmin[%0] \
	g_PlayerData[%0][pAdmin] == true || IsPlayerAdmin(%0) // Is Player pAdmin or Rcon Admin
	
#define pinfo[%0][%1] g_PlayerData[%0][%1]
#define getName[%0] g_PlayerData[%0][pName]
#define getIP[%0] g_PlayerData[%0][pIP]
#define @P:%0[%1] g_PlayerData[%0][%1]

#define TTS(%0,%1,%2) TextToSpeech(%0,%1,%2)

// Table Kill
new TableKill[2] = {INVALID_PLAYER_ID,0};
// Last Killer id, Kills

new /*bool: gameStarted = false,*/ bool: g_ModeLoaded = false;

main()
	return printf("\rCounter Strike v"version" Mode by "author" (www.GTA-World.co.il)\r\tLoaded: %s!", g_ModeLoaded? ("successfuly") : ("with errors"));
/* Main print debug:
Counter Strike v0.1b Mode by Liron (www.GTA-World.co.il)
Loaded: successfully!*/

public OnGameModeInit()
{
	if(!fexist(csfile)) return printf("ERROR: Gamemode main file isn't exists. Server shutting down"), SendRconCommand("exit"), 1;
	if(MAX_PLAYERS != GetMaxPlayers()) {
		print("WARNING: MAX_PLAYERS define isn't defined right. Server shutting down.");
		return SendRconCommand("exit"), 1;
	}
	//LoadDataFiles();
	SetGameModeText("CS Mode v"version" (GTA-World)");
	ShowNameTags(1);
	ShowPlayerMarkers(0);
	SetWorldTime(0);
	SetWeather(3);
	SetTeamCount(MAX_TEAMS);
	DisableInteriorEnterExits();
	SetTimer("OnRoundEnd", roundVar[0] * 60000, true);
	// Map - by SaideN
	AddPlayerClass(285,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(286,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(294,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(291,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(287,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(112,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	AddPlayerClass(101,1958.3783,1343.1572,15.3746,270.1425,0,0,24,300,-1,-1);
	CreateObject(4576, 2458.3999023438, 173.89999389648, 28.799999237061, 0, 0, 268.73010253906);
	CreateObject(4576, 2537.6999511719, 171.5, 28.799999237061, 0, 0, 268.7255859375);
	CreateObject(4576, 2556.3999023438, 140.19999694824, 28.799999237061, 0, 0, 226.7255859375);
	CreateObject(4576, 2578.8994140625, 74.2998046875, 28.799999237061, 0, 0, 182.71911621094);
	CreateObject(4576, 2580.8999023438, 21.5, 28.799999237061, 0, 0, 180.72412109375);
	CreateObject(4576, 2541.1999511719, -61.400001525879, 28.799999237061, 0, 0, 124.71484375);
	CreateObject(4576, 2514.1999511719, -72.400001525879, 28.799999237061, 0, 0, 102.71130371094);
	CreateObject(4576, 2456.6000976563, -85.599998474121, 28.799999237061, 0, 0, 92.711181640625);
	CreateObject(4576, 2406, -88.5, 28.799999237061, 0, 0, 92.708129882813);
	CreateObject(4576, 2344.8000488281, -56.700000762939, 28.799999237061, 0, 0, 358.703125);
	CreateObject(4576, 2376.8999023438, 175.10000610352, 28.799999237061, 0, 0, 268.7255859375);
	CreateObject(4576, 2345.3994140625, 24.19921875, 28.799999237061, 0, 0, 358.69262695313);
	CreateObject(4576, 2348.3000488281, 118.19999694824, 28.799999237061, 0, 0, 358.69812011719);
	CreateObject(3939, 2546.6000976563, 49, 27.200000762939, 0, 0, 0);
	CreateObject(3939, 2546.3999023438, 39.599998474121, 27.200000762939, 0, 0, 0);
	CreateObject(3939, 2559.1000976563, 39.5, 27.200000762939, 0, 0, 180);
	CreateObject(3939, 2559.1000976563, 48.900001525879, 27.200000762939, 0, 0, 179.99450683594);
	CreateObject(3763, 2547.6999511719, 109.40000152588, 32.400001525879, 0, 0, 0);
	CreateObject(967, 2541.3000488281, 29.89999961853, 25.5, 0, 0, 0);
	CreateObject(967, 2541.3000488281, 53, 25.5, 0, 0, 0);
	CreateObject(3243, 2471.2998046875, 96.099609375, 25.5, 0, 0, 0);
	CreateObject(3243, 2456, 78.599609375, 25.5, 0, 0, 0);
	CreateObject(5837, 2469.5, -8.6000003814697, 27.10000038147, 0, 0, 88);
	CreateObject(5837, 2394.5, 53.299999237061, 27.10000038147, 0, 0, 205.99499511719);
	CreateObject(8168, 2478.8994140625, 71.69921875, 27.39999961853, 0, 0, 0);
	CreateObject(8620, 2562.8000488281, 44.099998474121, 43.200000762939, 19.9951171875, 0, 271.99951171875);
	CreateObject(8620, 2367.8999023438, 92.199996948242, 45.799999237061, 19.989624023438, 0, 91.994018554688);
	CreateObject(3939, 2371.1000976563, 98.900001525879, 27.299999237061, 0, 0, 0);
	CreateObject(3939, 2371.099609375, 84, 27.299999237061, 0, 0, 0);
	CreateObject(3939, 2381.3999023438, 84, 27.299999237061, 0, 0, 180);
	CreateObject(3939, 2381.3994140625, 98.8994140625, 27.299999237061, 0, 0, 179.99450683594);
	CreateObject(967, 2386.3000488281, 81.400001525879, 25.5, 0, 0, 0);
	CreateObject(967, 2386.3000488281, 99.800003051758, 25.5, 0, 0, 180);
	CreateObject(1225, 2452, -40.599998474121, 26.10000038147, 0, 0, 0);
	CreateObject(1225, 2476.3000488281, 60.299999237061, 25.89999961853, 0, 0, 0);
	CreateObject(1225, 2444.6999511719, 52.900001525879, 25.89999961853, 0, 0, 0);
	CreateObject(1225, 2383, 22.299999237061, 25.60000038147, 0, 0, 0);
	CreateObject(6965, 2463.8999023438, 40.700000762939, 29.39999961853, 0, 0, 0);
	CreateObject(8168, 2383.6000976563, -11, 27.5, 0, 0, 324);
	CreateObject(3243, 2414.3000488281, -39.700000762939, 25.60000038147, 0, 0, 0);
	CreateObject(3243, 2438.3000488281, -14.5, 25.60000038147, 0, 0, 0);
	CreateObject(16644, 2392.5, -15.10000038147, 25.39999961853, 0, 0, 0);
	CreateObject(16644, 2535.6000976563, 98.800003051758, 25.39999961853, 0, 0, 0);
	CreateObject(16644, 2476.1000976563, 114.90000152588, 25.39999961853, 0, 0, 268);
	CreateObject(355, 2556.6999511719, 42.299999237061, 27.5, 0, 0, 0);
	CreateObject(355, 2557, 46.200000762939, 27.60000038147, 0, 0, 0);
	CreateObject(355, 2546.8999023438, 46.299999237061, 27.60000038147, 0, 0, 0);
	CreateObject(355, 2546.6999511719, 42.200000762939, 27.799999237061, 0, 0, 0);
	CreateObject(356, 2382.1999511719, 96.199996948242, 27.799999237061, 0, 0, 0);
	CreateObject(356, 2372.6000976563, 96.099998474121, 27.60000038147, 0, 0, 0);
	CreateObject(356, 2381.3000488281, 86.699996948242, 27.799999237061, 0, 0, 0);
	CreateObject(356, 2372.099609375, 86.69921875, 27.799999237061, 0, 0, 0);
	CreateObject(987, 2369.1000976563, 81.300003051758, 25.5, 0, 0, 358);
	CreateObject(987, 2370.5, 101.90000152588, 25.5, 0, 0, 359.99951171875);
	CreateObject(987, 2547.8000488281, 36.799999237061, 25.5, 0, 0, 359.99450683594);
	CreateObject(987, 2547, 52, 25.5, 0, 0, 359.99450683594);	
	g_ModeLoaded = true;
	return 1;
}
public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, getName[playerid], MAX_PLAYER_NAME+1);
	GetPlayerIp(playerid, getIP[playerid], MAX_PLAYER_IP+1);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	new reas[16];
	switch(reason)
	{
		case 0: reas = "Timed out";
		case 1: reas = "Leaving";
		case 2: reas = "Kicked/Banned";
		default: reas = "Unknown";
	}
	SendFormatToAll(-1, "%s left the server. (Reason: %s)", getName[playerid], reas);
	maxTeamPlayers[@P:playerid[pTeam]]++;
	/*if(gameStarted == true && teamPlayers(TEAM_CT) == 0 || teamPlayers(TEAM_T) == 0)
	{
		gameStarted = false;
		SendFormatToAll(lightred, "%s :éöà îäùøú. ñéáä \"%s\" äîùç÷ ðòöø îàçø åäùç÷ï", reas, getName[playerid]);
	}*/
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
	@P:playerid[IsDied] = true;
	SendDeathMessage(killerid, playerid, reason);
	PlayerSpectatePlayerEx(playerid, killerid != INVALID_PLAYER_ID? killerid : GetRandomID());
	if(@P:playerid[killingSpree][1] != 0) 
	{
		SendClientMessage(playerid,lightblue,"[Killing Spree] {FAFAFA}øöó ääøéâåú ùìê äúàôñ");
	}
	pinfo[playerid][killingSpree][0] = 0;
	pinfo[playerid][killingSpree][1] = 0;
	pinfo[playerid][pDeaths]++;
	if(killerid != INVALID_PLAYER_ID)
	{
		pinfo[killerid][killingSpree][0]++;
		pinfo[killerid][pKills]++;
		SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
		if(GetPlayerScore(killerid) > dini_Int(csfile, "BestKillerScore"))
		{
			dini_Set(csfile, "BestKiller", getName[killerid]);
			dini_IntSet(csfile, "BestKillerScore", GetPlayerScore(killerid));
			SendFormatToAll(0xFF0A00FF,"[Best Killer] {87FF00}%i: {FAFAFA}äùéà äçãù !Best Killer ùáø àú ùéà ä {87FF00}\"%s\" {FAFAFA}áøëåú! äùç÷ï", GetPlayerScore(killerid), getName[killerid]);
		}
		if(@P:killerid[pKills] % 10 == 0) LevelUp(killerid);
		if(@P:killerid[killingSpree][0] % 5 == 0)
		{
			pinfo[killerid][killingSpree][1]++;
			PlayAudioStreamForPlayer(killerid,audioSpree[@P:playerid[killingSpree][1]]);
			SendFormatToAll(lightblue,"[Killing Spree]{005FFF} ùç÷ðéí áøöó {FF1400}%i {005FsFF}äøâ {FF1400}\"%s\" {005FFF}äùç÷ï", @P:killerid[killingSpree][0], getName[killerid]);
		}
		if(killerid != TableKill[0]) TableKill[0] = killerid, TableKill[1] = 1;
		else 
		{
			TableKill[1]++;
			if(TableKill[1] == 5) SendFormatToAll(lightblue, "[Table Kill] îéìà èáìä \"%s\" äùç÷ï", getName[TableKill[0]]), TableKill[1] = 0;
		}
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == RADIO_DIALOG && response)
	{
		PlayAudioStreamForTeam(pinfo[playerid][pTeam],RadioList[listitem][rURL]);
		SendFormatToTeam(pinfo[playerid][pTeam],blue,"* [Radio] %s: \"%s\"", getName[playerid], RadioList[listitem][rName]);
		return 1;
	}
	if(dialogid == AL_DIALOG && response)
	{
		if(isequal(inputtext, dini_Get(csfile, "AdminPassword"), true))
		{
			g_PlayerData[playerid][pAdmin] = true;
			SendClientMessage(playerid,0xF50000FF,"[Admin System] {FAFAFA}äúçáøú ìîòøëú äàãîéðéí áäöìçä");
		}
		else SendClientMessage(playerid,0xF50000FF,"[Admin System] {FAFAFA}äñéñîä ùä÷ùú ùâåéä"), Kick(playerid);
		return 1;
	}
	return 0;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(@P:playerid[IsDied] == true)
	{
		if (newkeys & KEY_FIRE)
		{
			gettingID: new getrndid = GetRandomID();
			if(getrndid == @P:playerid[tView] || @P:getrndid[pTeam] != INVALID_TEAM || @P:getrndid[pTeam] != TEAM_S) goto gettingID;
			else PlayerSpectatePlayerEx(playerid, getrndid);
		}
		if(newkeys & KEY_ACTION) PlayerSpectatePlayerEx(playerid, @P:playerid[tView], g_PlayerData[playerid][vMode]++);
	}
	if(PRESSING(newkeys, KEY_NO))
	{
		if(IsPlayerInRangeOfPoint(playerid,5.0,C4_AREA))
		{
			switch(pinfo[playerid][pTeam])
			{
				case TEAM_T: if(c4Var[0] == playerid) BombPlantingProcess(playerid);
				case TEAM_CT: if(c4Var[3]) BombDefusingProcess(playerid);
			}
		}
	}
	return 1;
}
public OnPlayerSpawn(playerid)
{
	/*if(gameStarted == false)
	{
		new p[2] = {0,0};
		foreach(new i : Player) if(pinfo[i][pTeam] != INVALID_TEAM && pinfo[i][pTeam] != TEAM_S)
		{
			p[pinfo[i][pTeam]]++;
			if(i >= 2)
			{
				if(p[0] > 0 && p[1] > 0) 
				{
					cd[0] = 10, cd[1] = SetTimer("StartTheGame",1000,1);
					SendFormatToAll(lightblue, "!Prepare To Fight ,äñôéøä ìäúçìú äîùç÷ äçìä");
					break;
				}
			}	
		}
	}*/
	for(new i = 0; i < MAX_TEAMS && pinfo[playerid][pTeam] == INVALID_TEAM; i++) for(new j = 0; j < 3; j++) if(GetPlayerSkin(playerid) == g_TeamsData[i][skins][j]) pinfo[playerid][pTeam] = i;
	switch(pinfo[playerid][pTeam])
	{
		case TEAM_CT..TEAM_T:
		{
			if(pinfo[playerid][pTeam])
			{
				new rand = random(sizeof(g_teamCTSpawns));
				SetPlayerPos(playerid,g_teamCTSpawns[rand][0],g_teamCTSpawns[rand][1],g_teamCTSpawns[rand][2]);
				for(new i = 0; i < 3; i++) GivePlayerWeapon(playerid, g_TeamsData[@P:playerid[pTeam]][weapons][i], 9999);
			}
			else
			{
				new rand = random(sizeof(g_teamTSpawns));
				SetPlayerPos(playerid,g_teamTSpawns[rand][0],g_teamTSpawns[rand][1],g_teamTSpawns[rand][2]);
				for(new i = 0; i < 3; i++) GivePlayerWeapon(playerid, g_TeamsData[@P:playerid[pTeam]][weapons][i], 9999);
				if(teamPlayers(TEAM_T) == 1) SetPlayerBomber(playerid, false);
			}
		}
		case TEAM_S:
		{
			TogglePlayerSpectating(playerid,1);
			new found = INVALID_PLAYER_ID;
			for(new i = 0; i < MAX_PLAYERS && found == INVALID_PLAYER_ID; i++) if(IsPlayerConnected(i) && i != playerid && IsFightTeam(pinfo[playerid][pTeam])) found = i;
			if(found != INVALID_PLAYER_ID) PlayerSpectatePlayer(playerid,found);
		}
	}
	SetPlayerColor(playerid, tinfo[@P:playerid[pTeam]][hexColor]);
	SetPlayerHealth(playerid,100.0);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerInterior(playerid,0);
	SetPlayerPos(playerid,2327.1052,1383.8488,43.9128);
	SetPlayerCameraPos(playerid,2327.1057,1376.7577,46.0275);
	SetPlayerCameraLookAt(playerid,2327.1052,1383.8488,43.9128);
	SetPlayerFacingAngle(playerid,180.0000);
	ResetPlayerMoney(playerid);
	SetPlayerColor(playerid,grey);
	GameTextForPlayer(playerid,sprintf("~%c~%s", g_TeamsData[tIDBySkin(GetPlayerSkin(playerid))][cColor], g_TeamsData[tIDBySkin(GetPlayerSkin(playerid))][tName]),2000,5);
	if(pinfo[playerid][pSpawned]) pinfo[playerid][pSpawned] = 0;
	if(pinfo[playerid][pTeam] != INVALID_TEAM)
	{
		pinfo[playerid][pTeam] = INVALID_TEAM;
	}
	return 1;
}
public OnPlayerRequestSpawn(playerid)
{
	for(new i = 0; i < FIGHT_TEAMS; i++) for(new j = 0; j < 3; j++) 
		if(GetPlayerSkin(playerid) == g_TeamsData[i][skins][j] && teamPlayers(i) >= maxTeamPlayers[i]) return SendClientMessage(playerid, 0xF50000FF, "[Over-Players] {fafafa}éù éåúø îãé ùç÷ðéí á÷áåöä ùáçøú"), 0;
	SendFormat(playerid, 0xFFB400FF, "[Team System] {00FFAA}%s áçøú á÷áåöä", g_TeamsData[tIDBySkin(GetPlayerSkin(playerid))][tName]);
	return 1;
}
public OnPlayerText(playerid, text[])
{
	if(text[0] == '^' && g_IsPlayerAdmin[playerid])
	{
		foreach(new i : Player) if(g_IsPlayerAdmin[playerid])
		SendFormat(i,0xFFD200FF,"[Admin Chat] {%s}%s"@c(white)": %s [id: %03i]", GetPlayerColor(playerid) >>> 8, getName[playerid], playerid);
		return 0;
	}
	if(text[0] == '!' && IsFightTeam(pinfo[playerid][pTeam]))
	{
		foreach(new i : Player) if(pinfo[i][pTeam] == pinfo[playerid][pTeam]) 
		SendFormat(i,tinfo[@P:playerid[pTeam]][hexColor],"[%s Chat] "@c(white)"%s: %s [id: %03i]", tinfo[@P:playerid[pTeam]][tSName], getName[playerid], text[1], playerid);
		return 0;
	}
	new ptext[256];
	format(ptext, sizeof(ptext), "%s [id: %03i | {%s}%s{ffffff}]", text, playerid, tinfo[@P:playerid[pTeam]][cHexa], tinfo[@P:playerid[pTeam]][tName]);
	return SendPlayerMessageToAll(playerid, ptext), 0;
}
	
public OnPlayerCommandText(playerid, cmdtext[])
{
	new cmd[128], idx;
	cmd = strtok(cmdtext, idx);
	if(!strcmp(cmd, "/status", true))
	{
		cmd = strtok(cmdtext, idx);
		if(!strlen(cmd)) return SendClientMessage(playerid, -1, "/Status [playerid] :öåøú ùéîåù");
		if(!IsPlayerConnected(strval(cmd))) return SendClientMessage(playerid, -1, "Invalid Player ID");
		new id = strval(cmd);
		new Float:pp[3];
		GetPlayerPos(id, pp[0], pp[1], pp[2]);
		SendFormat(playerid, blue, "{%s}%s's "@c(blue)"Status [Position: %f, %f, %f]", GetPlayerColor(playerid) >>> 8, getName[id], pp[0], pp[1], pp[2]);
		SendFormat(playerid, lightred, "åäåà ëøâò %s %s äùç÷ï ðîöà á÷áåöä", pinfo[id][pTeam], (GetPlayerState(id) == PLAYER_STATE_SPECTATING)? ("áîò÷á") : !pinfo[id][IsDied]? ("îú") : ("îùç÷"));
		return 1;
	}	
	if(!strcmp(cmdtext, "/Buyweapon", true))
	{
		new szStr[624];
		for(new i = 0; i < sizeof(weaponArray); i++) format(szStr,sizeof(szStr),"%s{%s}%i\tLevel: %02i\r",(!szStr)? ("") : (szStr), (pinfo[i][pLevel] >= weaponArray[i][1])? ("00ff00") : ("ee0000"), weaponArray[i][0], weaponArray[i][1]);
		ShowPlayerDialog(playerid, WEAPON_DIALOG, DIALOG_STYLE_INPUT, "Buy Weapon", szStr, "Buy", "Cancel");
		return 1;
	}
	if(!strcmp(cmd, "/help", true))
	{
		cmd = strtok(cmdtext,idx);
		if(!strlen(cmd)) return ShowPlayerDialog(playerid, HELP_DIALOG, DIALOG_STYLE_MSGBOX, "Help - òæøä", sprintf(",\"%s\" äéé\r{FAFAFA}!áøåê äáà ìúôøéè äòæøä\r\r/Help Credits - ìöôéä áøùéîú ä÷øãéèéí\r/Help Commands - ìöôéä áøùéîú äô÷åãåú\r/Help Systems - ìöôéä áøùéîú äîòøëåú\r\r/A éù ìê ùàìä? á÷ùä? öøéê òæøä? àúä îåæîï ìôðåú ìàãîéðéí áàîöòåú äô÷åãä\r\tGTA-World CSA-MP Project",getName[playerid]), "OK", "");
		else if(!strcmp(cmd, "Credits", true)) return ShowPlayerDialog(playerid, (HELP_DIALOG + 1), DIALOG_STYLE_MSGBOX, "Credits - ÷øãéèéí", sprintf(",\"%s\" äéé\r!{FAFAFA}áøåê äáà ìøùéîú ä÷øãéèéí\r\r{FFD200}[T]he3DeVi[L]{FAFAFA} - Mode Scripter\r{FFD200}SaideN{FAFAFA} - Mapper\r\r!äîùê îùç÷ îäðä", getName[playerid]), "OK", "");
		else if(!strcmp(cmd, "Commands", true)) return ShowPlayerDialog(playerid, (HELP_DIALOG + 2), DIALOG_STYLE_MSGBOX, "Commands - ô÷åãåú", "Commands List:\r/Radio - radio system\r/ChangeTeam - Change your team", "OK", "");
		else if(!strcmp(cmd, "Systems", true))
		{
			cmd = strtok(cmdtext, idx);
			if(!strlen(cmd)) return ShowPlayerDialog(playerid, (HELP_DIALOG + 3), DIALOG_STYLE_MSGBOX, "Systems - îòøëåú", "Systems List:\r1 - C4\r2 - etc..", "OK", "");
			switch(strval(cmd))
			{
				case 0: print("sys 1");
				case 1: print("sys 1");
				case 2: print("sys 2");
				case 3: print("sys 3");
				default: return 1;
			}
		}
	}
	if(!strcmp(cmd, "/Stats", true))
	{
		cmd = strtok(cmdtext, idx);
		if(!strlen(cmd)) return SendClientMessage(playerid, -1, "/Stats [playerid] :öåøú ùéîåù");
		if(!IsPlayerConnected(strval(cmd))) return SendClientMessage(playerid, -1, "Invalid ID.");
		return ShowPlayerStats(strval(cmd));
	}
	if(!strcmp(cmdtext, "/radio", true) || !strcmp(cmdtext, "/r", true))
	{
		new szStr[624];
		for(new i = 0; i < sizeof(RadioList); i++) format(szStr, sizeof(szStr), "%s%s\r", (!szStr)? ("") : (szStr), RadioList[i][rName]);
		return ShowPlayerDialog(playerid, RADIO_DIALOG, DIALOG_STYLE_INPUT, "Radio List", szStr, "Play", "Cancel");
	}
	if(!strcmp(cmdtext, "/ChangeTeam", true))
	{
		SetPlayerHealth(playerid, 0.0);
		ForceClassSelection(playerid);
	    TogglePlayerSpectating(playerid, true);
		TogglePlayerSpectating(playerid, false);
		SendClientMessage(playerid,-1,"Change Team");
		return 1;
	}
	// Admin Mode
	if(isequal(cmdtext, "/adminlogin", true) || isequal(cmdtext, "/alogin", true))
	{
		if(g_PlayerData[playerid][pAdmin] == true)
			return SendClientMessage(playerid,0xFF0000FF,"[Admin System] {FAFAFA}àúä îçåáø ëáø ìîòøëú äàãîéðéí");
		ShowPlayerDialog(playerid, AL_DIALOG, DIALOG_STYLE_INPUT, "Admin Login // äúçáøåú ìàãîéï", "àðà äæï àú ñéñîú äàãîéðéí", "àùø", "áèì");
		return 1;
	}
	if(isequal(cmdtext, "/adminlogout", true) || isequal(cmdtext, "/alogout", true))
	{
		if(!g_PlayerData[playerid][pAdmin]) return SendClientMessage(playerid, 0xFF0000FF, "[Admin System] {fafafa}.àéðê àãîéï");
		g_PlayerData[playerid][pAdmin] = false;
		SendClientMessage(playerid,0xFF0000FF, "[Admin System] {fafafa}äúðú÷ú áäöìçä îäàãîéï");
		return 1;
	}
	if(g_IsPlayerAdmin[playerid])
	{
		if(isequal(cmdtext, "/CleanChat", true) || isequal(cmdtext, "/CC", true))
		{
			for(new i = 0; i < 50; i++) 
			{
				SendClientMessageToAll(-1, "");
			}
			GameTextForPlayer(playerid,"~n~~n~~n~~n~~n~~n~~n~~n~~n~Chat cleaned!",2000,4);
			return 1;
		}
		if(!strcmp(cmd, "/antiTK", true))
		{
			cmd = strtok(cmdtext, idx);
			if(!strlen(cmd)) return SendClientMessage(playerid, -1, "/antiTK [CT/T] :öåøú ùéîåù");
			if(!strcmp(cmd, "ct", true))
			{
				antiTK[0] = !antiTK[0]? true : false;
				SendFormatToAll(0xECFF57FF, "[CT ATK] {FAFAFA}%s àú äàðèé èéí ÷éì \"%s\" äàãîéï", !antiTK[0]? ("ëéáä") : ("äôòéì"), getName[playerid]);
				SendFormatToTeam(TEAM_CT, 0xECFF57FF, "[Anti-TK] {FAFAFA}Anti team kill %s", !antiTK[0]? ("{FF0000}OFF") : ("{05FF00}ON"));
				return 1;
			}
			else if(!strcmp(cmd, "t", true))
			{
				antiTK[1] = !antiTK[1]? true : false;
				SendFormatToAll(0xECFF57FF, "[Terrorist ATK] {FAFAFA}%s àú äàðèé èéí ÷éì \"%s\" äàãîéï", !antiTK[1]? ("ëéáä") : ("äôòéì"), getName[playerid]);
				SendFormatToTeam(TEAM_T, 0xECFF57FF, "[Anti-TK] {FAFAFA}Anti team kill %s", !antiTK[1]? ("{FF0000}OFF") : ("{05FF00}ON"));
				return 1;
			}
			return 1;
		}
		if(!strcmp(cmd,"/setskin",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetSkin " @c(lightblue) "[ID]" @c(white) " [Skin ID] :öåøú äùéîåù");
			new id = strval(cmd), skinid = 0;
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetSkin [ID] " @c(lightblue) "[Skin ID]" @c(white) " :öåøú äùéîåù");
			skinid = strval(cmd);
			if(!IsValidSkin(skinid)) return SendClientMessage(playerid,red," .îñôø ãîåú ùâåé");
			SetPlayerSkin(id,skinid);
			SendFormat(playerid,white," .ìãîåú îñôø %d %s ùéðéú àú äãîåú ùì",skinid,getName[id]);
			SendFormat(id,white," .äàãîéï ùéðä àú äãîåú ùìê ìãîåú îñôø %d",skinid);
			return 1;
		}
		if(!strcmp(cmd,"/kick",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /Kick " @c(lightblue) "[ID]" @c(white) " [Reason] :öåøú äùéîåù");
			new id = strval(cmd);
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			if(g_IsPlayerAdmin[id] && id != playerid) return SendClientMessage(playerid,red,"[Admin System] {fafafa}ìà ðéúï ìáöò àú äô÷åãä òì àãîéï àçø");
			cmd = strrest(cmdtext,idx);
			if(!strlen(cmd)) cmd = "äàãîéï ìà ä÷ìéã ñéáä";
			SendFormatToAll(0xFF0000FF,"" @c(red) "%s" @c(lightred) " has been kicked by " @c(red) "%s" @c(lightred) " [Reason: " @c(red) "%s" @c(lightred) "]",getName[id],getName[playerid],cmd);
			Kick(id);
			return 1;
		}
		if(!strcmp(cmd,"/ban",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /Ban " @c(lightblue) "[ID]" @c(white) " [Reason] :öåøú äùéîåù");
			new id = strval(cmd);
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			if(g_IsPlayerAdmin[id] && id != playerid) return SendClientMessage(playerid,red," .ìà ðéúï ìáöò àú äô÷åãä òì àãîéï àçø");
			cmd = strrest(cmdtext,idx);
			if(!strlen(cmd)) cmd = "äàãîéï ìà ä÷ìéã ñéáä";
			SendFormatToAll(0xFF0000FF,"" @c(red) "%s" @c(lightred) " has been banned by " @c(red) "%s" @c(lightred) " [Reason: " @c(red) "%s" @c(lightred) "]",getName[id],getName[playerid],cmd);
			format(cmd,sizeof(cmd),"Ban from ladder mode [Admin: %s, Reason: %s]",getName[playerid],cmd);
			BanEx(id,cmd);
			return 1;
		}
		if(!strcmp(cmd,"/gw",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /GW " @c(lightblue) "[ID]" @c(white) " [Weapon ID] :öåøú äùéîåù");
			new id = strval(cmd), wid = 0, wname[32];
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /GW [ID] " @c(lightblue) "[Weapon ID]" @c(white) " :öåøú äùéîåù");
			wid = strval(cmd);
			if(wid < 0 || wid > 46 || (wid >= 19 && wid <= 21)) return SendClientMessage(playerid,red," .îñôø ðù÷ ùâåé");
			GetWeaponName(wid,wname,sizeof(wname));
			GivePlayerWeapon(id,wid,10000);
			SendFormat(playerid,red," .%s àú äðù÷ %s-äáàú ì",wname,getName[id]);
			SendFormat(id,red," .%s äàãîéï äáéà ìê àú äðù÷",wname);
			return 1;
		}
		if(!strcmp(cmd,"/gmx",true))
		{
			SendFormatToAll(lightblue," .áéöò øéñè ìîåã " @c(white) "%s" @c(lblue) " äàãîéï",getName[playerid]);
			SendRconCommand(sprintf("changemode %s", AMX_FILE));
			SetTimer("GMX",200,0);
			return 1;
		}
		if(!strcmp(cmd,"/kickall",true))
		{
			SendFormatToAll(lightblue," .äåöéà àú ëåìí îäùøú " @c(white) "%s" @c(lblue) " äàãîéï",getName[playerid]);
			for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i) && !g_IsPlayerAdmin[i]) Kick(i);
			return 1;
		}
		if(!strcmp(cmd,"/settime",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetTime " @c(lightblue) "[Time 0-23]" @c(white) " :öåøú äùéîåù");
			new h = strval(cmd);
			if(h < 0 && h > 23) return SendClientMessage(playerid,red," .ùòä ùâåéä");
			SetWorldTime(h);
			SendFormatToAll(blue," .ùéðä àú äùòä ì%02d:00 %s äàãîéï",h,getName[playerid]);
			return 1;
		}
		if(!strcmp(cmd,"/TextToSpeech",true) || !strcmp(cmd, "/TTS", true))
		{
			cmd = strrest(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /TTS " @c(lightblue) "[Text]" @c(white) " :öåøú äùéîåù");
			for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) TTS(i,cmd,false);
			return 1;
		}
		if(!strcmp(cmd,"/CancelTextToSpeech",true) || !strcmp(cmd, "/CTTS", true))
		{
			for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) StopAudioStreamForPlayer(i);
			return 1;
		}
		if(!strcmp(cmd,"/akill",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /AKill " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd);
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			SendFormatToAll(0xFF0000FF,"" @c(red) "%s" @c(lightred) " has been killed by " @c(red) "%s",getName[id],getName[playerid]);
			SetPlayerHealth(id,0.0);
			return 1;
		}
		if(!strcmp(cmd,"/respawn",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /Respawn " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd);
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			SendFormatToAll(0xFF0000FF,"" @c(red) "%s" @c(lightred) " has been respawned by " @c(red) "%s",getName[id],getName[playerid]);
			if(GetPlayerState(id) == PLAYER_STATE_SPECTATING)
			{
				TogglePlayerSpectating(id,0);
				pinfo[id][pSpec] = id;
			}
			SpawnPlayer(id);
			return 1;
		}
		if(!strcmp(cmd,"/setskin",true))
		{
		new cmd[7+1],idx;
		strval(cmdtext,idx);
		SetPlayerSkin(playerid,cmd);
		format(idx,sizeof(idx),"%s",cmd);
		SendClientMessage(playerid,-1,"%s áçøú áñ÷éï îñôø",idx);
		}
		
		if(!strcmp(cmd,"/explode",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /Explode " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd), Float:p[3];
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			GetPlayerPos(id,p[0],p[1],p[2]);
			CreateExplosion(p[0],p[1],p[2],6,0.0);
			SendFormatToAll(0xFF0000FF,"" @c(red) "%s" @c(lightred) " has been exploded by " @c(red) "%s",getName[id],getName[playerid]);
			return 1;
		}
		if(!strcmp(cmd,"/sethealth",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetHealth " @c(lightblue) "[ID]" @c(white) " [Health] :öåøú äùéîåù");
			new id = strval(cmd), p;
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetHealth [ID] " @c(lightblue) "[Health]" @c(white) " :öåøú äùéîåù");
			p = strval(cmd);
			if(p < 0 || p > 100) return SendClientMessage(playerid,red," .îñôø ùâåé");
			SetPlayerHealth(id,float(p));
			SendFormat(playerid,white," .àú äçééí ì-%d %s-ùéðéú ì",p,getName[id]);
			SendFormat(id,white," .äàãîéï ùéðä àú äçééí ùìê ì-%d",p);
			return 1;
		}
		if(!strcmp(cmd,"/setarmour",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetArmour " @c(lightblue) "[ID]" @c(white) " [Armour] :öåøú äùéîåù");
			new id = strval(cmd), p;
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /SetArmour [ID] " @c(lightblue) "[Armour]" @c(white) " :öåøú äùéîåù");
			p = strval(cmd);
			if(p < 0 || p > 100) return SendClientMessage(playerid,red," .îñôø ùâåé");
			SetPlayerArmour(id,float(p));
			SendFormat(playerid,white," .àú äîâï ì-%d %s-ùéðéú ì",p,getName[id]);
			SendFormat(id,white," .äàãîéï ùéðä àú äîâï ùìê ì-%d",p);
			return 1;
		}
		if(!strcmp(cmd,"/spec",true))
		{
			if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING)
			{
				cmd = strtok(cmdtext,idx);
				if(!strlen(cmd)) return SendClientMessage(playerid,white," /Spec " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù"), SendClientMessage(playerid,white," /Spec Off - ìäôñ÷ú äîò÷á");
				new id = strval(cmd);
				if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
				if(id == playerid) return SendClientMessage(playerid,red," .ìà ðéúï ìáöò àú äô÷åãä äæå òì òöîê");
				TogglePlayerSpectating(playerid,1);
				PlayerSpectatePlayer(playerid,id);
				pinfo[playerid][pSpec] = id;
				SendFormat(playerid,white," .%s äúçìú îò÷á òì",getName[id]);
				return 1;
			}
			else
			{
				TogglePlayerControllable(playerid,0);
				OnPlayerSpawn(playerid);
				pinfo[playerid][pSpec] = 0;
				SendClientMessage(playerid,-1,".äôñ÷ú àú äîò÷á");
			}
			return 1;
		}
		if(!strcmp(cmd,"/goto",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /GoTo " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd), Float:p[3];
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			GetPlayerPos(id,p[0],p[1],p[2]);
			SetPlayerPos(playerid,p[0],p[1],p[2] + 2.0);
			return 1;
		}
		if(!strcmp(cmd,"/get",true))
		{
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) return SendClientMessage(playerid,white," /Get " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd), Float:p[3];
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			GetPlayerPos(playerid,p[0],p[1],p[2]);
			SetPlayerPos(id,p[0],p[1],p[2] + 2.0);
			return 1;
		}
		if(!strcmp(cmd,"/freeze",true) || !strcmp(cmd,"/unfreeze",true))
		{
			new unf = !strcmp(cmd,"/unfreeze",true);
			cmd = strtok(cmdtext,idx);
			if(!strlen(cmd)) if(unf) return SendClientMessage(playerid,white," /UnFreeze " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù"); else return SendClientMessage(playerid,white," /Freeze " @c(lightblue) "[ID]" @c(white) " :öåøú äùéîåù");
			new id = strval(cmd);
			if(!IsPlayerConnected(id)) return SendClientMessage(playerid,red," .àééãé ùâåé");
			TogglePlayerControllable(id,unf);
			SendFormat(playerid,white,unf ? (" .%s-äåøãú àú ää÷ôàä ì") : (" .%s ä÷ôàú àú"),getName[id]);
			SendClientMessage(id,white,unf ? (" .äàãîéï äåøéã àú ää÷ôàä ùìê") : (" .äàãîéï ä÷ôéà àåúê"));
			return 1;
		}
		if(!strcmp(cmd,"/jetpack",true))
		{
			if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) return SendClientMessage(playerid,red," .àúä ëáø îùúîù áâ'èôà÷");
			SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USEJETPACK);
			return 1;
		}
		if(!strcmp(cmd,"/getall",true))
		{
			new Float:p[3];
			GetPlayerPos(playerid,p[0],p[1],p[2]);
			for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) SetPlayerPos(i,p[0] + float(random(2)-1),p[1] + float(random(2)-1),p[2] + 2.0);
			return 1;
		}
	}
	return 0;
}
stock LevelUp(playerid)
{
	SetPlayerWantedLevel(playerid, GetPlayerWantedLevel(playerid) + 1);
	@P:playerid[pLevel]++;
	SetPlayerHealth(playerid, 100.0), SetPlayerArmour(playerid, 100.0);
	SendFormatToAll(-1, "[Levels System] %i òìä ìøîä \"%s\" áøëåú! äùç÷ï", @P:playerid[pLevel], getName[playerid]);
	// Send Client Messages
}
stock PlayAudioStreamForTeam(teamid, url[])
{
	foreach(new i : Player) if(pinfo[i][pTeam] == teamid)
	{
		PlayAudioStreamForPlayer(i, url);
	}
	return 1;
}
function OnRoundEnd()
{
	SendFormatToAll(-1, "Round #%i Over, a new round will start (Next round number: %i)", roundVar[1], ++roundVar[1]);
	return roundVar[2] = SetTimerEx("OnRoundStart",1000,true,"i",10);
}
function OnRoundStart(cd)
{
	foreach(new i : Player) OnPlayerSpawn(i);
	new cdtext[64];
	if(cd > 0)
	{
		format(cdtext,sizeof(cdtext),"~b~The game~n~will start in ~%c~%d",!(cd % 2)? 'w' : 'r',cd);
		GameTextForAll(cdtext,1000,4);
		cd--;
	}
	else
	{
		KillTimer(roundVar[2]);
		GameTextForAll("~g~go!",2500,4);
		SendClientMessageToAll(lightblue, "The game is start!");
		SendClientMessageToAll(lightblue, "Players:");
		foreach(new i : Player) if(pinfo[i][pTeam] != INVALID_TEAM)
		{
			TogglePlayerControllable(i,1);
			OnPlayerSpawn(i);
			SetPlayerArmour(i, 100.0);
			SendFormatToAll(-1, "%i. %s (id: %i | team: %s)", i+1, getName[i], i, tinfo[pinfo[i][pTeam]][tName]);
		}
		chooseBomber();
		SendFormatToAll(lightred, "Round %i Start!", roundVar[1]);
	}
}
stock chooseBomber()
{
	assert teamPlayers(TEAM_T) >= 1;
	new getid;
	choosePlayerid: getid = GetRandomID();
	if(pinfo[getid][pTeam] != TEAM_T) goto choosePlayerid;
	else SetPlayerBomber(getid, true);
	return 1;
}
stock SetPlayerBomber(playerid, bool: send = false)
{
	assert pinfo[playerid][pTeam] == TEAM_T;
	// GivePlayerBomb
	c4Var[1] = CreateObject(C4_OBJECT,0.0,0.0,0.0,0.0,0.0,0.0,30);
	AttachObjectToPlayer(c4Var[1],playerid,0.0,0.0,0.0,0.0,0.0,0.0);
	c4Var[0] = playerid;
	if(send == true) SendFormatToTeam(TEAM_T, lightred, "The bomber is: %s (id: %i)", getName[playerid], playerid);
	return 1;
}
stock BombPlantingProcess(targetid)
{
	SendFormatToTeam(TEAM_T,lightblue,"[C4 Planting] äúçéì àú úäìéê äèîðú äôööä \"%s\" äùç÷ï", getName[targetid]);
	ApplyAnimation(targetid,"BOMBER","BOM_Plant",4.1,1,1,1,1,1,1);
	SetTimerEx("PlanTheBomb",10 * 1000,false,"i",targetid);
	return 1;
}
function PlanTheBomb(targetid)
{
	DestroyPlayerObject(targetid,c4Var[2]);
	DestroyObject(c4Var[2]);
	new Float:ppos[4];
	GetPlayerPos(targetid,ppos[0],ppos[1],ppos[2]);
	SetPlayerFacingAngle(targetid,ppos[3]);
	c4Var[2] = CreateObject(C4_OBJECT,ppos[0],ppos[1],ppos[2],ppos[3],0.0,0.0,6.0);
	c4Var[3] = 1;
	ClearAnimations(targetid);
	SetTimer("C4BombTimer",C4_TIMER,false);
	return 1;
}
function C4BombTimer()
{
	DestroyObject(c4Var[2]);
	CreateExplosion(C4_AREA,7,50);
	SendClientMessageToAll(lightred, "[C4 System] {fafafa}!äôööä äúôåööä áäöìçä, ÷áåöú äèøåøéñè ðéöçå");
	OnRoundStart(10);
	return 1;
}
stock BombDefusingProcess(targetid)
{
	SendClientMessage(targetid,-1,"defusing start. ("#C4_DEFUSETIME" Seconds)");
	ApplyAnimation(targetid,"BOMBER","BOM_Plant",4.1,1,1,1,1,1,1);
	SetTimerEx("DefuseTheBomb",C4_DEFUSETIME * 1000,false,"i",targetid);
	return 1;
}

function DefuseTheBomb(playerid)
{
	DestroyObject(c4Var[2]);
	c4Var[3] = 0;
	ClearAnimations(playerid);
	SendFormatToAll(lightblue,"[C4 Defuse] !ðéöçå CT÷áåöú ä ,%s äôööä ðåèøìä áäöìçä òì-éãé",getName[playerid]);
	return 1;
}
stock IsValidSkin(skinid)
{
	if(skinid < 0 || skinid > 299) return 0;
	new BadSkins[] = {3,4,5,6,8,42,65,74,86,119,149,208,273,289};
	for(new i = 0; i < sizeof(BadSkins); i++) if(skinid == BadSkins[i]) return 0;
	return 1;
}
stock PlayerSpectatePlayerEx(playerid, targetplayerid, mode = 0)
{
	TogglePlayerSpectating(playerid,1);
	PlayerSpectatePlayer(playerid, targetplayerid, mode);
	@P:playerid[tView] = targetplayerid;
	return 1;
}
stock GetRandomID()
{
	new rnd = GetMaxPlayers();
	while(!IsPlayerConnected(rnd)) rnd = random(GetMaxPlayers());
	return rnd;
}
/*function StartTheGame()
{
	new cdtext[64];
	if(cd[0] > 0)
	{
		format(cdtext,sizeof(cdtext),"~b~The game~n~will start in ~%c~%d",!(cd[0] % 2)? 'w' : 'r',cd[0]);
		GameTextForAll(cdtext,1000,4);
		cd[0]--;
	}
	else
	{
		KillTimer(cd[1]);
		GameTextForAll("~g~go!",2500,4);
		foreach(new i : Player)
		{
			TogglePlayerControllable(i,1);
			OnPlayerSpawn(i);
			SetPlayerArmour(i, 100.0);
		}
		SendClientMessageToAll(lightblue, "The game is start!");
		gameStarted = true;
	}
}*/

stock teamPlayers(teamid)
{
	new c = 0;
	foreach(new i : Player) if(pinfo[i][pTeam] == teamid) c++;
	return c;
}

stock strtok(const string[], &index)
{   // by CompuPhase, improved by me
	new length = strlen(string);
	while((index < length) && (string[index] <= ' ')) index++;
	new offset = index, result[20];
	while((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1))) result[index - offset] = string[index], index++;
	result[index - offset] = EOS;
	return result;
}

stock strrest(const string[], index)
{   // by CompuPhase, improved by me
	new length = strlen(string), offset = index, result[128];
	while((index < length) && ((index - offset) < (sizeof(result) - 1)) && (string[index] > '\r')) result[index - offset] = string[index], index++;
	result[index - offset] = EOS;
	if(result[0] == ' ' && string[0] != ' ') strdel(result,0,1);
	return result;
}
stock TextToSpeech(playerid, text[], bool: send = false)
{
	if(send) SendFormat(playerid, 0x33CCFFAA, "» TTS: %s", text);
	return PlayAudioStreamForAll(sprintf("http://translate.google.com/translate_tts?tl=en&q=%s", text));
}
stock PlayAudioStreamForAll(url[])
{
	foreach(new i : Player) PlayAudioStreamForPlayer(i, url);
	return 1;
}
stock ShowPlayerStats(playerid)
	return ShowPlayerDialog(playerid, STATS_DIALOG, DIALOG_STYLE_MSGBOX, sprintf("%s's Stats", getName[playerid]), sprintf("Player Team: %s\rKills: %i\rDeaths: %i", pinfo[playerid][pTeam], pinfo[playerid][pKills], pinfo[playerid][pDeaths]), "OK", "");
stock tIDBySkin(classid)
{
	switch(classid)
	{
		case 285,268,294: return TEAM_CT;
		case 291,287,112: return TEAM_T;
		case 101: return TEAM_S;
	}
	return INVALID_TEAM;
}
stock IsFightTeam(teamid) return (teamid < FIGHT_TEAMS && teamid != INVALID_TEAM);
