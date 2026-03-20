/*
    Author: Theane / ChatGPT
    Function: fn_restoreSession
    Project: Military War Framework

    Description:
    Restores runtime-persistent session entities after strategic state and presets are online.
    This pass intentionally runs after presetManager so preset-defined classes such as MRU trucks
    can be reinitialized safely without boot-order races.
*/

if (!isServer) exitWith { false };
if (missionNamespace getVariable ["MWF_SessionVehiclesRestored", false]) exitWith { true };

private _pendingVehicles = + (missionNamespace getVariable ["MWF_PendingBoughtVehicles", []]);
if (_pendingVehicles isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_SessionVehiclesRestored", true, true];
    true
};

private _restoredCount = 0;
private _failedCount = 0;
{
    _x params [
        ["_className", "", [""]],
        ["_posASL", [0, 0, 0], [[]]],
        ["_vectorDir", [0, 1, 0], [[]]],
        ["_vectorUp", [0, 0, 1], [[]]],
        ["_damage", 0, [0]],
        ["_fuel", 1, [0]],
        ["_isMRU", false, [true]]
    ];

    if (_className isNotEqualTo "") then {
        private _veh = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
        if (isNull _veh) then {
            _failedCount = _failedCount + 1;
            diag_log format ["[MWF Persistence] Failed to restore vehicle class %1.", _className];
        } else {

    _veh setVariable ["MWF_isBought", true, true];
    _veh allowDamage false;
    _veh setPosASL _posASL;
    _veh setVectorDirAndUp [_vectorDir, _vectorUp];
    _veh setFuel (_fuel max 0 min 1);
    _veh setDamage (_damage max 0 min 1);

    if (_isMRU) then {
        _veh setVariable ["MWF_isMobileRespawn", true, true];
        [_veh] call MWF_fnc_initMobileRespawn;
    };

    [_veh] spawn {
        params ["_restoredVeh"];
        uiSleep 0.5;
        if (!isNull _restoredVeh) then {
            _restoredVeh allowDamage true;
        };
    };

            _restoredCount = _restoredCount + 1;
        };
    };
} forEach _pendingVehicles;

missionNamespace setVariable ["MWF_PendingBoughtVehicles", [], true];
missionNamespace setVariable ["MWF_SessionVehiclesRestored", true, true];
missionNamespace setVariable ["MWF_LastRestoreSummary", [_restoredCount, _failedCount], true];

diag_log format ["[MWF Persistence] Restored %1 bought vehicle(s). Failed: %2.", _restoredCount, _failedCount];
true
