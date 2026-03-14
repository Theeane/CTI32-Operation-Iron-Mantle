sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

// Start the undercover checking loop for all players
[] spawn {
    while {true} do {
        // Check undercover status for all players
        {[_x] call MWF_fnc_checkUndercover;} forEach allPlayers;
        sleep 5; // Check every 5 seconds
    };
};
