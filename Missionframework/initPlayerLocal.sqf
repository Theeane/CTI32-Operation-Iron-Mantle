/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Function-first local bootstrap.
    Starts client systems aggressively after the player becomes alive instead of
    waiting for perfect world/map conditions that can be missed by Arma's first deploy.
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
missionNamespace setVariable ["MWF_system_active", true, true];
missionNamespace setVariable ["MWF_UndercoverHandlerStarted", false];

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

    private _playerDeadline = diag_tickTime + 30;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {alive player}) || {diag_tickTime >= _playerDeadline}
    };

    if (isNull player || {!alive player}) exitWith {
        missionNamespace setVariable ["MWF_ClientInitStage", "PLAYER_TIMEOUT"];
        diag_log "[MWF] ERROR: initPlayerLocal aborted because player was not ready in time.";
    };

    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "SOFT_WAIT_SERVER"];
    private _serverSoftDeadline = diag_tickTime + 10;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerReady", false])
        || (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverSoftDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "FORCE_BOOTSTRAP"];

    private _kickLocalSystems = {
        params [["_initial", true, [false]]];

        if (isNull player || {!alive player}) exitWith {};

        if (_initial && {!isNil "MWF_fnc_applyBaselineLoadout"} && {!(missionNamespace getVariable ["MWF_InitialDeployCompleted", false])}) then {
            [true] call MWF_fnc_applyBaselineLoadout;
        };

        if (!isNil "MWF_fnc_initUI") then {
            [] call MWF_fnc_initUI;
        };

        if (!isNil "MWF_fnc_updateResourceUI") then {
            [] spawn MWF_fnc_updateResourceUI;
        };

        if (!isNil "MWF_fnc_initLoadoutSystem") then {
            [] call MWF_fnc_initLoadoutSystem;
        };

        if (!isNil "MWF_fnc_undercoverHandler") then {
            [] spawn MWF_fnc_undercoverHandler;
        };

        if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
            [] spawn MWF_fnc_infrastructureMarkerManager;
        };

        if (!isNil "MWF_fnc_setupInteractions") then {
            [] spawn MWF_fnc_setupInteractions;
        };

        if (!isNil "MWF_fnc_handlePostSpawn") then {
            [_initial] call MWF_fnc_handlePostSpawn;
        };
    };

    {
        [_x, _kickLocalSystems] spawn {
            params ["_delay", "_code"];
            uiSleep _delay;
            [true] call _code;
        };
    } forEach [0, 1, 3, 6, 10, 20, 35];

    private _bootstrapDeadline = diag_tickTime + 45;
    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) || {diag_tickTime >= _bootstrapDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_InitialDeployCompleted", false])) then {
        diag_log "[MWF] WARNING: Initial deploy watchdog expired before completion flag. Client bootstrap retries were still issued.";
    };
};
