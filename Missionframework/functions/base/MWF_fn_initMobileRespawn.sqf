/*
    Author: Theeane / Gemini Guide
    Function: MWF_fn_initMobileRespawn
    Project: Military War Framework

    Description:
    Initializes a vehicle as a mobile respawn point.
    Sets the required network variables and adds the map marker.
*/

params [["_vehicle", objNull, [objNull]]];

if (isNull _vehicle) exitWith {
    diag_log "[MWF] Error: initMobileRespawn called with null vehicle.";
};

// 1. Mark the vehicle as a mobile respawn globally
_vehicle setVariable ["MWF_isMobileRespawn", true, true];

// 2. Add to the global registry (if needed for cleanup/tracking)
private _currentRespawns = missionNamespace getVariable ["MWF_allMobileRespawns", []];
_currentRespawns pushBackUnique _vehicle;
missionNamespace setVariable ["MWF_allMobileRespawns", _currentRespawns, true];

// 3. Visual feedback/Map markers
// We call the marker refresh logic to ensure it shows up on the map
if (!isNil "MWF_fnc_refreshFOBMarkers") then {
    [] remoteExec ["MWF_fnc_refreshFOBMarkers", 0, true];
};

diag_log format ["[MWF] System: Mobile Respawn initialized on %1", typeOf _vehicle];

true
