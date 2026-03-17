/*
    Author: Theane / ChatGPT
    Function: fn_deployFOB
    Project: Military War Framework

    Description:
    Server-side FOB deployment pipeline. Converts a deployable truck/container into
    a live FOB terminal and attached assets, then registers it for persistence.
*/

if (!isServer) exitWith {objNull};

params [
    ["_sourceObject", objNull, [objNull]],
    ["_overridePosASL", [], [[]]],
    ["_overrideDir", -1, [0]],
    ["_displayName", "", [""]],
    ["_originType", "AUTO", [""]],
    ["_isRestore", false, [true]]
];

private _posAsl = if (!(_overridePosASL isEqualTo []) && {count _overridePosASL >= 2}) then {
    _overridePosASL
} else {
    if (isNull _sourceObject) exitWith {[]};
    getPosASL _sourceObject
};
if (_posAsl isEqualTo []) exitWith {objNull};

private _dir = if (_overrideDir >= 0) then { _overrideDir } else {
    if (isNull _sourceObject) then { 0 } else { getDir _sourceObject }
};

if (_originType == "AUTO") then {
    if (!isNull _sourceObject && {typeOf _sourceObject == (missionNamespace getVariable ["MWF_FOB_Truck", ""])}) then {
        _originType = "TRUCK";
    } else {
        _originType = "BOX";
    };
};

private _assetRoof     = missionNamespace getVariable ["MWF_FOB_Asset_Roof", ""];
private _assetTable    = missionNamespace getVariable ["MWF_FOB_Asset_Table", "Land_CampingTable_small_F"];
private _assetTerminal = missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"];
private _assetSiren    = missionNamespace getVariable ["MWF_FOB_Asset_Siren", "Land_Loudspeakers_F"];
private _assetLocker   = missionNamespace getVariable ["MWF_FOB_Asset_Locker", "Prop_Locker_01_F"];
private _assetLamp     = missionNamespace getVariable ["MWF_FOB_Asset_Lamp", ""];

if (!isNull _sourceObject) then {
    deleteVehicle _sourceObject;
};

private _posAtl = ASLToATL _posAsl;

private _table = createVehicle [_assetTable, _posAtl, [], 0, "CAN_COLLIDE"];
_table setDir _dir;
_table setPosASL _posAsl;
_table allowDamage false;

private _roofObj = objNull;
if (_assetRoof != "") then {
    _roofObj = createVehicle [_assetRoof, _posAtl, [], 0, "CAN_COLLIDE"];
    _roofObj setDir _dir;
    _roofObj setPosASL _posAsl;
    _roofObj enableSimulationGlobal false;
    _roofObj allowDamage false;
};

private _laptop = createVehicle [_assetTerminal, _posAtl, [], 0, "CAN_COLLIDE"];
_laptop attachTo [_table, [0, 0, 0.6]];
_laptop setVariable ["MWF_isCommandPC", true, true];
_laptop setVariable ["MWF_isFOB", true, true];
_laptop setVariable ["MWF_FOB_OriginType", _originType, true];
_laptop setVariable ["MWF_isUnderAttack", false, true];
_laptop setVariable ["MWF_FOB_CanRepack", false, true];
_laptop setVariable ["MWF_FOB_IsDamaged", false, true];
_laptop setVariable ["MWF_FOB_RepairCost", 0, true];
_laptop setVariable ["MWF_FOB_DespawnDeadline", -1, true];
_laptop allowDamage false;
[_laptop] remoteExec ["MWF_fnc_initCommandPC", 0, true];

private _siren = objNull;
if (_assetSiren != "") then {
    private _sirenPos = [ASLToATL _posAsl, 8, _dir + 45] call BIS_fnc_relPos;
    _siren = createVehicle [_assetSiren, _sirenPos, [], 0, "NONE"];
    _siren setDir (_dir + 180);
    _siren enableSimulationGlobal false;
    _siren allowDamage false;
};

private _locker = objNull;
if (_assetLocker != "") then {
    private _lockerPos = [ASLToATL _posAsl, 4, _dir - 110] call BIS_fnc_relPos;
    _locker = createVehicle [_assetLocker, _lockerPos, [], 0, "NONE"];
    _locker setDir (_dir + 70);
    _locker allowDamage false;

    if (!isNil "MWF_fnc_initFOBInventory") then {
        [_locker] remoteExec ["MWF_fnc_initFOBInventory", 0, true];
    };
};

private _lamp = objNull;
if (_assetLamp != "") then {
    private _lampPos = [ASLToATL _posAsl, 6, _dir + 135] call BIS_fnc_relPos;
    _lamp = createVehicle [_assetLamp, _lampPos, [], 0, "NONE"];
    _lamp setDir _dir;
    _lamp allowDamage false;
};

_laptop setVariable ["MWF_AttachedTable", _table, true];
_laptop setVariable ["MWF_AttachedRoof", _roofObj, true];
_laptop setVariable ["MWF_AttachedSiren", _siren, true];
_laptop setVariable ["MWF_AttachedLocker", _locker, true];
_laptop setVariable ["MWF_AttachedLamp", _lamp, true];

private _registration = [_laptop, _displayName, _originType, !_isRestore] call MWF_fnc_registerFOB;
private _markerName = _registration param [0, ""];
private _resolvedName = _registration param [1, "FOB"];

_laptop addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile"];

    if (_unit getVariable ["MWF_FOB_IsDamaged", false]) exitWith {0.89};

    if (_unit getVariable ["MWF_isUnderAttack", false]) then {
        if (!isNil "MWF_fnc_fobAttackSystem") then {
            ["HANDLE_DAMAGE", _unit, _damage, _source] call MWF_fnc_fobAttackSystem
        } else {
            _damage
        }
    } else {
        0
    };
}];

_laptop addEventHandler ["Killed", {
    params ["_unit"];
    [_unit] spawn {
        params ["_terminal"];

        if (_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {};

        [_terminal, "", true] call MWF_fnc_unregisterFOB;

        {
            if (!isNull _x) then {
                deleteVehicle _x;
            };
        } forEach [
            _terminal getVariable ["MWF_AttachedRoof", objNull],
            _terminal getVariable ["MWF_AttachedSiren", objNull],
            _terminal getVariable ["MWF_AttachedLocker", objNull],
            _terminal getVariable ["MWF_AttachedLamp", objNull],
            _terminal getVariable ["MWF_AttachedTable", objNull]
        ];

        uiSleep 10;
        deleteVehicle _terminal;
    };
}];

if (!_isRestore) then {
    ["TaskSucceeded", ["", format ["%1 deployed and active.", _resolvedName]]] remoteExec ["BIS_fnc_showNotification", 0];
};

diag_log format ["[MWF FOB] %1 deployed at %2 (origin: %3, marker: %4).", _resolvedName, _posAsl, _originType, _markerName];

if (!_isRestore) then {
    [] spawn {
        uiSleep 10;

        private _currentStage = missionNamespace getVariable ["MWF_current_stage", 0];
        if (_currentStage == 1) then {
            [] call MWF_fnc_generateInitialMission;
            diag_log "[MWF FOB] Tutorial mission advanced to post-deploy stage.";
        } else {
            diag_log format ["[MWF FOB] Tutorial mission post-deploy trigger skipped. Current stage: %1.", _currentStage];
        };
    };
};

_laptop
