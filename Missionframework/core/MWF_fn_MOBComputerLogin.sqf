/*
    Author: Theane / ChatGPT
    Function: MWF_fn_MOBComputerLogin
    Project: Military War Framework

    Description:
    Global campaign-phase-driven MOB computer login bridge.
    Tutorial repetition is controlled by MWF_Campaign_Phase, not by individual players.

    Phase behavior:
    - TUTORIAL   -> show / re-request Stage 1 (Deploy FOB)
    - SUPPLY_RUN -> show / re-request Stage 2 until the supply milestone is complete
    - OPEN_WAR   -> full terminal access for any player after login hold action
*/

params [
    ["_target", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _caller) exitWith { false };
if (!hasInterface) exitWith { false };
if (!local _caller) exitWith { false };

private _campaignPhase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
private _supplyRunDone = missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false];
private _currentStage = missionNamespace getVariable ["MWF_current_stage", 0];

private _showPlayerUI = {
    if (!hasInterface) exitWith {};
    cutRsc ["MWF_ResourceBar", "PLAIN"];
    if (!isNil "MWF_fnc_updateResourceUI") then {
        [] spawn MWF_fnc_updateResourceUI;
    };
};

private _requestInitialMission = {
    params [["_stage", 1, [0]]];
    if (isServer) then {
        [_stage] spawn MWF_fnc_generateInitialMission;
    } else {
        [_stage] remoteExec ["MWF_fnc_generateInitialMission", 2];
    };
};

private _grantTerminalAccess = {
    params ["_terminal", "_player"];

    _player setVariable ["MWF_Player_Authenticated", true, true];
    missionNamespace setVariable ["MWF_system_active", true, true];

    call _showPlayerUI;

    if (!isNull _terminal) then {
        if (!isNil "MWF_fnc_terminal_main") then {
            ["INIT_SCROLL", _terminal] call MWF_fnc_terminal_main;
            ["INIT_ACE", _terminal] call MWF_fnc_terminal_main;
        } else {
            diag_log "[MWF Login] Warning: terminal_main not loaded during MOB login grant.";
        };
    };

    [
        ["COMMAND NETWORK", "Authentication successful. Terminal access granted."],
        "success"
    ] call MWF_fnc_showNotification;

    systemChat "Command Network login accepted.";
    true
};

/* Session-scoped terminal auth. The campaign phase is persistent; the login itself is not. */
_caller setVariable ["MWF_Player_Authenticated", false, true];
missionNamespace setVariable ["MWF_system_active", false, true];

switch (_campaignPhase) do {
    case "TUTORIAL": {
        if (_currentStage >= 2) exitWith {
            if (!isNil "MWF_fnc_setCampaignPhase") then {
                ["SUPPLY_RUN", "Tutorial Stage Recovery"] remoteExecCall ["MWF_fnc_setCampaignPhase", 2];
            } else {
                missionNamespace setVariable ["MWF_Campaign_Phase", "SUPPLY_RUN", true];
            };

            if (_supplyRunDone) then {
                [
                    ["COMMAND NETWORK", "Complete the initial supply run to open the war and unlock the command terminal permanently."],
                    "warning"
                ] call MWF_fnc_showNotification;
                systemChat "Terminal locked: Complete the initial supply run milestone.";
            } else {
                [2] call _requestInitialMission;
                [
                    ["COMMAND NETWORK", "Complete the initial supply run to open the war and unlock the command terminal permanently."],
                    "warning"
                ] call MWF_fnc_showNotification;
                systemChat "Terminal locked: Complete the initial supply run milestone.";
            };
            false
        };

        call _showPlayerUI;

        if (_currentStage != 1) then {
            [1] call _requestInitialMission;
        };

        [
            ["COMMAND NETWORK", "Deploy your first FOB to unlock the command terminal."],
            "warning"
        ] call MWF_fnc_showNotification;

        systemChat "Terminal locked: Deploy FOB Alpha first.";
        false
    };

    case "SUPPLY_RUN": {
        if (_supplyRunDone) then {
            if (!isNil "MWF_fnc_setCampaignPhase") then {
                ["OPEN_WAR", "MOB Login Unlock"] remoteExecCall ["MWF_fnc_setCampaignPhase", 2];
            } else {
                diag_log "[MWF Login] Warning: setCampaignPhase missing during OPEN_WAR unlock.";
            };

            [_target, _caller] call _grantTerminalAccess
        } else {
            call _showPlayerUI;

            if (_currentStage != 2) then {
                [2] call _requestInitialMission;
            };

            [
                ["COMMAND NETWORK", "Complete the initial supply run to open the war and unlock the command terminal permanently."],
                "warning"
            ] call MWF_fnc_showNotification;

            systemChat "Terminal locked: Complete the initial supply run milestone.";
            false
        };
    };

    case "OPEN_WAR": {
        [_target, _caller] call _grantTerminalAccess
    };

    default {
        diag_log format ["[MWF Login] Unknown campaign phase '%1'. Falling back to tutorial gate.", _campaignPhase];
        call _showPlayerUI;
        [1] call _requestInitialMission;
        false
    };
};
