/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Systems-first client bootstrap.

    This version intentionally removes the legacy forced-MOB move and intro ownership.
    Arma native spawn/deploy owns the player's start. Actual gameplay initialization is
    centralized in MWF_fnc_handlePostSpawn and triggered from respawn flow, with a
    lightweight fallback here in case the first spawn event is not raised by the engine.
*/

if (!hasInterface) exitWith {};

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnGeneration", 0];
missionNamespace setVariable ["MWF_InitialSpawnHandled", false];
missionNamespace setVariable ["MWF_UndercoverLoopStarted", false];
missionNamespace setVariable ["MWF_InfrastructureMarkerLoopStarted", false];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "DISABLED"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];

disableUserInput false;
cutText ["", "BLACK IN", 0.25];

[] spawn {
    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_PLAYER"];
    private _playerDeadline = diag_tickTime + 60;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {player == player}) || {diag_tickTime >= _playerDeadline}
    };

    if (isNull player) exitWith {
        missionNamespace setVariable ["MWF_ClientInitStage", "PLAYER_TIMEOUT"];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because player object was not ready in time.";
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_LOCAL_READY"];
    private _readyDeadline = diag_tickTime + 60;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_LocalInitReady", false])
        || (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _readyDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_FIRST_SPAWN"];
    private _fallbackDeadline = diag_tickTime + 25;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_PostSpawnGeneration", 0]) > 0
        || {diag_tickTime >= _fallbackDeadline}
    };

    if ((missionNamespace getVariable ["MWF_PostSpawnGeneration", 0]) <= 0 && {!isNull player} && {alive player}) then {
        missionNamespace setVariable ["MWF_ClientInitStage", "FIRST_SPAWN_FALLBACK"];
        if (!isNil "MWF_fnc_handlePostSpawn") then {
            [true, "INITPLAYERLOCAL_FALLBACK"] spawn MWF_fnc_handlePostSpawn;
        } else {
            diag_log "[MWF] WARNING: initPlayerLocal fallback could not start post-spawn bootstrap because MWF_fnc_handlePostSpawn is unavailable.";
        };
    };
};
