/*
    Author: Theane / ChatGPT
    Function: fn_civRep
    Project: Military War Framework

    Description:
    Handles civilian reputation, threshold penalties, and rebel leader escalation.
*/

if (!isServer) exitWith {};

params [
    ["_mode", "ADJUST"],
    ["_amount", 0]
];

if (_mode == "ADJUST") exitWith {
    private _oldRep = missionNamespace getVariable ["MWF_CivRep", 0];
    private _newRep = ((_oldRep + _amount) max -100) min 100;
    private _rebelThreshold = missionNamespace getVariable ["MWF_CivRep_Threshold_Rebel", -30];

    missionNamespace setVariable ["MWF_CivRep", _newRep, true];

    if (_newRep <= -25 && {_oldRep > -25}) then {
        private _penalties = missionNamespace getVariable ["MWF_RepPenaltyCount", 0];
        missionNamespace setVariable ["MWF_RepPenaltyCount", _penalties + 1, true];
        diag_log format ["[KPIN REP]: Penalty threshold reached. Total Penalties: %1", _penalties + 1];
        ["SAVE"] call MWF_fnc_saveManager;
    };

    if (
        _newRep <= _rebelThreshold &&
        {_oldRep > _rebelThreshold} &&
        {!missionNamespace getVariable ["MWF_RebelLeaderEventActive", false]}
    ) then {
        if (!isNil "MWF_fnc_rebelLeaderSystem") then {
            ["TRIGGER", [], "CIV_REP_THRESHOLD"] spawn MWF_fnc_rebelLeaderSystem;
        };
    };

    if (abs _amount >= 5) then {
        ["SAVE"] call MWF_fnc_saveManager;
    };

    diag_log format ["[KPIN REP]: Adjusted by %1. Current: %2", _amount, _newRep];
};

if (_mode == "GET_BRIBE_COST") exitWith {
    private _penalties = (missionNamespace getVariable ["MWF_RepPenaltyCount", 0]) max 0;
    private _baseCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Base", 30];
    private _maxCost = missionNamespace getVariable ["MWF_RebelLeaderCost_Max", 1000];
    (_baseCost * (2 ^ _penalties)) min _maxCost
};

if (_mode == "RESET") exitWith {
    missionNamespace setVariable ["MWF_CivRep", 0, true];
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];

    if (!isNil "MWF_fnc_rebelManager") then {
        ["REFRESH_ZONES"] spawn MWF_fnc_rebelManager;
    };

    ["SAVE"] call MWF_fnc_saveManager;
    diag_log "[KPIN REP]: Reputation reset to 0. Peace has been bought.";
};
