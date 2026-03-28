/*
    Author: Theeane / Gemini Guide
    Function: MWF_fn_executeRepack
    Project: Military War Framework
    Description: 
    Handles the physical repacking of a FOB. 
    Deletes the composition, cleans up attached assets, and spawns the 
    designated transport (truck or box).
*/

if (!isServer) exitWith {};

params [
    ["_fobObject", objNull, [objNull]],
    ["_repackType", "box", [""]] // "box" or "truck"
];

if (isNull _fobObject) exitWith { 
    diag_log "[MWF] Repack Error: FOB Object is null"; 
};

// 1. Safety Check: Is repacking authorized by the Commander?
private _canRepack = _fobObject getVariable ["MWF_FOB_CanRepack", true];
if (!_canRepack) exitWith {
    ["TaskFailed", ["", "Repack not authorized by Commander!"]] remoteExec ["BIS_fnc_showNotification", 0];
    diag_log "[MWF] Repack aborted: Unauthorized by variable.";
};

private _pos = getPosATL _fobObject;
private _dir = getDir _fobObject;

// 2. Cleanup attached assets to prevent floating objects
{
    private _attached = _fobObject getVariable [_x, objNull];
    if (!isNull _attached) then { deleteVehicle _attached };
} forEach ["MWF_AttachedRoof", "MWF_AttachedSiren", "MWF_AttachedLamp", "MWF_AttachedTable"];

// 3. Unregister the FOB from the system and delete the main building
[_fobObject] call MWF_fnc_unregisterFOB;
deleteVehicle _fobObject;

// 4. Create the new entity based on repackType
private _newObject = objNull;
private _className = "";

if ((toLower _repackType) == "truck") then {
    // Retrieve truck classname from presets
    _className = missionNamespace getVariable ["MWF_Preset_FOBTruck", "B_Truck_01_box_F"];
} else {
    // Retrieve box/container classname from presets
    _className = missionNamespace getVariable ["MWF_Preset_FOBBox", "B_Slingload_01_Cargo_F"];
};

_newObject = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

// 5. Initialize the object for future deployment (ACE actions, etc.)
[_newObject] remoteExec ["MWF_fnc_setupFOBAction", 0, true];

// 6. Player feedback
[format ["FOB repacked into %1.", _repackType]] remoteExec ["systemChat", 0];

diag_log format ["[MWF] Base: FOB at %1 repacked into %2 (%3)", _pos, _repackType, _className];

true