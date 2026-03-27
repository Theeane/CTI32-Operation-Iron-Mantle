/*
    Author: Theeane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Client-side initialization for each player.

    Join flow (every new join):
    staging/holding area -> local deployment cinematic -> direct insertion at MOB -> baseline loadout -> local client systems

    Respawn flow:
    handled separately in onPlayerRespawn.sqf. Intro never replays on player death.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];

/* Fresh mission join = always replay the local intro for this client. */
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", false];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "RESET"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
missionNamespace setVariable ["MWF_IntroCallResult", false];

if (hasInterface) then {
    cutText ["", "BLACK FADED", 0];
};

private _clientBootDeadline = diag_tickTime + 120;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false])
    || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
    || {diag_tickTime >= _clientBootDeadline}
};

if (!(missionNamespace getVariable ["MWF_ServerInitialized", false])) then {
    diag_log "[MWF] WARNING: Client init timeout reached before server-ready flag. Continuing with local startup.";
};

diag_log format ["[MWF] INFO: Player initialization started for %1.", name player];

[] spawn {
    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_PLAYER"];
    waitUntil { !isNull player };
    waitUntil { alive player };

    if (hasInterface) then {
        cutText ["", "BLACK FADED", 0];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_WORLD_READY"];
    waitUntil {
        uiSleep 0.25;
        alive player
        && {!visibleMap}
        && {!dialog}
        && {!isNull findDisplay 46}
    };

    uiSleep 0.25;

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    [] call MWF_fnc_initUI;

    private _needsInitialIntro = !(uiNamespace getVariable ["MWF_InitialIntroSequenceDone", false]);
    if (_needsInitialIntro) then {
        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_PREP"];
        missionNamespace setVariable ["MWF_BlockRespawn", true];

        [] spawn {
            uiSleep 90;
            if (missionNamespace getVariable ["MWF_BlockRespawn", false]) then {
                disableUserInput false;
                missionNamespace setVariable ["MWF_BlockRespawn", false];
                uiNamespace setVariable ["MWF_IntroCinematicActive", false];
                diag_log "[MWF] WARNING: Intro input lock watchdog released control after timeout.";
            };
        };

        disableUserInput true;
        uiSleep 0.1;

        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
        uiNamespace setVariable ["MWF_IntroCallAttempted", true];

        private _introSucceeded = false;
        private _introAttempts = 0;
        private _introDeadline = diag_tickTime + 90;

        while {!_introSucceeded && {diag_tickTime < _introDeadline} && {alive player}} do {
            _introAttempts = _introAttempts + 1;
            uiNamespace setVariable ["MWF_IntroCinematicStage", format ["ATTEMPT_%1", _introAttempts]];
            uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
            uiNamespace setVariable ["MWF_IntroCinematicActive", false];

            private _callResult = false;
            if (!isNil "MWF_fnc_playIntroCinematic") then {
                _callResult = [] call MWF_fnc_playIntroCinematic;
            } else {
                _callResult = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
            };

            missionNamespace setVariable ["MWF_IntroCallResult", _callResult];
            _introSucceeded = _callResult;

            if (!_introSucceeded) then {
                diag_log format ["[MWF] WARNING: Intro attempt %1 failed. Retrying.", _introAttempts];
                uiSleep 1;
            };
        };

        if (_introSucceeded) then {
            uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
            missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_DONE"];
        } else {
            missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_FAILED_FALLBACK"];
            diag_log "[MWF] WARNING: Intro cinematic failed after retries. Continuing with direct MOB insertion fallback.";
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_INSERT_POINT"];
        private _insertDeadline = diag_tickTime + 20;
        waitUntil {
            uiSleep 0.25;
            !isNull (missionNamespace getVariable ["MWF_MOB_DeployPad", objNull])
            || {!isNil "mob_deploy_pad"}
            || {markerColor "MWF_MOB_Marker" isNotEqualTo ""}
            || {!isNull (missionNamespace getVariable ["MWF_MOB", objNull])}
            || {diag_tickTime >= _insertDeadline}
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "MOB_INSERT"];

        private _insertPos = [0, 0, 0];
        private _insertDir = 0;
        private _deployPad = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];

        if (isNull _deployPad && {!isNil "mob_deploy_pad"}) then {
            _deployPad = mob_deploy_pad;
        };

        if (!isNull _deployPad) then {
            _insertPos = getPosATL _deployPad;
            _insertDir = getDir _deployPad;
        };

        if ((_insertPos isEqualTo [0, 0, 0]) && {markerColor "MWF_MOB_Marker" isNotEqualTo ""}) then {
            _insertPos = getMarkerPos "MWF_MOB_Marker";
            _insertDir = markerDir "MWF_MOB_Marker";
        };

        if ((_insertPos isEqualTo [0, 0, 0])) then {
            private _mobArea = missionNamespace getVariable ["MWF_MOB", objNull];
            if (!isNull _mobArea) then {
                _insertPos = getPosATL _mobArea;
                _insertDir = getDir _mobArea;
            };
        };

        if ((_insertPos isEqualTo [0, 0, 0])) then {
            private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
            if (!isNull _mainBase) then {
                _insertPos = getPosATL _mainBase;
                _insertDir = getDir _mainBase;
            };
        };

        if ((_insertPos isEqualTo [0, 0, 0])) then {
            _insertPos = getPosATL player;
            _insertDir = getDir player;
        };

        if !(vehicle player isEqualTo player) then {
            moveOut player;
            uiSleep 0.1;
        };

        if !(_insertPos isEqualTo [0, 0, 0]) then {
            player switchMove "";
            player setVelocity [0, 0, 0];
            player setPosATL _insertPos;
            player setVehiclePosition [_insertPos, [], 0, "NONE"];
            player setDir _insertDir;
        };

        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [] call MWF_fnc_applyBaselineLoadout;
        };

        if (!isNil "MWF_fnc_setupInteractions") then {
            [] call MWF_fnc_setupInteractions;
        };

        if (!isNil "MWF_fnc_initLoadoutSystem") then {
            [] call MWF_fnc_initLoadoutSystem;
        };

        missionNamespace setVariable ["MWF_BlockRespawn", false];
        disableUserInput false;
        cutText ["", "BLACK IN", 1.5];
        uiSleep 0.25;
    } else {
        cutText ["", "BLACK IN", 0.5];
    };

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
