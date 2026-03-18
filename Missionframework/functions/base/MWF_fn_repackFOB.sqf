/*
    Author: Theane / ChatGPT
    Function: fn_repackFOB
    Project: Military War Framework

    Description:
    Server-side FOB repack pipeline. Cleans up the FOB composition, unregisters it,
    and restores the requested transport form.
*/

if (!isServer) exitWith {objNull};

params [
    ["_target", objNull, [objNull]],
    ["_repackTarget", "TRUCK", [""]]
];

if (isNull _target) exitWith {objNull};

private _canRepack = _target getVariable ["MWF_FOB_CanRepack", false];
if (!_canRepack) exitWith {
    ["TaskFailed", ["", "Repack not authorized by Commander!"]] remoteExec ["BIS_fnc_showNotification", 0];
    objNull
};

private _className = switch (toUpper _repackTarget) do {
    case "TRUCK": { missionNamespace getVariable ["MWF_FOB_Truck", "B_Truck_01_Repair_F"] };
    case "BOX": { missionNamespace getVariable ["MWF_FOB_Box", "B_Slingload_01_Cargo_F"] };
    default { _repackTarget };
};

if (_className isEqualTo "") exitWith { objNull };

private _originType = if ((toUpper _repackTarget) in ["TRUCK", "BOX"]) then {
    toUpper _repackTarget
} else {
    if (_className == (missionNamespace getVariable ["MWF_FOB_Truck", ""])) then { "TRUCK" } else { "BOX" };
};

private _posAsl = getPosASL _target;
private _dir = getDir _target;
private _marker = _target getVariable ["MWF_FOB_Marker", ""];

[_target, _marker, true] call MWF_fnc_unregisterFOB;

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach [
    _target getVariable ["MWF_AttachedRoof", objNull],
    _target getVariable ["MWF_AttachedSiren", objNull],
    _target getVariable ["MWF_AttachedLamp", objNull],
    _target getVariable ["MWF_AttachedTable", objNull],
    _target
];

private _newObject = createVehicle [_className, ASLToATL _posAsl, [], 0, "CAN_COLLIDE"];
_newObject setDir _dir;
_newObject setPosASL _posAsl;
_newObject setVariable ["MWF_FOB_Type", _originType, true];

[_newObject] remoteExec ["MWF_fnc_initFOB", 0, true];

["TaskSucceeded", ["", "FOB repacked and ready for transport."]] remoteExec ["BIS_fnc_showNotification", 0];

diag_log format ["[MWF FOB] Repacked FOB at %1 into %2.", _posAsl, _className];

_newObject
