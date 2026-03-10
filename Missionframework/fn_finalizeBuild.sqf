/*
    Author: Theane (AGS Project)
    Description: Server-side finalization of the build.
    Language: English
*/

if (!isServer) exitWith {};
params ["_className", "_pos", "_dir", "_price"];

// Deduct resources
private _current = missionNamespace getVariable ["AGS_res_supplies", 0];
missionNamespace setVariable ["AGS_res_supplies", (_current - _price), true];

// Spawn the real object
private _vehicle = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_vehicle setDir _dir;
_vehicle setPosATL _pos;

// If it's a new FOB Box, add the Unpack Action
if (_className == "B_Slingload_01_Cargo_F") then {
    [_vehicle] remoteExec ["AGS_fnc_setupFOBAction", 0, true];
};

diag_log format ["AGS Build: %1 spawned at %2 for %3 supplies.", _className, _pos, _price];
