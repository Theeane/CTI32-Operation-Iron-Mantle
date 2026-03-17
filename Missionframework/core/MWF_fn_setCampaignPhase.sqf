/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setCampaignPhase
    Project: Military War Framework

    Description:
    Server-authoritative campaign phase transition helper.
    Handles global phase changes for tutorial gating and forces an immediate hard save.

    Valid phases:
    - TUTORIAL
    - SUPPLY_RUN
    - OPEN_WAR
*/

if (!isServer) exitWith { false };

params [
    ["_newPhase", "TUTORIAL", [""]],
    ["_reason", "Campaign Phase Transition", [""]]
];

if !(_newPhase in ["TUTORIAL", "SUPPLY_RUN", "OPEN_WAR"]) exitWith {
    diag_log format ["[MWF Phase] Ignored invalid campaign phase: %1", _newPhase];
    false
};

private _currentPhase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
if (_currentPhase isEqualTo _newPhase) exitWith { true };

missionNamespace setVariable ["MWF_Campaign_Phase", _newPhase, true];

switch (_newPhase) do {
    case "TUTORIAL": {
        missionNamespace setVariable ["MWF_current_stage", 1, true];
    };
    case "SUPPLY_RUN": {
        missionNamespace setVariable ["MWF_current_stage", 2, true];
    };
    case "OPEN_WAR": {
        missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
        missionNamespace setVariable ["MWF_current_stage", 3, true];
    };
};

diag_log format ["[MWF Phase] %1 -> %2 (%3)", _currentPhase, _newPhase, _reason];

if (!isNil "MWF_fnc_saveGame") then {
    [format ["%1: %2 -> %3", _reason, _currentPhase, _newPhase]] call MWF_fnc_saveGame;
} else {
    diag_log "[MWF Phase] Warning: saveGame unavailable during phase transition.";
};

true
