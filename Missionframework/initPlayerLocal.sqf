/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Function-first client bootstrap.
    Waits for the actual deploy UI to close before consuming the first startup pass,
    so pre-deploy placeholder states cannot burn the initial wake-up.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_RuntimeSystemsInitialized", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
missionNamespace setVariable ["MWF_InitialDeployCompleted", false];
missionNamespace setVariable ["MWF_DeployUiClosed", false];
missionNamespace setVariable ["MWF_system_active", true, true];
missionNamespace setVariable ["MWF_UndercoverHandlerStarted", false];
missionNamespace setVariable ["MWF_PlayerSpawnGeneration", 0];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
uiNamespace setVariable ["MWF_IntroCallAttempted", true];
uiNamespace setVariable ["MWF_IntroCinematicStage", "BYPASSED"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];
player setVariable ["MWF_Player_Authenticated", true, true];

disableUserInput false;
cutText ["", "BLACK IN", 0.01];

[] spawn {
    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_PLAYER"];

    private _playerDeadline = diag_tickTime + 60;
    waitUntil {
        uiSleep 0.1;
        !isNull player || {diag_tickTime >= _playerDeadline}
    };

    if (isNull player) exitWith {
        missionNamespace setVariable ["MWF_ClientInitStage", "PLAYER_TIMEOUT"];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because the player object never became valid.";
    };

    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_READY"];
    private _serverDeadline = diag_tickTime + 180;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerReady", false])
        || {diag_tickTime >= _serverDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_ServerReady", false])) then {
        diag_log "[MWF] WARNING: Client bootstrap timed out waiting for explicit server-ready. Startup fallback engaged.";
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_DEPLOY_UI_CLOSE"];
    private _uiDeadline = diag_tickTime + 240;
    private _menuSeen = false;
    waitUntil {
        uiSleep 0.1;
        private _respawnDisplay = findDisplay 49;
        private _mapVisible = visibleMap;
        if (!isNull _respawnDisplay || {_mapVisible}) then {
            _menuSeen = true;
        };

        private _uiClosed = _menuSeen && {isNull _respawnDisplay} && {!_mapVisible};
        private _playerReady = !isNull player && {alive player};
        (_playerReady && _uiClosed)
        || {(missionNamespace getVariable ["MWF_PlayerSpawnGeneration", 0]) > 0}
        || {diag_tickTime >= _uiDeadline}
    };

    missionNamespace setVariable ["MWF_DeployUiClosed", true];
    missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_BOOTSTRAP"];

    {
        [_x] spawn {
            params ["_delay"];
            uiSleep _delay;
            if (isNull player || {!alive player}) exitWith {};
            if (!isNil "MWF_fnc_handlePostSpawn") then {
                [true] call MWF_fnc_handlePostSpawn;
            };
            if (!isNil "MWF_fnc_setupInteractions") then {
                [] spawn MWF_fnc_setupInteractions;
            };
            if (!isNil "MWF_fnc_updateResourceUI") then {
                [] spawn MWF_fnc_updateResourceUI;
            };
        };
    } forEach [0, 1, 2, 4, 7, 12, 20, 35, 50];

    private _bootstrapDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) || {diag_tickTime >= _bootstrapDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_InitialDeployCompleted", false])) then {
        diag_log "[MWF] WARNING: Initial deploy watchdog expired before completion flag. Startup retries were still issued.";
    };
};
