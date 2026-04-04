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
private _buyerName = if (isNull _buyer) then { format ["owner_%1", _ownerId] } else { name _buyer };
private _sessionKey = format ["MWF_PendingVehiclePurchase_%1", _ownerId];

private _dbg = {
    params ["_message", ["_notifyBuyer", false, [false]]];
    private _line = format ["[MWF VEHICLE DBG][FINALIZE][owner:%1][buyer:%2][req:%3] %4", _ownerId, _buyerName, _requestId, _message];
    diag_log _line;
    missionNamespace setVariable ["MWF_VehiclePurchase_LastDebug", _line, true];
    if (_notifyBuyer) then {
        [_line] remoteExecCall ["systemChat", _ownerId];
    };
};

[format ["received finalize request pos=%1 dir=%2 surface=%3", _posASL, _dir, _surfaceRule], true] call _dbg;

private _session = missionNamespace getVariable [_sessionKey, []];
if ((count _session) < 6) exitWith {
    ["Vehicle placement failed. No pending purchase found."] remoteExec ["systemChat", _ownerId];
    ["no pending session found", true] call _dbg;
    false
};

private _storedRequestId = _session param [0, "", [""]];
if (_storedRequestId isNotEqualTo _requestId) exitWith {
    ["Vehicle placement failed. Purchase session mismatch."] remoteExec ["systemChat", _ownerId];
    [format ["request mismatch stored=%1", _storedRequestId], true] call _dbg;
    false
};

private _className = _session param [1, "", [""]];
private _reservedCost = _session param [2, 0, [0]];
if (_className isEqualTo "") exitWith {
    ["Vehicle placement failed. Invalid purchase data."] remoteExec ["systemChat", _ownerId];
    ["invalid class in session", true] call _dbg;
    false
};

[format ["spawning class=%1 reservedCost=%2", _className, _reservedCost], true] call _dbg;

private _spawnVehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
if (isNull _spawnVehicle) exitWith {
    missionNamespace setVariable [_sessionKey, nil, false];

    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
    private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    private _newSupplies = _supplies + _reservedCost;

    [format ["spawn returned null; refunding suppliesBefore=%1 reservedCost=%2 newSupplies=%3", _supplies, _reservedCost, _newSupplies], true] call _dbg;

    if (!isNil "MWF_fnc_syncEconomyState") then {
        [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
    } else {
        missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
        missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
        missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
        missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
        remoteExec ["MWF_fnc_updateResourceUI", -2];
    };

    ["Vehicle purchase failed. Spawn returned null. Supplies refunded."] remoteExec ["systemChat", _ownerId];
    false
};

missionNamespace setVariable [_sessionKey, nil, false];
["session consumed; vehicle created successfully", true] call _dbg;

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

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", _ownerId];
true
