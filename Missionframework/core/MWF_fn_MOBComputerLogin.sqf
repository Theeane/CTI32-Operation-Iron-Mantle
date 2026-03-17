/*
    Author: Theane / ChatGPT
    Function: MWF_fn_MOBComputerLogin
    Project: Military War Framework

    Description:
    Smart MOB computer login gate.
    Uses persistent campaign milestones instead of current supply totals so players
    do not get forced back into old tutorial gates after a save/load.

    Stage model:
    - Stage 1: Deploy FOB gate
    - Stage 2: Complete initial supply run gate
    - Stage 3+: Full terminal access / normal campaign flow
*/

params [
    ["_target", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _caller) exitWith { false };
if (!hasInterface) exitWith { false };
if (!local _caller) exitWith { false };

private _hasCampaignSave = missionNamespace getVariable ["MWF_HasCampaignSave", false];
private _fobRegistry = + (missionNamespace getVariable ["MWF_FOB_Registry", []]);
private _hasFOB = (count _fobRegistry) > 0;
private _supplyRunDone = missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false];
private _currentStage = missionNamespace getVariable ["MWF_current_stage", 0];
private _uid = getPlayerUID _caller;
private _authenticatedPlayers = + (missionNamespace getVariable ["MWF_AuthenticatedPlayers", []]);
private _playerMilestoneAuthenticated = (_uid isNotEqualTo "" && {_uid in _authenticatedPlayers});

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

    if (_currentStage < 3) then {
        missionNamespace setVariable ["MWF_current_stage", 3, true];
    };

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

/* Session-scoped auth. Players may need to log in again after restart, but
   tutorial gating should no longer repeat once milestones are completed. */
_caller setVariable ["MWF_Player_Authenticated", false, true];
missionNamespace setVariable ["MWF_system_active", false, true];

/* Legacy compatibility: if an older campaign already passed the supply-run milestone
   before per-player authentication existed, the first returning player may claim that
   milestone once and become permanently authenticated for future logins. */
if (!_playerMilestoneAuthenticated && _hasCampaignSave && _supplyRunDone && {(count _authenticatedPlayers) == 0} && {_uid isNotEqualTo ""}) then {
    if (!isNil "MWF_fnc_registerAuthenticatedPlayer") then {
        [_uid] remoteExecCall ["MWF_fnc_registerAuthenticatedPlayer", 2];
    };
    _playerMilestoneAuthenticated = true;
};

if (_playerMilestoneAuthenticated) exitWith {
    [_target, _caller] call _grantTerminalAccess
};

/* Gate 1: FOB must exist. */
if (!_hasFOB) exitWith {
    call _showPlayerUI;

    if (_currentStage != 1) then {
        [1] call _requestInitialMission;
    };

    if (_hasCampaignSave) then {
        [
            ["COMMAND NETWORK", "No active FOB detected. Deploy a FOB before terminal access can be granted."],
            "warning"
        ] call MWF_fnc_showNotification;
    } else {
        [
            ["COMMAND NETWORK", "Deploy your first FOB to unlock the Command Network terminal."],
            "warning"
        ] call MWF_fnc_showNotification;
    };

    systemChat "Terminal locked: Deploy a FOB first.";
    false
};

/* Gate 2: Player must have completed the initial supply-run milestone.
   This is history-driven, not supply-amount-driven, so access stays unlocked
   permanently once the player has proved they can complete the logistics step. */
if (!_supplyRunDone) exitWith {
    call _showPlayerUI;

    if (_currentStage != 2) then {
        [2] call _requestInitialMission;
    };

    [
        ["COMMAND NETWORK", "Complete the initial supply run to unlock permanent terminal access."],
        "warning"
    ] call MWF_fnc_showNotification;

    systemChat "Terminal locked: Complete the initial supply run milestone.";
    false
};

[_target, _caller] call _grantTerminalAccess
