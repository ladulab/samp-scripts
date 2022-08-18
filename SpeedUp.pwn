#include <a_samp>
/*
	#define SPEED_MULTIPLIER 1.025
	#define SPEED_THRESHOLD  0.4
*/
new g_SpeedUpTimer = -1, Float: g_SpeedThreshold, PLAYER_SLOTS;
new const KEY_VEHICLE_FORWARD = 0b001000,
		  KEY_VEHICLE_BACKWARD = 0b100000
;

new Float: Speed_MPTH[2] = {1.025, 0.4};

public OnFilterScriptInit() {
    PLAYER_SLOTS = GetMaxPlayers();  
    g_SpeedUpTimer = SetTimer("SpeedUp", 220, true);   
    g_SpeedThreshold = Speed_MPTH[2] * Speed_MPTH[2];
}

public OnFilterScriptExit() KillTimer(g_SpeedUpTimer);

// Speed Up ON: g_SpeedUpTimer = SetTimer("SpeedUp", 220, true);
// Speed UP OFF: KillTimer(g_SpeedUpTimer);
// Speed Up Multiplier Change: Speed_MPTH[0] = New Value (Maximum Value: 3.5)
// Reset All Settings: Speed_MPTH[0] = 1.025, Speed_MPTH[1] = 0.4;

forward public SpeedUp();
public SpeedUp() 
{
	new vehicleid, keys, Float:vp[3];
    for (new i = 0; i < PLAYER_SLOTS; i++) 
	{
        if (!IsPlayerConnected(i)) 
			continue;
			
        if ((vehicleid = GetPlayerVehicleID(i))) 
		{
            GetPlayerKeys(i, keys, _:vp[0], _:vp[1]);           
            if ((keys & (KEY_VEHICLE_FORWARD | KEY_VEHICLE_BACKWARD | KEY_HANDBRAKE)) == KEY_VEHICLE_FORWARD) 
			{
				GetVehicleVelocity(vehicleid, vp[0], vp[1], vp[2]);
                 if (vx * vx + vy * vy < g_SpeedThreshold) continue;
				 
                vx *= Speed_MPTH[0];
                vy *= Speed_MPTH[0];         
                if (vz > 0.04 || vz < -0.04) 
					vz -= 0.020;         
                SetVehicleVelocity(vehicleid, vx, vy, vz);
            }
        }
    }
}