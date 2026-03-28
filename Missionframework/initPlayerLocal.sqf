/*
    Author: OpenAI / Operation Iron Mantle
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Function-first client bootstrap.
    Waits for the actual gameplay landing near a valid respawn position before
    running the first deploy bootstrap, so Arma's pre-deploy placeholder state
    cannot consume the initial wake-up.
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
    private _serverDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerReady", false])
        || (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) in ["ESSENTIALS_READY", "CRITICAL_RELEASED"]}
        || {diag_tickTime >= _serverDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_ServerReady", false])) then {
        diag_log "[MWF] WARNING: Client bootstrap continued before explicit server-ready flag. Function-first fallback engaged.";
    };

    private _getSpawnTargets = {
        private _targets = [];

        private _pushPos = {
            params ["_value"];
            if (_value isEqualType objNull) then {
                if (!isNull _value) then {
                    _targets pushBackUnique (getPosATL _value);
                };
            } else {
                if (_value isEqualType "" && {_value isNotEqualTo ""} && {markerColor _value isNotEqualTo ""}) then {
                    _targets pushBackUnique (getMarkerPos _value);
                };
            };
        };

        [missionNamespace getVariable ["MWF_MOB_RespawnAnchor", objNull]] call _pushPos;
        [missionNamespace getVariable ["MWF_MOB_DeployPad", objNull]] call _pushPos;

        if (!isNil "MWF_MOB_RespawnAnchor") then {
            [MWF_MOB_RespawnAnchor] call _pushPos;
        };
        if (!isNil "MWF_MOB_DeployPad") then {
            [MWF_MOB_DeployPad] call _pushPos;
        };

        ["respawn_west"] call _pushPos;
        ["MWF_MOB_Marker"] call _pushPos;

        _targets
    };

    private _landedAtGameplaySpawn = {
        if (isNull player || {!alive player}) exitWith { false };
        private _targets = call _getSpawnTargets;
        if (_targets isEqualTo []) exitWith { false };
        (_targets findIf { player distance2D _x <= 300 }) >= 0
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_INITIAL_LANDING"];
    private _landingDeadline = diag_tickTime + 300;
    waitUntil {
        uiSleep 0.25;
        (
            (!isNull player && {alive player} && {call _landedAtGameplaySpawn})
            || {(missionNamespace getVariable ["MWF_PlayerSpawnGeneration", 0]) > 0}
            || {diag_tickTime >= _landingDeadline}
        )
    };

    if (!(call _landedAtGameplaySpawn) && {(missionNamespace getVariable ["MWF_PlayerSpawnGeneration", 0]) <= 0}) then {
        diag_log "[MWF] WARNING: Initial landing watchdog expired before a valid gameplay spawn was detected. Forcing startup anyway.";
    };

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
    } forEach [0, 1, 3, 6, 10, 20, 35, 50, 70, 90];

    private _bootstrapDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) || {diag_tickTime >= _bootstrapDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_InitialDeployCompleted", false])) then {
        diag_log "[MWF] WARNING: Initial deploy watchdog expired before completion flag. Startup retries were still issued.";
    };
};
