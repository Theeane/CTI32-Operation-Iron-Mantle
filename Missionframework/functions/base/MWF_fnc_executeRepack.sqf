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
    ["_repackType", "box", [""]]
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

private _newObject = createVehicle [_className, _pos, [], 0, "CAN_COLLIDE"];
_newObject setDir _dir;
_newObject setPosATL _pos;

[_newObject] remoteExec ["MWF_fnc_initFOB", 0, true];

[format ["FOB repacked into %1.", _repackType]] remoteExec ["systemChat", 0];
diag_log format ["[MWF] Base: FOB at %1 repacked into %2 (%3).", _pos, _repackType, _className];

true
