// Coded by Liron
new szFormatString[64];
#define SendClientMessagef(%0,%1,%2,%3) SendClientMessage(%0, %1, (format(szFormatString, sizeof(szFormatString), %2), %3))
for(new i; i < GetMaxPlayers(); i++) if(!IsPlayerConnected(i) && H_Info[i][HONOR_LEVEL])
new pDrunkLevel[MAX_PLAYERS char] = {0, ...}, pFPS[MAX_PLAYERS char] = {0, ...};
public OnPlayerConnect(playerid) pDrunkLevel{playerid} = 0, pFPS{playerid} = 0;
public OnPlayerUpdate(playerid) 
{
	new dlevel = GetPlayerDrunkLevel(playerid);
	if(dlevel < 100) SetPlayerDrunkLevel(playerid, 2000);
	else
	{
		if(pDrunkLevel{playerid} != dlevel) 
		{
			new fps = pDrunkLevel{playerid} - dlevel;
			if((fps > 0) && (fps < 200)) 
				pFPS{playerid} = fps;
				
			pDrunkLevel{playerid} = dlevel;
		}
	}
}
public OnPlayerCommandText(playerid, cmdtext[])
{
if(
	if(!strcmp(cmdtext, "/fps", true, 4))
	{
		if(cmdtext[4] != ' ') || (cmdtext[5] == EOS))
			return SendClientMessagef(playerid, 0xA9C4E4FF, "Your FPS is: %i", GetPlayerFPS(playerid));
			
		new destid = strval(cmdtext[5]);
		if(!IsPlayerConnected(destid)) return SendClientMessage(playerid, 0xFFFFFFFF, "Error: Player isn't connected!");
		
		new name[MAX_PLAYER_NAME + 1];
		GetPlayerName(destid, name, sizeof name);
		SendClientMessagef(playerid, 0xA9C4E4FF, "\"%s\" FPS is: %i", name, GetPlayerFPS(destid));
		return 1;
	}
	return 0;
}

stock GetPlayerFPS(playerid)
	return pFPS{playerid};
