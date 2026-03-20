/*
    Author: Theane / ChatGPT
    Function: MWF_fn_upgradeBaseTier
    Project: Military War Framework

    Description:
    Upgrades the base tier using the authoritative Supplies pool.
*/

if (!isServer) exitWith { [_this select 0, _this select 1] remoteExecCall ["MWF_fnc_upgradeBaseTier", 2]; };

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

private _upgradeCosts = [0, 1500, 3500];
private _nextTier = _currentTier + 1;

if (_currentTier >= 3) exitWith {
    ["TaskFailed", ["", "Base is already at Maximum Tier (3)."]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

private _cost = _upgradeCosts select _currentTier;
if (_supplies < _cost) exitWith {
    private _msg = format ["Insufficient Supplies! Need %1 for Tier %2 upgrade.", _cost, _nextTier];
    [_msg] remoteExec ["systemChat", remoteExecutedOwner];
};

_supplies = _supplies - _cost;
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
missionNamespace setVariable ["MWF_CurrentTier", _nextTier, true];

if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

[
    "TaskSucceeded",
    ["", format ["Base Upgraded to Tier %1! New assets unlocked.", _nextTier]]
] remoteExec ["BIS_fnc_showNotification", -2];

if (_nextTier == 3) then {
    diag_log "[MWF] Economy: Strategic Assets (Tier 3) are now online.";
};

if (!isNil "MWF_fnc_updateBuyCategory") then {
    ["Infantry"] remoteExec ["MWF_fnc_updateBuyCategory", -2];
};

diag_log format ["[MWF] Economy: Base upgraded to Tier %1. Cost: %2 Supplies.", _nextTier, _cost];
