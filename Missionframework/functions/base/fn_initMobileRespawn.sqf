/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Initializes an object as a Mobile Respawn point. 
    Checks for movement and life status before allowing redeploy.
    Language: English
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {};

// Mark the object as a mobile respawn point
_object setVariable ["KPIN_isMobileRespawn", true, true];

// Add a marker that follows the vehicle (optional, but good for clarity)
private _mkr = createMarker [format["mkr_respawn_%1", round(random 9999)], getPosATL _object];
_mkr setMarkerType "b_inf";
_mkr setMarkerColor "ColorGreen";
_mkr setMarkerText "Mobile Respawn";

// Logic to keep the marker updated and check status
[_object, _mkr] spawn {
    params ["_obj", "_mkr"];
    
    while {alive _obj} do {
        _mkr setMarkerPos (getPosATL _obj);
        
        // If it's a truck, maybe it only works when parked?
        if (speed _obj > 2) then {
            _mkr setMarkerAlpha 0.3; // Dim it when moving
            _obj setVariable ["KPIN_respawnAvailable", false, true];
        } else {
            _mkr setMarkerAlpha 1;
            _obj setVariable ["KPIN_respawnAvailable", true, true];
        };
        sleep 5;
    };
    
    deleteMarker _mkr;
};
