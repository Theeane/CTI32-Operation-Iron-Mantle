/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_executeRepack
    Project: Military War Framework

    Description:
    Handles the physical repacking of a FOB on the server.
    Deletes the terminal and attached assets, unregisters the loadout zone,
    and spawns the designated transport truck or box.
*/

if (!isServer) exitWith {};

params [
    ["_fobObject", objNull, [objNull]],
    ["_repackType", "box", [""]],
    ["_caller", objNull, [objNull]]
];

if (isNull _fobObject) exitWith {
    diag_log "[MWF] Repack Error: FOB Object is null.";
};

private _canRepack = _fobObject getVariable ["MWF_FOB_CanRepack", true];
if (!_canRepack) exitWith {
    ["TaskFailed", ["", "Repack not authorized by Commander!"]] remoteExec ["BIS_fnc_showNotification", 0];
    diag_log "[MWF] Repack aborted: Unauthorized by variable.";
};

private _pos = getPosATL _fobObject;
private _dir = getDir _fobObject;

[_fobObject] call MWF_fnc_unregisterLoadoutZone;

{
    private _attached = _fobObject getVariable [_x, objNull];
    if (!isNull _attached) then { deleteVehicle _attached; };
} forEach ["MWF_AttachedRoof", "MWF_AttachedSiren", "MWF_AttachedLamp", "MWF_AttachedTable", "MWF_AttachedLocker"];

[_fobObject] call MWF_fnc_unregisterFOB;
deleteVehicle _fobObject;

private _assetOptions = missionNamespace getVariable ["MWF_FOB_AssetOptions", []];
private _className = "";

if ((toLower _repackType) == "truck") then {
    if (_assetOptions isEqualType [] && {count _assetOptions > 0}) then {
        _className = ((_assetOptions select 0) param [1, "", [""]]);
    };
    if (_className isEqualTo "") then {
        _className = missionNamespace getVariable ["MWF_FOB_Truck", "B_Truck_01_box_F"];
    };
} else {
    if (_assetOptions isEqualType [] && {count _assetOptions > 1}) then {
        _className = ((_assetOptions select 1) param [1, "", [""]]);
    };
    if (_className isEqualTo "") then {
        _className = missionNamespace getVariable ["MWF_FOB_Box", "B_Slingload_01_Cargo_F"];
    };
};

private _spawnPos = +_pos;
if (!isNull _caller) then {
    private _callerPos = getPosATL _caller;
    private _callerDir = getDir _caller;
    private _candidate = [_callerPos, 20, _callerDir] call BIS_fnc_relPos;
    private _safe = [_candidate, 5, 18, 8, 0, 0.25, 0] call BIS_fnc_findSafePos;
    if !(_safe isEqualTo [] || {_safe isEqualTo [0,0,0]}) then {
        _spawnPos = _safe;
    } else {
        _spawnPos = _candidate;
    };
};

private _newObject = createVehicle [_className, _spawnPos, [], 0, "CAN_COLLIDE"];
_newObject setDir _dir;
_newObject setPosATL _spawnPos;

[_newObject] remoteExec ["MWF_fnc_initFOB", 0, true];

[format ["FOB repacked into %1.", _repackType]] remoteExec ["systemChat", 0];
diag_log format ["[MWF] Base: FOB at %1 repacked into %2 (%3) at %4.", _pos, _repackType, _className, _spawnPos];

true
