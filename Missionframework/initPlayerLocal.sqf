/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Systems-first local bootstrap.
    Keeps startup minimal and defers all gameplay/runtime initialization until the
    player has actually completed the first native Arma deploy spawn.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_RuntimeSystemsInitialized", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_InitialDeployCompleted", false];
missionNamespace setVariable ["MWF_system_active", true, true];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
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
        (!isNull player && {alive player}) || {diag_tickTime >= _playerDeadline}
    };

    if (isNull player || {!alive player}) exitWith {
        missionNamespace setVariable ["MWF_ClientInitStage", "PLAYER_TIMEOUT"];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because player was not ready in time.";
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_SOFT"];
    private _serverDeadline = diag_tickTime + 30;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_INITIAL_DEPLOY_UI"];

    private _initialDeployDeadline = diag_tickTime + 180;
    private _uiObserveDeadline = diag_tickTime + 20;
    private _sawDeployUi = false;

    waitUntil {
        uiSleep 0.1;

        if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith { true };

        if (dialog || {visibleMap}) then {
            _sawDeployUi = true;
        };

        _sawDeployUi || {diag_tickTime >= _uiObserveDeadline} || {diag_tickTime >= _initialDeployDeadline}
    };

    if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith {};

    missionNamespace setVariable ["MWF_ClientInitStage", if (_sawDeployUi) then {"WAIT_INITIAL_DEPLOY_CLOSE"} else {"WAIT_INITIAL_DEPLOY_WORLDSTATE"}];

    private _stableWorldSince = -1;
    waitUntil {
        uiSleep 0.1;

        if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith { true };

        private _worldReady = !isNull player
            && {alive player}
            && {!dialog}
            && {!visibleMap}
            && {!isNull findDisplay 46};

        if (_worldReady) then {
            if (_stableWorldSince < 0) then {
                _stableWorldSince = diag_tickTime;
            };
        } else {
            _stableWorldSince = -1;
        };

        ((_stableWorldSince >= 0) && {(diag_tickTime - _stableWorldSince) >= 1})
        || {diag_tickTime >= _initialDeployDeadline}
    };

    if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith {};

    missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_DETECTED"];

    if (!isNil "MWF_fnc_handlePostSpawn") then {
        [true] call MWF_fnc_handlePostSpawn;
    } else {
        diag_log "[MWF] ERROR: MWF_fnc_handlePostSpawn missing during initial deploy bootstrap.";
    };
};
