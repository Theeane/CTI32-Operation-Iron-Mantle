/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Reliable fresh-join deployment flow.

    Join flow:
    black screen -> force move player to MOB/deploy pad immediately -> local intro cinematic ->
    baseline loadout -> enable local systems.

    Respawn flow:
    handled separately in onPlayerRespawn.sqf. Intro never replays on player death.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];

uiNamespace setVariable ["MWF_InitialIntroSequenceDone", false];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "RESET"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];

cutText ["", "BLACK FADED", 0];

[] spawn {
    private _resolveDeployData = {
        private _deployPad = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];
        if (isNull _deployPad && {!isNil "mob_deploy_pad"}) then {
            _deployPad = mob_deploy_pad;
        };

        private _anchorObj = missionNamespace getVariable ["MWF_MOB_Table", missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]]];
        if (isNull _anchorObj && {!isNil "MWF_MOB_Table"}) then {
            _anchorObj = MWF_MOB_Table;
        };

        private _deployPos = [0, 0, 0];
        private _deployDir = 0;

        if (!isNull _deployPad) then {
            _deployPos = getPosATL _deployPad;
            _deployDir = getDir _deployPad;
        };

        if (_deployPos isEqualTo [0, 0, 0] && {!isNull _anchorObj}) then {
            _deployPos = getPosATL _anchorObj;
            _deployDir = getDir _anchorObj;
        };

        if (_deployPos isEqualTo [0, 0, 0]) then {
            private _markerPos = getMarkerPos "respawn_west";
            if !(_markerPos isEqualTo [0, 0, 0]) then {
                _deployPos = _markerPos;
                _deployDir = markerDir "respawn_west";
            };
        };

        if (_deployPos isEqualTo [0, 0, 0]) then {
            _deployPos = getPosATL player;
            _deployDir = getDir player;
        };

        [_deployPos, _deployDir]
    };

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

    private _deployData = call _resolveDeployData;
    private _deployPos = _deployData # 0;
    private _deployDir = _deployData # 1;

    missionNamespace setVariable ["MWF_ClientInitStage", "FORCE_MOB_POSITION"];
    if !(_deployPos isEqualTo [0, 0, 0]) then {
        player setPosATL _deployPos;
        player setVehiclePosition [_deployPos, [], 0, "CAN_COLLIDE"];
        player setDir _deployDir;
        player setVelocity [0, 0, 0];
    };

    uiSleep 0.25;

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    if (!isNil "MWF_fnc_initUI") then {
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

    private _introSucceeded = false;
    if (!isNil "MWF_fnc_playIntroCinematic") then {
        _introSucceeded = [] call MWF_fnc_playIntroCinematic;
    } else {
        _introSucceeded = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
    };
    missionNamespace setVariable ["MWF_IntroCallResult", _introSucceeded];

    if (!_introSucceeded) then {
        diag_log "[MWF] WARNING: Intro cinematic returned false. Continuing with forced MOB deploy release.";
        cutText ["", "BLACK IN", 0.5];
    } else {
        uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "POST_INTRO_DEPLOY"];
    _deployData = call _resolveDeployData;
    _deployPos = _deployData # 0;
    _deployDir = _deployData # 1;
    if !(_deployPos isEqualTo [0, 0, 0]) then {
        player setPosATL _deployPos;
        player setVehiclePosition [_deployPos, [], 0, "CAN_COLLIDE"];
        player setDir _deployDir;
        player setVelocity [0, 0, 0];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "BASELINE_LOADOUT"];
    if (!isNil "MWF_fnc_applyBaselineLoadout") then {
        [] call MWF_fnc_applyBaselineLoadout;
    };

    player enableSimulation true;
    player allowDamage true;
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    disableUserInput false;
    uiSleep 0.25;

    missionNamespace setVariable ["MWF_ClientInitStage", "ASYNC_SYSTEMS"];
    [] spawn {
        uiSleep 0.25;

        missionNamespace setVariable ["MWF_ClientInitStage", "SETUP_INTERACTIONS"];
        [] call MWF_fnc_setupInteractions;
        [] spawn {
            uiSleep 4;
            [] call MWF_fnc_setupInteractions;
        };
        [] spawn {
            uiSleep 10;
            [] call MWF_fnc_setupInteractions;
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "LOADOUT_INIT"];
        [] call MWF_fnc_initLoadoutSystem;

        missionNamespace setVariable ["MWF_ClientInitStage", "UNDERCOVER_INIT"];
        [] spawn MWF_fnc_undercoverHandler;

        if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
            missionNamespace setVariable ["MWF_ClientInitStage", "INFRA_MARKERS"];
            [] spawn MWF_fnc_infrastructureMarkerManager;
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "RESOURCE_UI"];
        [] spawn MWF_fnc_updateResourceUI;

        if !(player getVariable ["MWF_DamageInterruptEHAdded", false]) then {
            missionNamespace setVariable ["MWF_ClientInitStage", "DAMAGE_EH"];
            player setVariable ["MWF_DamageInterruptEHAdded", true];
            player addEventHandler ["HandleDamage", {
                params ["_unit", "_selection", "_damage", "_source", "_projectile"];
                private _currentDamage = damage _unit;
                if ((_damage > _currentDamage) || {(_projectile isEqualType "") && {_projectile isNotEqualTo ""}} || {(_source isEqualType objNull) && {!isNull _source}}) then {
                    [] call MWF_fnc_interruptSensitiveInteraction;
                };
                _damage
            }];
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "COMPLETE"];
        missionNamespace setVariable ["MWF_ClientInitComplete", true];
        diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
    };
};
