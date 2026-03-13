/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Deletes linked FOB assets and restores the transport vehicle/box.
    Language: English
*/

if (!isServer) exitWith {};

params [
    ["_target", objNull, [objNull]], // Typically the Command PC
    ["_className", "", [""]]        // The vehicle or box class to restore
];

if (isNull _target || _className == "") exitWith { 
    diag_log "[KPIN ERROR]: Invalid repack parameters."; 
};

// 1. AUTHORIZATION CHECK
// Ensure the Commander has toggled the repack authorization
private _canRepack = _target getVariable ["KPIN_FOB_CanRepack", false];
if (!_canRepack) exitWith {
    ["TaskFailed", ["", "Repack not authorized by Commander!"]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

private _pos = getPosATL _target;
private _dir = getDir _target;
private _marker = _target getVariable ["KPIN_FOB_Marker", ""];

// 2. COLLECT LINKED ASSETS
private _locker = _target getVariable ["KPIN_AttachedLocker", objNull];
private _siren  = _target getVariable ["KPIN_AttachedSiren", objNull];
private _table  = attachedTo _target; // Laptop is usually attached to the table

// 3. REGISTRY CLEANUP
if (_marker != "") then {
    ["REMOVE", _marker] call KPIN_fnc_baseManager;
    deleteMarker _marker;
};

// 4. THE CLEAN SWEEP
// Delete the core assets
{
    if (!isNull _x) then { deleteVehicle _x };
} forEach [_target, _locker, _siren, _table];

// Delete optional assets (Camo net/Roof)
private _roofClass = missionNamespace getVariable ["KPIN_FOB_Asset_Roof", ""];
if (_roofClass != "") then {
    private _roofs = nearestObjects [_pos, [_roofClass], 15];
    { deleteVehicle _x } forEach _roofs;
};

// 5. RESTORE TRANSPORT VEHICLE
// We use "CAN_COLLIDE" to ensure it spawns exactly where the FOB was
private _newObject = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

// Re-initialize the vehicle so it can be deployed again
[_newObject] call KPIN_fnc_initFOB
