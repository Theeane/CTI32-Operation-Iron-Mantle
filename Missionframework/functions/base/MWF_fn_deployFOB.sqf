/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_deployFOB
    Project: Military War Framework

    Description:
    Server-side FOB deployment pipeline. Converts a deployable truck/container into
    a live FOB terminal and attached assets, then registers it for persistence.
    Also registers the FOB loadout/arsenal zone.
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

if (!_isRestore) then {
    private _canDeploy = ["CAN_DEPLOY", [ASLToATL _posAsl]] call MWF_fnc_baseManager;
    if (!_canDeploy) exitWith {
        if (!isNull _sourceObject) then {
            _sourceObject setVariable ["MWF_FOB_PlacementInProgress", false, true];
        };
        diag_log format ["[MWF FOB] Deployment rejected at %1.", _posAsl];
        objNull
    };
};

if (!isNull _sourceObject) then {
    if (_sourceObject == (missionNamespace getVariable ["MWF_InitialFOBAssetRef", objNull])) then {
        missionNamespace setVariable ["MWF_InitialFOBAssetRef", objNull, true];
    };
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
    private _lockerPos = [ASLToATL _posAsl, 2.5, _dir + 180] call BIS_fnc_relPos;
    _locker = createVehicle [_assetLocker, _lockerPos, [], 0, "NONE"];
    _locker setDir _dir;
    _locker allowDamage false;
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

private _zoneRadius = missionNamespace getVariable ["MWF_FOB_DeploymentRadius", 50];
[_laptop, _zoneRadius, _resolvedName] call MWF_fnc_registerLoadoutZone;

[_laptop] remoteExec ["MWF_fnc_initCommandPC", 0, true];

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

        [_terminal] call MWF_fnc_unregisterLoadoutZone;
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
    _laptop setVariable ["MWF_FOB_PlacementInProgress", false, true];

    private _campaignPhase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
    private _currentStage = missionNamespace getVariable ["MWF_current_stage", 0];
    if (_campaignPhase isEqualTo "TUTORIAL" || {_currentStage <= 1}) then {
        [2] call MWF_fnc_generateInitialMission;
        diag_log "[MWF FOB] Tutorial mission advanced to supply-run stage.";
    };
};

_laptop
