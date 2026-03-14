// Author: Gemini / Theane
// Project: Mission War Framework

/*
    Description:
    Main loop for checking player undercover status and proximity-based restrictions.
    Checks if players are wearing blacklisted items and if they are within base range (500m).
*/

if (!isServer) exitWith {}; // Ensure this loop only runs on the server

[] spawn {
    while {true} do {
        {
            private _player = _x;
            
            // 1. Run the Undercover and Blacklist check
            // This updates MWF_SaveLoadout_Enabled and checks against MWF_Undercover_Blacklist
            [_player] call MWF_fnc_checkUndercover;

            // 2. Base Proximity Check (MOB/FOB)
            // Logic: Save/Arsenal/Build is only allowed within MWF_Base_Radius (500m)
            private _nearBase = false;
            private _bases = [getMarkerPos "MWF_MOB"]; // Always include Main Operating Base
            
            // Add all active FOB positions to the check
            if (!isNil "MWF_Active_FOBs") then {
                _bases append MWF_Active_FOBs;
            };

            // Check if player is near any base
            {
                if (_player distance _x < MWF_Base_Radius) exitWith { _nearBase = true; };
            } forEach _bases;

            // 3. Apply Restrictions based on Proximity
            if (_nearBase) then {
                _player setVariable ["MWF_Player_InServiceZone", true, true];
            } else {
                _player setVariable ["MWF_Player_InServiceZone", false, true];
                
                // If the player leaves the zone, we force-disable loadout saving
                // regardless of their uniform status.
                _player setVariable ["MWF_SaveLoadout_Allowed", false, true];
            };

        } forEach allPlayers;

        sleep 5; // Scan interval
    };
};
