/* Author: Theeane
    Description: 
    Makes an informant-soldier wave at NATO players to offer basic intel.
*/
params ["_unit"];

if (!isServer) exitWith {};

while {alive _unit} do {
    // Find nearby NATO players who are NOT undercover and have weapons lowered
    private _targetPlayer = (allPlayers select {
        _x distance _unit < 15 && 
        !(_x getVariable ["GVAR_isUndercover", false]) && 
        currentWeapon _x == ""
    }) # 0;

    if (!isNil "_targetPlayer") then {
        // Play the wave animation
        [_unit, "GestureHi"] remoteExec ["playActionNow", 0];
        
        // Short cooldown to prevent animation spam
        sleep 10;
    };
    sleep 5;
};
