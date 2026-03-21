/*
    Author: Theane / ChatGPT
    Function: fn_restoreBuiltUpgradeStructures
    Project: Military War Framework

    Description:
    Restores physical base-upgrade structures after FOBs and presets are online.
    This covers MOB heli/jet structures and base-local virtual garages.
*/

if (!isServer) exitWith { false };
if (missionNamespace getVariable ["MWF_BuiltUpgradeStructuresRestored", false]) exitWith { true };

private _pending = + (missionNamespace getVariable ["MWF_PendingBuiltUpgradeStructures", []]);
if (_pending isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];
    true
};

private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];

private _restoredCount = 0;
private _failedCount = 0;
{
    _x params [
        ["_className", "", [""]],
        ["_posASL", [0, 0, 0], [[]]],
        ["_vectorDir", [0, 1, 0], [[]]],
        ["_vectorUp", [0, 0, 1], [[]]],
        ["_damage", 0, [0]]
    ];

    if (_className isEqualTo "") then {
        _failedCount = _failedCount + 1;
    } else {
        if !(_className in [_heliClass, _jetClass, _garageClass]) then {
            _failedCount = _failedCount + 1;
            diag_log format ["[MWF Persistence] Skipping unknown built upgrade class %1.", _className];
        } else {
            private _obj = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
            if (isNull _obj) then {
                _failedCount = _failedCount + 1;
                diag_log format ["[MWF Persistence] Failed to restore built upgrade class %1.", _className];
            } else {
                _obj setPosASL _posASL;
                _obj setVectorDirAndUp [_vectorDir, _vectorUp];
                _obj setDamage (_damage max 0 min 1);

                if (_className isEqualTo _garageClass) then {
                    _obj setVariable ["MWF_isVirtualGarage", true, true];
                    _obj allowDamage false;
                    private _ok = ["REGISTER_BUILD", _obj, objNull, 0] call MWF_fnc_garageSystem;
                    if (!_ok) then {
                        if (!isNull _obj) then { deleteVehicle _obj; };
                        _failedCount = _failedCount + 1;
                    } else {
                        _restoredCount = _restoredCount + 1;
                    };
                } else {
                    _restoredCount = _restoredCount + 1;
                };
            };
        };
    };
} forEach _pending;

missionNamespace setVariable ["MWF_PendingBuiltUpgradeStructures", [], true];
missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];
missionNamespace setVariable ["MWF_LastBuiltUpgradeRestoreSummary", [_restoredCount, _failedCount], true];

diag_log format ["[MWF Persistence] Restored %1 built upgrade structure(s). Failed: %2.", _restoredCount, _failedCount];
true
