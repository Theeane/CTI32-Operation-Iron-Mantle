/*
    Author: Theane / ChatGPT
    Function: fn_rebelLeaderDialogue
    Project: Military War Framework

    Description:
    Client-side interaction setup for the rebel leader plus server-side negotiation handling.

    Modes:
    - ATTACH              : add actions to the leader on clients
    - PROCESS_NEGOTIATION : process payment on the server
*/

params [
    ["_mode", "ATTACH", [""]],
    ["_leader", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (_mode == "ATTACH") exitWith {
    if (!hasInterface) exitWith {};
    if (isNull _leader) exitWith {};
    if (!alive _leader) exitWith {};
    if ((_leader getVariable ["MWF_RebelDialogueActionIds", []]) isNotEqualTo []) exitWith {};

    private _cost = _leader getVariable ["MWF_RebelNegotiationCost", 30];
    private _spawnLabel = _leader getVariable ["MWF_RebelSpawnLabel", "the area"];
    private _targetFob = _leader getVariable ["MWF_RebelTargetFOBName", "your FOB"];
    private _actionIds = [];

    _actionIds pushBack (
        _leader addAction [
            "<t color='#cccc66'>[ REBEL LEADER ] Hear terms</t>",
            {
                params ["_target", "_caller"];
                private _costLocal = _target getVariable ["MWF_RebelNegotiationCost", 30];
                private _spawnLabelLocal = _target getVariable ["MWF_RebelSpawnLabel", "the area"];
                private _targetFobLocal = _target getVariable ["MWF_RebelTargetFOBName", "your FOB"];
                hint format [
                    "The rebel leader speaks quietly:\n\n'The people remember %1. Pay %2 Intel and this dies here.\n\nShoot me, and every cell still loyal to me marches on %3.'",
                    _spawnLabelLocal,
                    _costLocal,
                    _targetFobLocal
                ];
            },
            nil,
            6,
            true,
            true,
            "",
            "_this distance _target < 3 && alive _target && !(_target getVariable ['MWF_RebelLeaderResolved', false])"
        ]
    );

    _actionIds pushBack (
        _leader addAction [
            format ["<t color='#ffaa00'>[ REBEL LEADER ] Pay %1 Intel</t>", _cost],
            {
                params ["_target", "_caller"];
                ["PROCESS_NEGOTIATION", _target, _caller] remoteExec ["MWF_fnc_rebelLeaderDialogue", 2];
            },
            nil,
            5,
            true,
            true,
            "",
            "_this distance _target < 3 && alive _target && !(_target getVariable ['MWF_RebelLeaderResolved', false])"
        ]
    );

    _leader setVariable ["MWF_RebelDialogueActionIds", _actionIds];
};

if (!isServer) exitWith {};
if (_mode != "PROCESS_NEGOTIATION") exitWith {};
if (isNull _leader || {isNull _caller}) exitWith {};
if (!alive _leader) exitWith {};
if !(_leader getVariable ["MWF_IsRebelLeader", false]) exitWith {};
if ((_caller distance _leader) > 6) exitWith {};
if (_leader getVariable ["MWF_RebelLeaderResolved", false]) exitWith {};

private _activeLeader = missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull];
if (!isNull _activeLeader && {_activeLeader != _leader}) exitWith {};

private _cost = _leader getVariable ["MWF_RebelNegotiationCost", missionNamespace getVariable ["MWF_RebelLeaderCost_Base", 30]];
private _intel = missionNamespace getVariable ["MWF_res_intel", 0];

if (_intel < _cost) exitWith {
    [format ["Insufficient Intel. Required: %1 | Available: %2", _cost, _intel]] remoteExec ["systemChat", owner _caller];
};

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies, _intel - _cost, _notoriety] call MWF_fnc_syncEconomyState;

missionNamespace setVariable ["MWF_CivRep", 0, true];
missionNamespace setVariable ["MWF_RebelLeaderSettlementCount", (missionNamespace getVariable ["MWF_RebelLeaderSettlementCount", 0]) + 1, true];
missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];

_leader setVariable ["MWF_RebelLeaderResolved", true, true];
private _label = _leader getVariable ["MWF_RebelSpawnLabel", "the area"];
private _grp = group _leader;

deleteVehicle _leader;
if (!isNull _grp && {{alive _x} count units _grp == 0}) then {
    deleteGroup _grp;
};

missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];

private _msg = format ["Deal struck at %1. Civilian reputation reset to neutral at the cost of %2 Intel.", _label, _cost];
[_msg] remoteExec ["systemChat", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format ["[MWF Rebel] Negotiation completed by %1. Intel spent: %2.", name _caller, _cost];
