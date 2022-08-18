/*
	Tips & Tricks
					*/
/*
	Initialization / Reset variables (enum, string etc.)
*/

enum E_TEST_DATA {
    E_ONE,
    E_TWO = 10,
    E_THREE[20],
    E_FOUR
}

new g_TEST[E_TEST_DATA];
	/* EQUAL To: new g_TEST[E_ONE + E_TWO + E_THREE + E_FOUR]; */

g_TEST[E_TEST_DATA:0] = 0;

// Reset all cells with for-loop
for(new i = 0; E_TEST_DATA:i < E_TEST_DATA; i++)
	g_TEST[E_TEST_DATA:i] = 0;
	
	new x[E_TEST_DATA];

new x[E_TEST_DATA];
g_TEST = x;

g_TEST[E_THREE] = 0; // Even it string.
g_TEST[E_THREE] = EOS; // 0 = '/0' = EOS (End of String)

/*
	Ternay Operators
*/

SetPlayerColor(playerid, (Team[ playerid ] == TEAM_ONE) ? COLOR_RED : COLOR_BLUE);
// Set the color to red if the player is in TEAM_ONE, otherwise set it to blue.

GivePlayerWeapon(playerid, (IsMadnessEnabled()) ? WEAPON_MINIGUN : WEAPON_FLOWER, 5000);
// If IsMadnessEnabled is true, give the player a minigun!

public OnPlayerSpawn(playerid) {
    SetPlayerHealth(playerid, (IsSuddenDeathEnabled()) ? 1.0 : 100.0);
    if ((IsPlayerAdmin(playerid )) ? SetPlayerPos(playerid, AdminSpawnX, AdminSpawnY, AdminSpawnZ) : SetPlayerPos(playerid, PlayerSpawnX, PlayerSpawnY, PlayerSpawnZ)) { }
    // I have to wrap this inside an if statement to avoid getting a warning from the PAWN compiler!
}

file = fopen((useSpecialFile) ? ("special_file.txt") : ("normal_file.txt"));
// Strings need parentheses around them or the PAWN compiler will generate an error.

// You can also use ternary operators inside ternary operators!
file = fopen((useFile == 1) ? ("file1.txt") : ((useFile == 2) ? ("file2.txt") : ((useFile == 3) ? ("file3.txt") : ("file0.txt"))));

// ..let's break that down
    new File:file = fopen(
        ( useFile == 1 ) ? ("file1.txt")
            : ( ( useFile == 2 ) ? ("file2.txt")
                : ( ( useFile == 3 ) ? ("file3.txt")
                    : ("file0.txt") ) )
    );
	
if ( a == b )
    c = d;
else
    c = e;
	
c = ( a == b ) ? d : e;
//   if-^   then-^   ^-else

/*
	Integer To Boolean
*/

new 
    myInt = 50;
new 
    bool: myBool = !! myInt;
	
/*
	Fastest string loop
*/

for(new i, j = strlen(string); i != j; i++)
// Better than..
for(new i, j = sizeof(string); i != j; i++)

/*
	Fastest plain player-loop
*/

for ( new slots = GetMaxPlayers( ), i; i < slots; i++ )
{
    if ( !IsPlayerConnected( i ) )
        continue;
    
    // code for connected players
}
// My Code
for(new i, j = GetMaxPlayers(); i < j; i++) if(IsPlayerConnected(i))
{
	// code
}
#define playerLoop(%0,%1) for(new %0, %1 = GetMaxPlayers(); %0 < %1; %0++) if(IsPlayerConnected(%0))

/*
	Short Functions
*/

stock SomeFunction( someInput )
    return someArray[ someInput / 2 ];

/*
	Multiple action in one statement
*/

stock KickEx(playerid, reason[])
    SendClientMessage(playerid, 0xC00000FF, "You got kicked!! Reason:"), SendClientMessage(playerid, 0xC00000FF, reason), Kick(playerid);
// Sends the two client messages then kicks the player.

stock DoStuff(playerid)
    return DoFirstThing(playerid), DoSecondThing(playerid), DoThirdThing(playerid), DoLastThing(playerid);
// DoStuff will return what DoLastThing returns.

public OnPlayerRequestSpawn(playerid)
{
    if(!IsPlayerLoggedIn(playerid))
        return SendClientMessage(playerid, 0xC00000FF, "You're not logged in!"), 0;
    // Send the client message and return 0
    
    return 1;
}

/*
	Running code just after a function finishes
	
Explain:
	
This really isn't anything special, but I just thought I'd mention it as I haven't seen a lot of people do this.
I simply set a timer on 0 ms with no repeat somewhere and that function will be called almost right after the current function finished.

Why?
Sometimes you want to run code right after the current function finishes, here's a short example of a really handy function:
*/

stock DBResult:db_query_ex( DB:db, query[ ], bool:storeResult = true )
{
    new DBResult:dbrResult = db_query( db, query );
    
    if ( dbrResult )
    {
        if ( storeResult )
            SetTimerEx( "db_query_ex_free", 0, false, "i", _:dbrResult );
        else
            db_free_result( dbrResult );
    }
    
    return dbrResult;
}

forward db_query_ex_free( DBResult:dbrResult );
public  db_query_ex_free( DBResult:dbrResult )
    db_free_result( dbrResult );

// EXAMPLE:

public OnFilterScriptInit( )
{
    new DB:db, DBResult:dbrResult, buffer[ 16 ];
    
    db = db_open( "test.db" );
    
    dbrResult = db_query_ex( db, "SELECT 50" );
    
    db_get_field( dbrResult, 0, buffer, sizeof( buffer ) - 1 );
    
    print( buffer );
    
    // Even if the script would get some sort of error and abort running the current function,
    // the result will still get freed so you won't have a memory leak!
}

/* Using IsPlayerAdmin inside OnRconLoginAttempt doesn't work - the admin-status is set after that function executes. Example: */
new
    bool:g_IsRconAdmin[ MAX_PLAYERS ]
;

public OnPlayerConnect( playerid )
    g_IsRconAdmin[ playerid ] = false;

public OnRconLoginAttempt( ip[ ], password[ ], success ) // IsPlayerAdmin returns false if you check it inside this function. :(
    SetTimer( "CheckNewRconAdmins", 0, false );

forward CheckNewRconAdmins( );
public  CheckNewRconAdmins( )
{
    for ( new slots = GetMaxPlayers( ), playerid; playerid < slots; playerid++ )
    {
        if ( !g_IsRconAdmin[ playerid ] && IsPlayerAdmin( playerid ) )
        {
            // IsPlayerAdmin always returns false for unconnected players so we can save some performance by only calling that function.
            
            OnPlayerRconLogIn( playerid );
            
            break;
            // There should be at most new admin each function call, so we can break out of the loop now.
        }
    }
}

OnPlayerRconLogIn( playerid )
{
    SendClientMessage( playerid, 0x0000C0FF, "Welcome, Mr. Rcon!" );
}

/*
	Here's a part of a post by Y_Less explaining how he uses this:
		Quote:
		Originally Posted by Y_Less  
		I find this useful to apply a large set of operations at once. If you look in the YSI library YSI_td.own it can dynamically update textdraws, so you can move them about the screen or change the colour etc. If you have code which looks like this:

		pawn Code:
		TD_Colour(td, 0xFF0000AA);
		TD_SetShadow(td, 3);
		TD_Font(td, 2);

		That will change the textdraw for anyone looking at it to a red style 2 TD with a shadow, however because of the way the system used to work that would have redrawn the textdraw three times when it doesn't need to. The old method of fixing this was an extra parameter:

		pawn Code:
		TD_Colour(td, 0xFF0000AA, false);
		TD_SetShadow(td, 3, false);
		TD_Font(td, 2);

		So only the last update in a set would change the appearance, the new system however uses a timer in much the same way as you just described. All the functions contain this (or something similar):

		pawn Code:
		if (YSI_g_sTimer[td] == -1)
		{
			YSI_g_sTimer[td] = SetTimerEx("TD_Delay", 0, 0, "i", td);
		}

		That way the "TD_Delay" function is always called after the last current update is applied, without knowing a user's code in advance.
*/

/*
	Getting rid of stupid tag warnings
	
Explain:
	
When putting Text3Ds, DBResults, and stuff inside functions such as printf, format, SetTimerEx, CallLocalFunction, CallRemoteFunction you might notice you're getting a tag warning.
You're not doing anything wrong!
What you do to get rid of them is you clear the tag - clearing the tag is done by putting an underscore as a tag.
*/

new Text3D:t3dTest = Create3DTextLabel( .. ), Text:txTest = TextDrawCreate( .. );
printf( "DEBUG: %d, %d", _:t3dTest, _:txTest );

/*
	Char-arrays
*/
new bool:g_IsPlayerSomething[ MAX_PLAYERS ]; // 500 cells * 4 bytes per cell = 2000 bytes!
new bool:g_IsPlayerSomething[ MAX_PLAYERS char ]; // 500 bytes = .. 500 bytes!
public OnPlayerConnect(playerid)
{
    g_IsPlayerSomething{ playerid } = false;
//                     ^          ^
}

public OnPlayerSpawn(playerid)
{
//                          v          v
    if(g_IsPlayerSomething{ playerid } )
    {
        // ..
    }
}

/*
	Split up numeric literals
*/

345,234,148
//Here "," is used as a thousands separator (sometimes "." I believe, but PAWN uses that for decimal). You can also do this in PAWN using "'" instead:

345'234'148
//And you can split HEX numbers up every 4, or binary numbers every 8:
/*
0x12FD'39C5
0b00000000'11111111'01010101*/
//As you can see, the highlighter doesn't like this.

/*
	Bit-Flags in enums
*/

// Usage for all macros: BitFlag_X(variable, flag)
#define BitFlag_Get(%0,%1)            ((%0) & (%1))   // Returns zero (false) if the flag isn't set.
#define BitFlag_On(%0,%1)             ((%0) |= (%1))  // Turn on a flag.
#define BitFlag_Off(%0,%1)            ((%0) &= ~(%1)) // Turn off a flag.
#define BitFlag_Toggle(%0,%1)         ((%0) ^= (%1))  // Toggle a flag (swap true/false).

enum PlayerFlags:(<<= 1) {
    // It's important that you don't forget to put "= 1" on the first flag. If you don't, all flags will be 0.
    
    PLAYER_IS_LOGGED_IN = 1,   // 0b00000000000000000000000000000001
    PLAYER_HAS_GANG,           // 0b00000000000000000000000000000010
    PLAYER_CAN_BUY_PROPERTIES, // 0b00000000000000000000000000000100
    PLAYER_BLABLA_1,           // 0b00000000000000000000000000001000
    PLAYER_BLABLA_2,           // 0b00000000000000000000000000010000
    PLAYER_BLABLA_3,           // 0b00000000000000000000000000100000
    PLAYER_BLABLA_4,           // 0b00000000000000000000000001000000
    PLAYER_BLABLA_5,           // 0b00000000000000000000000010000000
    PLAYER_BLABLA_6,           // 0b00000000000000000000000100000000
    PLAYER_BLABLA_7,           // 0b00000000000000000000001000000000
    PLAYER_BLABLA_8,           // 0b00000000000000000000010000000000
    PLAYER_BLABLA_9,           // 0b00000000000000000000100000000000
    PLAYER_BLABLA_10,          // 0b00000000000000000001000000000000
    PLAYER_BLABLA_11,          // 0b00000000000000000010000000000000
    PLAYER_BLABLA_12,          // 0b00000000000000000100000000000000
    PLAYER_BLABLA_13,          // 0b00000000000000001000000000000000
    PLAYER_BLABLA_14,          // 0b00000000000000010000000000000000
    PLAYER_BLABLA_15,          // 0b00000000000000100000000000000000
    PLAYER_BLABLA_16,          // 0b00000000000001000000000000000000
    PLAYER_BLABLA_17,          // 0b00000000000010000000000000000000
    PLAYER_BLABLA_18,          // 0b00000000000100000000000000000000
    PLAYER_BLABLA_19,          // 0b00000000001000000000000000000000
    PLAYER_BLABLA_20,          // 0b00000000010000000000000000000000
    PLAYER_BLABLA_21,          // 0b00000000100000000000000000000000
    PLAYER_BLABLA_22           // 0b00000001000000000000000000000000
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

/*
	Using logical operators for tiny if-statements
*/

stock FIXES_valstr(dest[], value, bool:pack = false)
{
    static const cellmin_value[] = !"-2147483648";

    if (value == cellmin)
        pack && strpack(dest, cellmin_value, 12) || strunpack(dest, cellmin_value, 12);
    else
        format(dest, 12, "%d", value), pack && strpack(dest, dest, 12);
    // Notice the comma after format? See the section "Multiple actions in one statement" in this topic.
}
// Equal to:
stock FIXES_valstr(dest[], value, bool:pack = false)
{
    static const cellmin_value[] = !"-2147483648";

    if (value == cellmin) {
        if (pack)
            strpack(dest, cellmin_value, 12)
        else
            strunpack(dest, cellmin_value, 12);
    } else {
        format(dest, 12, "%d", value);
        
        if (pack)
            strpack(dest, dest, 12);
    }
}
// A few examples
a && b();              // if a, run b.
a && b() || c();       // if a, run b. otherwise, run c.
a || b();              // if not a, run b.
a && b() || c && d();  // if a, run b. otherwise, if c, run d.
a && b() && c();       // if a, run b. if b isn't false, run c.

/*
	Efficient memory management with stock const
*/
#include <a_samp>

main()
{
    print("hi");
    print("hi");
}
//If we compile this with "-a" we get:

Code:
CODE 0	; 0
;program exit point
	halt 0

	proc	; main
	; line 4
	; line 5
	push.c 0
	;$par
	push.c 4
	sysreq.c 0	; print
	stack 8
	;$exp
	; line 6
	push.c c
	;$par
	push.c 4
	sysreq.c 0	; print
	stack 8
	;$exp
	zero.pri
	retn


DATA 0	; 0
dump 68 69 0 68 69 0 

STKSIZE 1000

//I have highlighted two lines in bold. The first pushes the number "0", the second pushes the number "12" ("c"). 
//"print", for it's first (and only) parameter, takes the address of a string to print. 
//All string literals are converted to data and stored in global memory (I won't go in to the details of the true implications of this, but sufficed to say you change them). 
//"dump" is the current global memory for this tiny program:

Code:
dump 68 69 0 68 69 0
//If we convert those numbers to ascii we suddenly see:

Code:
dump 'h' 'i' '\0' 'h' 'i' '\0'

//I.e. our two "hi" strings - two copies of the same string isn't very efficient though, so let's improve this by explicitly managing the memory:

#include <a_samp>

stock const
    C_HI[3] = "hi";

main()
{
    print(C_HI);
    print(C_HI);
}

Code:
CODE 0	; 0
;program exit point
	halt 0


DATA 0	; 0
dump 68 69 0 

	proc	; main
	; line 7
	; line 8
	push.c 0
	;$par
	push.c 4
	sysreq.c 0	; print
	stack 8
	;$exp
	; line 9
	push.c 0
	;$par
	push.c 4
	sysreq.c 0	; print
	stack 8
	;$exp
	zero.pri
	retn


STKSIZE 1000
/*The location of "dump" has changed, but that's not important - a large program will have many "dump" statements spread throughout its code, all combined in the final stages of compilation. The important things to look at are the contents of "dump" and the two highlighted lines.

Despite the fact that we are using a variable, this is still EXACTLY as efficient code-wise as the original version because we are still using constant strings. However, the memory requirements for storing the two strings has halved, with both instances pointing to the same memory.

You can also use "new const" or "static stock const", but "stock const" is probably best for this code to avoid warnings and dupilcation of the memory we are trying not to duplicate.

Your assembly output will probably look different if you are not using "-d0".*/

/*
	(c) NOT operator ('!') to assign the "NOT value"
*/
sometimes using ternay operators to assign the not value of a variable.
this = (!this)? true : false;
OR:
if(this == true)
{
	this = false;
}
else
{
	this = true;
}
My Improvment:
this = !this;

Another code (with CLIENT-MESSAGE):
if(godmode == true)
{
	godmode = false;
	SendClientMessage(playerid, YELLOW, "Godmode is now off");
}
else
{
	godmode = true;
	SendClientMessage(playerid, YELLOW, "Godmode is now on");
}

// New Code:
godmode = !godmode;
SendClientMessage(playerid, YELLOW, "Godmode is now <SOME CUSTOM SPECIFIER>", godmode); // But if you set up a custom specifier in Slice's formatex, you can just do this:

OR - Formatted Message:
SendCMf(playerid, YELLOW, "Godmode is now %s", !godmode? ("off") : ("on"));

Advanced:
SendClientMessage(playerid, 0xFFFFFFFF, (godmode = !godmode) ? ("Godmode is now on.") : ("Godmode is now off."));
/*
	create iterative processes
*/
BEFORE:

TOTAL = sizeof(array);
i++;
if (i == TOTAL) i = 0;
array[i] = bblabla;

AFTER:

i = (i + 1) % TOTAL;
array[i] = blabla;

/*
	Efficiency back on Codes, etc.
*/
#define ZONE:%0(%1) \
    forward public ZONE_%0(%1); \
    public ZONE_%0(%1) // just a shortcut

new vid = GetPlayerVehicleID(playerid);
if(vid)
{
	printf("Player ID %d is in vehicle ID %d", playerid, vehicleid);
}
// more efficient than
if(GetPlayerVehicleID(playerid))
{
	printf("Player ID %d is in vehicle ID %d", playerid, GetPlayerVehicleID(playerid));
}

for(new i; i < MAX_PLAYERS; i++)
{
    if(IsPlayerConnected(i) && IsPlayerAdmin(i))
    {
        // something else
    }
}
// You don't need the player connection check there because if the player isn't connected, then they will never be an admin. This is true with all other native functions like that.

/*
	Show Dialogs whenever you want (nousing Ctrl+H)
*/
stock ShowDialog(playerid, type)
{
    switch(type)
    {
        case D_SOME_DIALOG:
        {
                     // Some dialog.
        }
    }
}

ShowDialog(playerid, D_SOME_DIALOG);

/*
	Printing once value
*/
	new iVar = 5,
		sVar[6] = "Hello";
		fVar = 0.0;
	print(iVar) && print(sVar) && print(fVar);
	// Not need printf

/*
	Create variables when necessary
*/
WRONG CODE:
new str[128], Float:armour; // declaring some variable which are needed to execute the command if player is admin BEFORE checking whether he/she is admin or not.
if(!IsPlayerAdmin(playerid))
{
    SendClientMessage(playerid, -1, "You aren't an admin!");
    // They aren't admins, so they won't use the cmd
    return 1; // stops the execution of the command. In other words it won't execute the rest code below
}
// Rest of code that will be executed if the player is an admin:
armour = 50.0;
SetPlayerArmour(playerid, armour);
format(str, sizeof str, "You've just been given a body armour (%f)!", armour);
SendClientMessage(playerid, -1, str);

GOOD CODE:
if(!IsPlayerAdmin(playerid))
{
    SendClientMessage(playerid, -1, "You aren't an admin!");
    return 1;
}
new Float:armour;
armour = 50.0;
SetPlayerArmour(playerid, armour);
new str[128];
format(str, sizeof str, "You've just been given a body armour (%f)!", armour);
SendClientMessage(playerid, -1, str);

/*
	"," Operator more effective than ";"
*/

OLD VERSION:
a = random(11);
b = random(11);
c = a + b;
d = a * b;
e = d - c;
printf("%d", e);

NEW VERSION:
a = random(11),
b = random(11),
c = a + b,
d = a * b,
e = d - c,
printf("%d", e);

OLD VRESION Output:
;$exp
; line a
break	; 78
const.pri b
push.pri
;$par
push.c 4
sysreq.c 0	; random
stack 8
stor.s.pri fffffffc
;$exp
; line b
break	; a8
const.pri b
push.pri
;$par
push.c 4
sysreq.c 0	; random
stack 8
stor.s.pri fffffff8
;$exp
; line c
break	; d8
load.s.pri fffffffc
push.pri
load.s.pri fffffff8
pop.alt
add
stor.s.pri fffffff4
;$exp
; line d
break	; 100
load.s.pri fffffffc
push.pri
load.s.pri fffffff8
pop.alt
smul
stor.s.pri fffffff0
;$exp
; line e
break	; 128
load.s.pri fffffff0
push.pri
load.s.pri fffffff4
pop.alt
sub.alt
stor.s.pri ffffffec
;$exp
; line f
break	; 150
addr.pri ffffffec
push.pri
;$par
zero.pri
push.pri
;$par
push.c 8
sysreq.c 1	; printf
stack c

NEW VERSION Output:
;$exp
; line 10
break	; 180
const.pri b
push.pri
;$par
push.c 4
sysreq.c 0	; random
stack 8
stor.s.pri fffffffc
;$exp
const.pri b
push.pri
;$par
push.c 4
sysreq.c 0	; random
stack 8
stor.s.pri fffffff8
;$exp
load.s.pri fffffffc
push.pri
load.s.pri fffffff8
pop.alt
add
stor.s.pri fffffff4
;$exp
load.s.pri fffffffc
push.pri
load.s.pri fffffff8
pop.alt
smul
stor.s.pri fffffff0
;$exp
load.s.pri fffffff0
push.pri
load.s.pri fffffff4
pop.alt
sub.alt
stor.s.pri ffffffec
;$exp
addr.pri ffffffec
push.pri
;$par
const.pri c
push.pri
;$par
push.c 8
sysreq.c 1	; printf
stack c
/*
	Best Ahraza
*/
forward public OnSomethingHappen(a, b, c);
/*
	Check variable value certain range of numbers
*/

if (variable >= 1 && variable <= 10)
if(10 < variable < 1)
if (1 <= variable <= 10)
/*
	........
	.........
	..........
	...........
*/
Y_Less:
No, define is very rarely better for functions. 
There are issues with defines when you use a parameter more than once, though in that specific example theres no issue. 
Additionally, if you use defines the code will be copied every time it is used, instead of being done once and jumped to.