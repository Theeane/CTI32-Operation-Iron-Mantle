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

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_INITIAL_DEPLOY"];

    private _startupUnit = player;
    private _startupPos = getPosATL player;
    private _initialDeployDeadline = diag_tickTime + 300;

    waitUntil {
        uiSleep 0.1;

        if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith { true };

        private _unitChanged = player != _startupUnit;
        private _movedFar = (player distance2D _startupPos) > 25;

        (_unitChanged || _movedFar) || {diag_tickTime >= _initialDeployDeadline}
    };

    if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith {};

    missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_DETECTED"];

    if (!isNil "MWF_fnc_handlePostSpawn") then {
        [true] call MWF_fnc_handlePostSpawn;
    } else {
        diag_log "[MWF] ERROR: MWF_fnc_handlePostSpawn missing during initial deploy bootstrap.";
    };
};
