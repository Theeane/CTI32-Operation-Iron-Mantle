/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Fresh-join deployment flow.

    Join flow:
    black screen -> local deployment cinematic -> trigger native Arma respawn/deploy.

    Respawn flow:
    handled separately in onPlayerRespawn.sqf. Intro never replays on player death.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_RuntimeSystemsInitialized", false];
missionNamespace setVariable ["MWF_InitialDeployPending", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", false];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "RESET"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];

cutText ["", "BLACK FADED", 0];

[] spawn {
    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_PLAYER"];
    private _playerDeadline = diag_tickTime + 60;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {alive player}) || {diag_tickTime >= _playerDeadline}
    };

    if (isNull player || {!alive player}) exitWith {
        missionNamespace setVariable ["MWF_ClientInitStage", "PLAYER_TIMEOUT"];
        missionNamespace setVariable ["MWF_ClientInitComplete", false];
        disableUserInput false;
        cutText ["", "BLACK IN", 0.5];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because player was not ready in time.";
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "LOCK_PLAYER"];
    missionNamespace setVariable ["MWF_BlockRespawn", true];
    player allowDamage false;
    player enableSimulation false;
    disableUserInput true;

    if (vehicle player != player) then {
        moveOut player;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_SOFT"];
    private _serverDeadline = diag_tickTime + 10;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverDeadline}
    };

    [] spawn {
        uiSleep 90;
        if (missionNamespace getVariable ["MWF_BlockRespawn", false]) then {
            player enableSimulation true;
            player allowDamage true;
            missionNamespace setVariable ["MWF_BlockRespawn", false];
            uiNamespace setVariable ["MWF_IntroCinematicActive", false];
            disableUserInput false;
            cutText ["", "BLACK IN", 0.5];
            diag_log "[MWF] WARNING: Intro/deploy watchdog released client control after timeout.";
        };
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
    uiNamespace setVariable ["MWF_IntroCallAttempted", true];

    private _introSucceeded = false;
    if (!isNil "MWF_fnc_playIntroCinematic") then {
        _introSucceeded = [] call MWF_fnc_playIntroCinematic;
    } else {
        _introSucceeded = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
    };
    missionNamespace setVariable ["MWF_IntroCallResult", _introSucceeded];

    if (_introSucceeded) then {
        uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
    } else {
        diag_log "[MWF] WARNING: Intro cinematic returned false. Continuing to native deploy trigger.";
        cutText ["", "BLACK IN", 0.5];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "TRIGGER_INITIAL_DEPLOY"];
    player enableSimulation true;
    player allowDamage true;
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    disableUserInput false;

    missionNamespace setVariable ["MWF_InitialDeployPending", true];
    missionNamespace setVariable ["MWF_ClientInitComplete", false];

    cutText ["", "BLACK FADED", 0];
    uiSleep 0.1;

    setPlayerRespawnTime 0;
    forceRespawn player;

    [] spawn {
        uiSleep 8;
        if (missionNamespace getVariable ["MWF_InitialDeployPending", false]) then {
            if (!isNull player && {alive player}) then {
                player setDamage 1;
                diag_log "[MWF] WARNING: forceRespawn fallback triggered via setDamage 1.";
            };
        };
    };
};
