/*
    Author: Theane / ChatGPT
    Function: fn_signalPlayer
    Project: Military War Framework

    Description:
    Handles signal player for the interactions system.
*/

params ["_unit"];

if (!isServer) exitWith {};

while {alive _unit} do {
    // Look for ANY player within 15 meters
    private _candidates = allPlayers select {
        _x distance _unit < 15 &&
        currentWeapon _x == ""
    };
    private _targetPlayer = if (_candidates isEqualTo []) then { objNull } else { _candidates # 0 };

    if (!isNull _targetPlayer) then {
        // Play wave animation
        [_unit, "GestureHi"] remoteExec ["playActionNow", 0];
        
        // Random chance for a low whistle sound or subtle shout
        if (random 100 < 25) then {
            // Placeholder for a 3D sound if you add custom audio later
            // _unit say3D "whistle"; 
        };
        
        sleep 12; // Cooldown
    };
    sleep 5;
};
