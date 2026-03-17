/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_confirmVehiclePlacement
    Project: Military War Framework

    Description:
    Confirms preset-driven ghost placement.
    Client branch validates and forwards the build request to the server.
    Server branch performs final resource validation, spawns the real vehicle, syncs resources,
    and auto-initializes preset-defined Mobile Respawn Units.
*/

params [
    ["_className", "", [""]],
    ["_cost", -1, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]]
];

if (hasInterface && {_className isEqualTo ""}) exitWith {
    if !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) exitWith { false };

    private _isValid = missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false];
    if (!_isValid) exitWith {
        systemChat (missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."]);
        false
    };

    private _payload = [
        missionNamespace getVariable ["MWF_VehiclePlacement_Class", ""],
        missionNamespace getVariable ["MWF_VehiclePlacement_Cost", 0],
        missionNamespace getVariable ["MWF_VehiclePlacement_MinTier", 1],
        missionNamespace getVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player],
        missionNamespace getVariable ["MWF_VehiclePlacement_LastDir", getDir player],
        (missionNamespace getVariable ["MWF_VehiclePlacement_Profile", ["LAND", "LAND"]]) param [1, "LAND"]
    ];

    [] call MWF_fnc_cleanupVehiclePlacement;
    _payload remoteExec ["MWF_fnc_confirmVehiclePlacement", 2];
    systemChat "Vehicle build request sent to server.";
    true
};

if (!isServer) exitWith { false };
if (_className isEqualTo "") exitWith { false };

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];

if (_supplies < _cost) exitWith {
    [format ["Vehicle purchase failed. Need %1 supplies.", _cost]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

if (_currentTier < _minTier) exitWith {
    [format ["Vehicle purchase failed. Tier %1 required.", _minTier]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

private _spawnVehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
_spawnVehicle setVariable ["MWF_isBought", true, true];
_spawnVehicle allowDamage false;
_spawnVehicle setDir _dir;

if (_surfaceRule isEqualTo "WATER") then {
    private _spawnASL = +_posASL;
    _spawnVehicle setPosASL _spawnASL;
    _spawnVehicle setVectorUp [0, 0, 1];
} else {
    private _spawnATL = ASLToATL _posASL;
    _spawnATL set [2, 0.2];
    _spawnVehicle setPosATL _spawnATL;
    _spawnVehicle setVectorUp surfaceNormal _spawnATL;
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
if (_respawnTruckClass isNotEqualTo "" && {_className isEqualTo _respawnTruckClass}) then {
    [_spawnVehicle] call MWF_fnc_initMobileRespawn;
    ["Mobile Respawn Unit deployed."] remoteExec ["systemChat", remoteExecutedOwner];
};

[_spawnVehicle] spawn {
    params ["_veh"];
    uiSleep 0.5;
    if (!isNull _veh) then { _veh allowDamage true; };
};

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_notoriety", 0];
private _newSupplies = (_supplies - _cost) max 0;

if (!isNil "MWF_fnc_syncEconomyState") then {
    [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
    missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
    remoteExec ["MWF_fnc_updateResourceUI", 0];
};

if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", remoteExecutedOwner];
diag_log format ["[MWF VehiclePlacement] Spawned %1 for %2 supplies at %3.", _className, _cost, _posASL];

true
