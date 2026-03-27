/*
    Author: Theane / ChatGPT
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Handles the first playable spawn after the intro/deploy menu and all later
    player respawns.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];

private _initialDeployCompleted = missionNamespace getVariable ["MWF_InitialDeployCompleted", false];
private _initialDeployReleased = missionNamespace getVariable ["MWF_InitialDeployMenuReleased", false];

if (!_initialDeployCompleted && {!_initialDeployReleased}) exitWith {
    missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_IGNORED_PREINTRO"];
};

private _isInitialDeploy = !_initialDeployCompleted;
missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_RESPAWN"} else {"RESPAWN_REINIT"}];

[_isInitialDeploy] call MWF_fnc_handlePostSpawn;
