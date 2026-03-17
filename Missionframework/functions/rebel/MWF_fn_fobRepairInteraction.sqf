/*
    Author: Theane / ChatGPT
    Function: fn_fobRepairInteraction
    Project: Military War Framework

    Description:
    Adds and processes the damaged FOB repair interaction.

    Modes:
    - ATTACH         : add client-side hold action
    - REMOVE         : remove client-side hold action
    - PROCESS_REPAIR : server-side repair logic
*/

params [
    ["_mode", "ATTACH", [""]],
    ["_terminal", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (_mode == "ATTACH") exitWith {
    if (!hasInterface) exitWith {};
    if (isNull _terminal) exitWith {};
    if !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {};

    private _existingId = _terminal getVariable ["MWF_FOB_RepairActionId", -1];
    if (_existingId >= 0) exitWith {};

    private _cost = _terminal getVariable ["MWF_FOB_RepairCost", 0];
    private _actionId = [
        _terminal,
        format ["<t color='#ffaa00'>Repair FOB Terminal (%1 Supplies)</t>", _cost],
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_repair_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_repair_ca.paa",
        "_this distance _target < 3 && (_target getVariable ['MWF_FOB_IsDamaged', false])",
        "_caller distance _target < 3",
        {},
        {},
        {
            params ["_target", "_caller"];
            ["PROCESS_REPAIR", _target, _caller] remoteExec ["MWF_fnc_fobRepairInteraction", 2];
        },
        {},
        [],
        5,
        0,
        true,
        false
    ] call BIS_fnc_holdActionAdd;

    _terminal setVariable ["MWF_FOB_RepairActionId", _actionId];
};

if (_mode == "REMOVE") exitWith {
    if (!hasInterface) exitWith {};
    if (isNull _terminal) exitWith {};

    private _actionId = _terminal getVariable ["MWF_FOB_RepairActionId", -1];
    if (_actionId >= 0) then {
        [_terminal, _actionId] call BIS_fnc_holdActionRemove;
        _terminal setVariable ["MWF_FOB_RepairActionId", -1];
    };
};

if (!isServer) exitWith {};
if (_mode != "PROCESS_REPAIR") exitWith {};
if (isNull _terminal || {isNull _caller}) exitWith {};
if (!alive _terminal) exitWith {};
if !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {};
if ((_caller distance _terminal) > 5) exitWith {};

private _repairCost = _terminal getVariable ["MWF_FOB_RepairCost", 0];
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
private _intel = missionNamespace getVariable ["MWF_res_intel", 0];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

if (_supplies < _repairCost) exitWith {
    [format ["Insufficient Supplies. Required: %1 | Available: %2", _repairCost, _supplies]] remoteExec ["systemChat", owner _caller];
};

[_supplies - _repairCost, _intel, _notoriety] call MWF_fnc_syncEconomyState;

_terminal setVariable ["MWF_FOB_IsDamaged", false, true];
_terminal setVariable ["MWF_FOB_RepairCost", 0, true];
_terminal setVariable ["MWF_FOB_DespawnDeadline", -1, true];
_terminal setVariable ["MWF_isUnderAttack", false, true];
_terminal allowDamage false;
_terminal setDamage 0;

missionNamespace setVariable ["MWF_isUnderAttack", false, true];
missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];

private _damaged = missionNamespace getVariable ["MWF_DamagedFOBs", []];
private _terminalPos = getPosASL _terminal;
_damaged = _damaged select {
    private _savedPos = _x param [0, []];
    !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance2D _terminalPos <= 5})
};
missionNamespace setVariable ["MWF_DamagedFOBs", _damaged, true];

["REMOVE", _terminal] remoteExec ["MWF_fnc_fobRepairInteraction", 0, true];

private _displayName = _terminal getVariable ["MWF_FOB_DisplayName", "FOB"];
[format ["%1 terminal repaired. FOB operations restored.", _displayName]] remoteExec ["systemChat", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format ["[MWF Rebel] %1 repaired by %2 for %3 supplies.", _displayName, name _caller, _repairCost];
