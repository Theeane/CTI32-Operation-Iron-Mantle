/*
    Author: Theane / ChatGPT
    Function: MWF_fn_MOBComputerLogin
    Project: Military War Framework

    Description:
    Smart login bridge for the MOB computer.
    Routes the player into the correct early-game path after restart/load:
    - No FOBs -> deploy FOB quest
    - FOB exists but supplies below threshold -> supply quest
    - FOB exists and supplies threshold met -> full terminal access

    Parameters:
    0: _target <OBJECT> MOB computer / terminal object
    1: _caller <OBJECT> player using the hold action

    Returns:
    <BOOL> True when full terminal access was granted, otherwise false.
*/

params [
    ["_target", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _caller) exitWith { false };
if (!local _caller && {hasInterface}) exitWith { false };

private _hasCampaignSave = missionNamespace getVariable ["MWF_HasCampaignSave", false];
private _fobRegistry = + (missionNamespace getVariable ["MWF_FOB_Registry", []]);
private _hasFOB = (count _fobRegistry) > 0;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _threshold = 1000;
private _currentStage = missionNamespace getVariable ["MWF_current_stage", 0];

private _showPlayerUI = {
    if (!hasInterface) exitWith {};
    cutRsc ["MWF_ResourceBar", "PLAIN"];
    [] spawn MWF_fnc_updateResourceUI;
};

private _grantTerminalAccess = {
    params ["_terminal", "_player"];

    _player setVariable ["MWF_Player_Authenticated", true, true];
    missionNamespace setVariable ["MWF_Player_Authenticated", true];
    missionNamespace setVariable ["MWF_system_active", true, true];

    call _showPlayerUI;

    if (!isNull _terminal) then {
        ["INIT_SCROLL", _terminal] call MWF_fnc_terminal_main;
        ["INIT_ACE", _terminal] call MWF_fnc_terminal_main;
    };

    ["ACCESS GRANTED", "Command Network access verified. Full terminal access available." ] call MWF_fnc_showNotification;
    systemChat "Command Network login complete. Full terminal access granted.";
    true
};

private _requestInitialMission = {
    params ["_stage"];
    if (isServer) then {
        [_stage] spawn MWF_fnc_generateInitialMission;
    } else {
        [_stage] remoteExec ["MWF_fnc_generateInitialMission", 2];
    };
};

// Reset local auth until proven otherwise.
_caller setVariable ["MWF_Player_Authenticated", false, true];
missionNamespace setVariable ["MWF_Player_Authenticated", false];

if (!_hasFOB) exitWith {
    missionNamespace setVariable ["MWF_system_active", false, true];
    call _showPlayerUI;

    if (_currentStage != 1) then {
        [1] call _requestInitialMission;
    };

    private _msg = if (_hasCampaignSave) then {
        "Campaign save loaded, but no FOB is registered. Deploy a FOB before terminal access is granted."
    } else {
        "No FOB found. Deploy your first FOB to unlock the command network."
    };

    ["LOGIN ROUTED", _msg] call MWF_fnc_showNotification;
    systemChat _msg;
    false
};

if (_supplies < _threshold) exitWith {
    missionNamespace setVariable ["MWF_system_active", false, true];
    call _showPlayerUI;

    if (_currentStage < 2) then {
        [2] call _requestInitialMission;
    };

    private _msg = format [
        "FOB online, but logistics are below %1 supplies (%2 available). Complete the supply quest before full terminal access.",
        _threshold,
        _supplies
    ];

    ["LOGIN ROUTED", _msg] call MWF_fnc_showNotification;
    systemChat _msg;
    false
};

[_target, _caller] call _grantTerminalAccess
