/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Per-player startup flow.

    Join flow:
    black screen -> local deployment cinematic -> native Arma deploy/respawn menu ->
    first playable spawn on MOB/FOB -> post-spawn systems.

    Respawn flow after the first playable spawn is handled in onPlayerRespawn.sqf.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", true];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_InitialDeployMenuReleased", false];
missionNamespace setVariable ["MWF_InitialDeployCompleted", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];
missionNamespace setVariable ["MWF_system_active", false, true];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", false];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "RESET"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];

cutText ["", "BLACK FADED", 0];
["close"] call BIS_fnc_showRespawnMenu;

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
        missionNamespace setVariable ["MWF_BlockRespawn", false];
        disableUserInput false;
        cutText ["", "BLACK IN", 0.5];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because player was not ready in time.";
    };

    player setVariable ["MWF_Player_Authenticated", false, true];

    missionNamespace setVariable ["MWF_ClientInitStage", "LOCK_PLAYER"];
    player allowDamage false;
    player enableSimulation false;
    disableUserInput true;

    if (vehicle player != player) then {
        moveOut player;
    };

    if (!isNil "MWF_fnc_initUI") then {
        missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_SOFT"];
    private _serverDeadline = diag_tickTime + 5;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
    uiNamespace setVariable ["MWF_IntroCallAttempted", true];

    [] spawn {
        uiSleep 90;
        if (!(missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) && {(missionNamespace getVariable ["MWF_BlockRespawn", false])}) then {
            missionNamespace setVariable ["MWF_BlockRespawn", false];
            player enableSimulation false;
            player allowDamage false;
            disableUserInput false;
            uiNamespace setVariable ["MWF_IntroCinematicActive", false];
            cutText ["", "BLACK IN", 0.5];
            diag_log "[MWF] WARNING: Intro/deploy watchdog released client control after timeout.";
        };
    };

    private _introSucceeded = false;
    if (!isNil "MWF_fnc_playIntroCinematic") then {
        _introSucceeded = [] call MWF_fnc_playIntroCinematic;
    } else {
        _introSucceeded = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
    };
    missionNamespace setVariable ["MWF_IntroCallResult", _introSucceeded];

    if (!_introSucceeded) then {
        diag_log "[MWF] WARNING: Intro cinematic returned false. Continuing to deploy menu release.";
        cutText ["", "BLACK IN", 0.5];
    } else {
        uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "OPEN_DEPLOY_MENU"];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    missionNamespace setVariable ["MWF_InitialDeployMenuReleased", true];

    disableUserInput false;
    player allowDamage false;
    player enableSimulation false;
    player setVelocity [0, 0, 0];

    [] spawn {
        private _deadline = diag_tickTime + 120;
        while {
            !(missionNamespace getVariable ["MWF_InitialDeployCompleted", false])
            && {alive player}
            && {diag_tickTime < _deadline}
        } do {
            ["open"] call BIS_fnc_showRespawnMenu;
            uiSleep 5;
        };
    };
};
