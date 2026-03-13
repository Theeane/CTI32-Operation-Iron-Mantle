/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Initializes an object as a Mobile Respawn point. 
                 Syncs with the global redeploy list and handles movement logic.
    Language: English
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {};

// 1. SET VARIABLES
_object setVariable ["KPIN_isMobileRespawn", true, true];
_object setVariable ["KPIN_isUnderAttack", false, true]; // Needed for redeploy logic consistency

// 2. CREATE MARKER
private _mkrName = format["mkr_respawn_%1", round(random 9999)];
private _mkr = createMarker [_mkrName, getPosATL _object];
_mkr setMarkerType "b_motor_inf"; // Changed to motor_inf icon to differentiate from FOBs
_mkr setMarkerColor "ColorGreen";
_mkr setMarkerText "Mobile Respawn";

// 3. MONITOR LOOP
[_object, _mkr] spawn {
    params ["_obj", "_mkr"];
    
    while {alive _obj} do {
        _mkr setMarkerPos (getPosATL _obj);
        
        // Logical condition: Respawn only works when stationary
        private _isStationary = (speed _obj < 2);
        _obj setVariable ["KPIN_respawnAvailable", _isStationary, true];

        if (_isStationary) then {
            _mkr setMarkerAlpha 1;
            _mkr setMarkerText "Mobile Respawn (READY)";
        } else {
            _mkr setMarkerAlpha 0.5;
            _mkr setMarkerText "Mobile Respawn (MOVING...)";
        };

        sleep 3; // Slightly faster update for moving vehicles
    };
    
    deleteMarker _mkr;
};
