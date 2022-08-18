// 0xffb16hexcodetohex.

stock BigEndian:operator=(b)
{
	return BigEndian:(((b >>> 24) & 0x000000FF) | ((b >>> 8) & 0x0000FF00) | ((b << 8) & 0x00FF0000) | ((b << 24) & 0xFF000000));
}
 
main()
{
	new
	    BigEndian:a = 7;
	printf("%d", _:a);
}
// +, -, *, /, %, ++, --, ==, !=, <, >, <=, >=, ! and =
main()
{
	new
		HexColor:Blue = 0x00FF00FF;
	printf("%s", Blue);
}	
stock HexColor:operator!(col) return HexColor:(col >>> 8);

// Optimization PlayerFlags Array (For boolean)
// Usage for all macros: BitFlag_X(variable, flag)
#define BitFlag_Get(%0,%1)            ((%0) & (%1))   // Returns zero (false) if the flag isn't set.
#define BitFlag_On(%0,%1)             ((%0) |= (%1))  // Turn on a flag.
#define BitFlag_Off(%0,%1)            ((%0) &= ~(%1)) // Turn off a flag.
#define BitFlag_Toggle(%0,%1)         ((%0) ^= (%1))  // Toggle a flag (swap true/false).

enum PlayerFlags:(<<= 1) {
	// It's important that you don't forget to put "= 1" on the first flag. If you don't, all flags will be 0.
	PLAYER_IS_LOGGED_IN = 1,	// 0b00000000000000000000000000000001
	PLAYER_AUTO_LOGIN,			// 0b00000000000000000000000000000010
	PLAYER_IS_SPAWNED,			// 0b00000000000000000000000000000100
}

new
	PlayerFlags:g_PlayerFlags[MAX_PLAYERS]
;

public OnPlayerConnect(playerid) {
	// 0 - All flags are off (false). You must include the tag to prevent a warning.
	g_PlayerFlags[playerid] = PlayerFlags:0;
}

public OnPlayerLogin(playeid) {
	BitFlag_On(g_PlayerFlags[playerid], PLAYER_IS_LOGGED_IN);
}
enum PlayerFlags:(<<= 1) {
    // It's important that you don't forget to put "= 1" on the first flag. If you don't, all flags will be 0.
    
    PLAYER_IS_LOGGED_IN = 1,   // 0b00000000000000000000000000000001
    PLAYER_HAS_GANG,           // 0b00000000000000000000000000000010
    PLAYER_CAN_BUY_PROPERTIES, // 0b00000000000000000000000000000100
};

new
    // Create an array with the same tag as the enum
    PlayerFlags:g_PlayerFlags[MAX_PLAYERS]
;

public OnPlayerConnect(playerid) {
    // 0 - All flags are off (false). You must include the tag to prevent a warning.
    g_PlayerFlags[playerid] = PlayerFlags:0;
}

public OnPlayerLogIn(playerid) {
    BitFlag_On(g_PlayerFlags[playerid], PLAYER_IS_LOGGED_IN);
    
//  Without macros:
//  g_PlayerFlags[playerid] |= PLAYER_IS_LOGGED_IN;
}

public OnPlayerJoinGang(playerid) {
    BitFlag_On(g_PlayerFlags[playerid], PLAYER_HAS_GANG);
    
//  Without macros:
//  g_PlayerFlags[playerid] |= PLAYER_HAS_GANG;
}

public OnPlayerLeaveGang(playerid) {
    BitFlag_Off(g_PlayerFlags[playerid], PLAYER_HAS_GANG);
    
//  Without macros:
//  g_PlayerFlags[playerid] &= ~PLAYER_HAS_GANG;
}

public OnPlayerUpdate(playerid) {
    // DoSomething every-other player update.
    
    BitFlag_Toggle(g_PlayerFlags[playerid], PLAYER_BLABLA_19);
    
    if (BitFlag_Get(g_PlayerFlags[playerid], PLAYER_BLABLA_19)) {
        DoSomething();
    }
    
//  Without macros:
//  g_PlayerFlags[playerid] ^= PLAYER_BLABLA_19;
//  
//  if (g_PlayerFlags[playerid] & PLAYER_BLABLA_19) {
//      DoSomething();
//  }
}