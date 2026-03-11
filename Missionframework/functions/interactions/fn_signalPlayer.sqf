/* Author: Theeane
    Description: 
    Makes an informant-soldier wave at any player nearby, 
    regardless of their clothing/side.
*/
params ["_unit"];

if (!isServer) exitWith {};

while {alive _unit} do {
    // Look for ANY player within 15 meters
    private _targetPlayer = (allPlayers select {
        _x distance _unit < 15 && 
        currentWeapon _x == "" // Player must have weapon lowered to be signaled
    }) # 0;

    if (!isNil "_targetPlayer") then {
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
