params [
    ["_buyer", objNull, [objNull]],
    ["_requestId", "", [""]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]]
];

if (!isServer) exitWith { false };
if (_requestId isEqualTo "") exitWith { false };

private _ownerId = if (isNull _buyer) then { remoteExecutedOwner } else { owner _buyer };
private _sessionKey = format ["MWF_PendingVehiclePurchase_%1", _ownerId];
private _session = missionNamespace getVariable [_sessionKey, []];
if ((count _session) < 6) exitWith {
    ["Vehicle purchase failed. Pending placement session missing."] remoteExec ["systemChat", _ownerId];
    false
};

private _storedRequestId = _session param [0, "", [""]];
if !(_storedRequestId isEqualTo _requestId) exitWith {
    ["Vehicle purchase failed. Placement request mismatch."] remoteExec ["systemChat", _ownerId];
    false
};

private _className = _session param [1, "", [""]];
private _cost = _session param [2, 0, [0]];
private _minTier = _session param [3, 1, [0]];
private _requiredUnlock = _session param [4, "", [""]];
private _isTier5 = _session param [5, false, [false]];
if (_className isEqualTo "") exitWith {
    missionNamespace setVariable [_sessionKey, nil, false];
    ["Vehicle purchase failed. Pending session had no class."] remoteExec ["systemChat", _ownerId];
    false
};

private _debugMode = missionNamespace getVariable ["MWF_DebugMode", ((["MWF_Param_DebugMode", 0] call BIS_fnc_getParamValue) > 0)];
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
if (_debugMode) then {
    _supplies = 9999;
    _currentTier = 99;
    missionNamespace setVariable ["MWF_Economy_Supplies", 9999, true];
    missionNamespace setVariable ["MWF_Supplies", 9999, true];
    missionNamespace setVariable ["MWF_Supply", 9999, true];
    missionNamespace setVariable ["MWF_res_intel", 9999, true];
    missionNamespace setVariable ["MWF_Intel", 9999, true];
    missionNamespace setVariable ["MWF_Currency", 19998, true];
};

private _spawnVehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
if (isNull _spawnVehicle) exitWith {
    missionNamespace setVariable [_sessionKey, nil, false];
    if (!isNil "MWF_fnc_serverCancelVehiclePurchase") then {
        [_buyer, _requestId, "SPAWN_FAILED"] call MWF_fnc_serverCancelVehiclePurchase;
    };
    ["Vehicle purchase failed. Spawn returned null."] remoteExec ["systemChat", _ownerId];
    false
};

missionNamespace setVariable [_sessionKey, nil, false];

_spawnVehicle setVariable ["MWF_isBought", true, true];
_spawnVehicle setDir _dir;
_spawnVehicle allowDamage false;
clearWeaponCargoGlobal _spawnVehicle;
clearMagazineCargoGlobal _spawnVehicle;
clearItemCargoGlobal _spawnVehicle;
clearBackpackCargoGlobal _spawnVehicle;

if (_surfaceRule isEqualTo "WATER") then {
    _spawnVehicle setPosASL _posASL;
    _spawnVehicle setVectorUp [0, 0, 1];
} else {
    _spawnVehicle setPosASL _posASL;
    _spawnVehicle setVectorUp (surfaceNormal (ASLToATL _posASL));
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
private _respawnHeliClass = missionNamespace getVariable ["MWF_Respawn_Heli", ""];
if ((_respawnTruckClass isNotEqualTo "" && {_className isEqualTo _respawnTruckClass}) || (_respawnHeliClass isNotEqualTo "" && {_className isEqualTo _respawnHeliClass})) then {
    [_spawnVehicle] call MWF_fnc_initMobileRespawn;
    [if (_className isEqualTo _respawnHeliClass) then {"Respawn Helicopter deployed."} else {"Mobile Respawn Unit deployed."}] remoteExec ["systemChat", _ownerId];
};

[_spawnVehicle] spawn {
    params ["_veh"];
    uiSleep 0.5;
    if (!isNull _veh) then {
        _veh allowDamage true;
    };
};

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newSupplies = if (_debugMode) then {9999} else {_supplies};

if (!isNil "MWF_fnc_syncEconomyState") then {
    [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
    missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
    remoteExec ["MWF_fnc_updateResourceUI", -2];
};

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", _ownerId];
if (_debugMode) then {
    [format ["DEBUG: Vehicle placed at %1", mapGridPosition (ASLToATL _posASL)]] remoteExec ["systemChat", _ownerId];
};
true
