/*
    Author: Theeane / Gemini Guide
    Function: MWF_fnc_executeRepack
    Project: Military War Framework
    Description: 
    Handles the physical repacking of a FOB. 
    Deletes the composition and spawns the designated transport container/vehicle.
*/

params [
    ["_fobObject", objNull, [objNull]],
    ["_repackType", "box", [""]] // "box" or "truck"
];

if (isNull _fobObject) exitWith { diag_log "[MWF] Repack Error: FOB Object is null"; };

private _pos = getPosATL _fobObject;
private _dir = getDir _fobObject;

// 1. Remove the FOB object and its interactions
[_fobObject] call MWF_fnc_unregisterFOB;
deleteVehicle _fobObject;

// 2. Create the new entity based on repackType
private _newObject = objNull;

if (_repackType == "truck") then {
    // Spawn a transport truck (e.g., HEMTT or equivalent from preset)
    private _truckClass = missionNamespace getVariable ["MWF_Preset_FOBTruck", "B_Truck_01_box_F"];
    _newObject = createVehicle [_truckClass, _pos, [], 0, "NONE"];
} else {
    // Spawn a box/container
    private _boxClass = missionNamespace getVariable ["MWF_Preset_FOBBox", "B_Slingload_01_Cargo_F"];
    _newObject = createVehicle [_boxClass, _pos, [], 0, "NONE"];
};

_newObject setDir _dir;
_newObject setPosATL _pos;

// 3. Initialize the object so it can be deployed again later
[_newObject] remoteExec ["MWF_fnc_setupFOBAction", 0, true];

[format ["FOB repacked into %1.", _repackType]] remoteExec ["systemChat", 0];

diag_log format [" [MWF] Base: FOB at %1 repacked into %2", _pos, typeOf _newObject];

true
