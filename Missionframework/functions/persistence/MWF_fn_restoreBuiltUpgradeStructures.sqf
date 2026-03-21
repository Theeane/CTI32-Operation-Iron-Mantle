/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_restoreBuiltUpgradeStructures
    Project: Military War Framework

    Description:
    Restores physical base-upgrade structures after presets are loaded.
*/

if (!isServer) exitWith { false };
if (missionNamespace getVariable ["MWF_BuiltUpgradeStructuresRestored", false]) exitWith { true };

private _pending = + (missionNamespace getVariable ["MWF_PendingBuiltUpgradeStructures", []]);
if (_pending isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", [], true];
    missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];
    true
};

private _registry = [];
private _restored = 0;

{
    _x params [
        ["_upgradeId", "", [""]],
        ["_className", "", [""]],
        ["_posASL", [0, 0, 0], [[]]],
        ["_vectorDir", [0, 1, 0], [[]]],
        ["_vectorUp", [0, 0, 1], [[]]],
        ["_damage", 0, [0]]
    ];

    if (_className isNotEqualTo "") then {
        private _obj = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
        if (!isNull _obj) then {
            _obj allowDamage false;
            _obj setPosASL _posASL;
            _obj setVectorDirAndUp [_vectorDir, _vectorUp];
            _obj setDamage (_damage max 0 min 1);
            _obj setVariable ["MWF_isPhysicalBaseUpgrade", true, true];
            _obj setVariable ["MWF_UpgradeId", toUpper _upgradeId, true];
            _obj setVariable ["MWF_BaseKey", "MOB", true];
            _registry pushBack [toUpper _upgradeId, _obj, _className];
            _restored = _restored + 1;
        };
    };
} forEach _pending;

missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", _registry, true];
missionNamespace setVariable ["MWF_PendingBuiltUpgradeStructures", [], true];
missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", true, true];

diag_log format ["[MWF Persistence] Restored %1 physical base upgrade structure(s).", _restored];
true
