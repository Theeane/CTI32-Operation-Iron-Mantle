/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Systems-first local bootstrap.
    Keeps startup minimal and defers all gameplay/runtime initialization until the
    player has completed the first native Arma deploy spawn.

    This version removes the old unit-change / move-distance gate and instead
    watches for the player to settle into a valid world spawn state near a real
    deploy anchor. That avoids the current dead-start where Arma reuses the same
    player object and no "movement > 25m" event ever occurs.
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
missionNamespace setVariable ["MWF_UndercoverHandlerStarted", false];

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
        {
            [_x] spawn {
                params ["_delay"];
                uiSleep _delay;
                if (!isNil "MWF_fnc_initUI") then {
                    [] call MWF_fnc_initUI;
                };
            };
        } forEach [2, 5, 10];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_SOFT"];
    private _serverDeadline = diag_tickTime + 45;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_INITIAL_DEPLOY"];

    private _isNearValidSpawnAnchor = {
        private _anchorPositions = [];

        if (markerColor "respawn_west" isNotEqualTo "") then {
            private _respawnPos = getMarkerPos "respawn_west";
            if !(_respawnPos isEqualTo [0, 0, 0]) then {
                _anchorPositions pushBackUnique _respawnPos;
            };
        };

        if (markerColor "MWF_MOB_Marker" isNotEqualTo "") then {
            private _mobMarkerPos = getMarkerPos "MWF_MOB_Marker";
            if !(_mobMarkerPos isEqualTo [0, 0, 0]) then {
                _anchorPositions pushBackUnique _mobMarkerPos;
            };
        };

        {
            private _obj = missionNamespace getVariable [_x, objNull];
            if (!isNull _obj) then {
                _anchorPositions pushBackUnique (getPosATL _obj);
            };
        } forEach [
            "MWF_MainBase",
            "MWF_MOB",
            "MWF_MOB_Object",
            "MWF_MOB_Table",
            "MWF_MOB_FobPad",
            "MWF_MOB_DeployPad",
            "MWF_Intel_Center"
        ];

        if (!isNil "MWF_Intel_Center") then {
            if (!isNull MWF_Intel_Center) then {
                _anchorPositions pushBackUnique (getPosATL MWF_Intel_Center);
            };
        };

        {
            private _terminal = _x param [1, objNull];
            if (!isNull _terminal) then {
                _anchorPositions pushBackUnique (getPosATL _terminal);
            };
        } forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);

        private _isNear = false;
        {
            if (player distance2D _x <= 175) exitWith {
                _isNear = true;
            };
        } forEach _anchorPositions;

        _isNear
    };

    private _initialDeployDeadline = diag_tickTime + 180;
    private _fallbackBootstrapAt = diag_tickTime + 8;

    waitUntil {
        uiSleep 0.1;

        if (missionNamespace getVariable ["MWF_InitialDeployCompleted", false]) exitWith { true };

        private _playerReady = !isNull player && {alive player} && {!isNull findDisplay 46};
        private _worldReady = _playerReady && {!visibleMap};
        private _nearAnchor = false;

        if (_worldReady) then {
            _nearAnchor = call _isNearValidSpawnAnchor;
        };

        (_worldReady && _nearAnchor)
        || (_worldReady && {diag_tickTime >= _fallbackBootstrapAt})
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
