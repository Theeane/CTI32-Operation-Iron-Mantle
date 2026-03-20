/*
    Author: OpenAI / ChatGPT
    Function: fn_restoreActiveMainOperation
    Project: Military War Framework

    Description:
    Rehydrates an active main operation after persistence load by recreating its task chain,
    restoring transient operation context, and resuming the runtime monitor.
*/

if (!isServer) exitWith { false };

private _savedState = + (missionNamespace getVariable ["MWF_PendingGrandOperationState", []]);
if (_savedState isEqualTo []) exitWith { true };
if (count _savedState < 10) exitWith {
    missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
    false
};

_savedState params [
    ["_key", "", [""]],
    ["_savedTitle", "", [""]],
    ["_placement", [], [[]]],
    ["_savedFnName", "", [""]],
    ["_savedPosition", [0, 0, 0], [[]]],
    ["_savedPhaseIndex", 0, [0]],
    ["_startedElapsed", 0, [0]],
    ["_opDetected", false, [true]],
    ["_radarsDestroyed", 0, [0]],
    ["_heliDiscount", 1, [0]]
];

if (_key isEqualTo "") exitWith {
    missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
    false
};

private _registry = [] call MWF_fnc_getMainOperationRegistry;
private _entryIndex = _registry findIf { (_x # 0) isEqualTo _key };
if (_entryIndex < 0) exitWith {
    missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
    diag_log format ["[MWF Main Operations] Restore failed. Registry entry missing for %1.", _key];
    false
};

private _entry = _registry # _entryIndex;
_entry params [
    ["_entryKey", _key, [""]],
    ["_registryTitle", _savedTitle, [""]],
    "_description",
    ["_registryFnName", _savedFnName, [""]]
];

private _fnName = if (_savedFnName isNotEqualTo "") then { _savedFnName } else { _registryFnName };
private _title = if (_savedTitle isNotEqualTo "") then { _savedTitle } else { _registryTitle };
private _position = if (_savedPosition isEqualTo []) then {
    + (_placement param [1, [0, 0, 0], [[]]])
} else {
    + _savedPosition
};

private _fn = missionNamespace getVariable [_fnName, objNull];
if (isNil "_fn" || {_fn isEqualTo objNull}) exitWith {
    missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
    diag_log format ["[MWF Main Operations] Restore failed. Function missing for %1 (%2).", _key, _fnName];
    false
};

private _sequence = switch (toUpper _key) do {
    case "SKY_GUARDIAN": { [["Task_SkyGuardian_S1", "MID_1"], ["Task_SkyGuardian_S2", "END"], ["Task_SkyGuardian_S3", "COMPLETE"]] };
    case "POINT_BLANK": { [["Task_PointBlank_S1", "MID_1"], ["Task_PointBlank_S2", "MID_2"], ["Task_PointBlank_S3", "MID_3"], ["Task_PointBlank_S4", "END"], ["Task_PointBlank_S5", "COMPLETE"]] };
    case "SEVERED_NERVE": { [["Task_SeveredNerve_S1", "MID_1"], ["Task_SeveredNerve_S2", "MID_2"], ["Task_SeveredNerve_S3", "MID_3"], ["Task_SeveredNerve_S4", "END"], ["Task_SeveredNerve_S5", "COMPLETE"]] };
    case "STASIS_STRIKE": { [["Task_StasisStrike_S1", "MID_1"], ["Task_StasisStrike_S2", "MID_2"], ["Task_StasisStrike_S3", "END"], ["Task_StasisStrike_S4", "COMPLETE"]] };
    case "STEEL_RAIN": { [["Task_SteelRain_S1", "MID"], ["Task_SteelRain_S2", "END"], ["Task_SteelRain_S3", "COMPLETE"]] };
    case "APEX_PREDATOR": { [["Task_Apex_S1", "MID_1"], ["Task_Apex_S2", "MID_2"], ["Task_Apex_S3", "MID_3"], ["Task_Apex_S4", "END"], ["Task_Apex_S5", "COMPLETE"]] };
    default { [] };
};
if (_sequence isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
    diag_log format ["[MWF Main Operations] Restore failed. Sequence missing for %1.", _key];
    false
};

private _phaseIndex = (_savedPhaseIndex max 0) min ((((count _sequence) - 1) max 0));
missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
missionNamespace setVariable ["MWF_CurrentGrandOperation", _key, true];
missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _title, true];
missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", + _placement, true];
missionNamespace setVariable ["MWF_MainOperationRestoreMode", true, true];

["START", _position] call _fn;
for "_i" from 0 to (_phaseIndex - 1) do {
    private _stateName = (_sequence # _i) param [1, "", [""]];
    if (_stateName isNotEqualTo "") then {
        [_stateName, _position] call _fn;
    };
};

missionNamespace setVariable ["MWF_MainOperationRestoreMode", false, true];
missionNamespace setVariable ["MWF_Op_Detected", _opDetected, true];
missionNamespace setVariable ["MWF_SkyGuardian_RadarsDestroyed", _radarsDestroyed max 0, true];
missionNamespace setVariable ["MWF_Perk_HeliDiscount", (_heliDiscount max 0.01) min 10, true];

private _startedAt = serverTime - (_startedElapsed max 0);
["RESTORE", [_key, _fnName, _title, _position, _phaseIndex, _startedAt]] call MWF_fnc_mainOperationRuntime;
missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];

diag_log format ["[MWF Main Operations] Restored active operation %1 at phase index %2.", _key, _phaseIndex];
true
