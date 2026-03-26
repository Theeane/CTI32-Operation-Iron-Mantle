/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.

    First join flow:
    island/holding area -> intro cinematic -> deploy to mob_deploy_pad (or respawn_west fallback)

    Real respawn flow:
    regular respawn only, no intro replay.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER"];

if !(uiNamespace getVariable ["MWF_InitialIntroSequenceDone", false]) then {
    uiNamespace setVariable ["MWF_IntroCallAttempted", false];
    uiNamespace setVariable ["MWF_IntroCinematicStage", "NOT_CALLED"];
    uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
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

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_WORLD_READY"];
    waitUntil {
        uiSleep 0.25;
        alive player
        && {!visibleMap}
        && {!dialog}
        && {!isNull findDisplay 46}
    };

    uiSleep 0.5;

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    [] call MWF_fnc_initUI;

    private _needsInitialIntro = !(uiNamespace getVariable ["MWF_InitialIntroSequenceDone", false]);
    if (_needsInitialIntro) then {
        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_PREP"];
        missionNamespace setVariable ["MWF_BlockRespawn", true];

        [] spawn {
            uiSleep 30;
            if (missionNamespace getVariable ["MWF_BlockRespawn", false]) then {
                disableUserInput false;
                missionNamespace setVariable ["MWF_BlockRespawn", false];
                diag_log "[MWF] WARNING: Intro input lock watchdog released control after timeout.";
            };
        };

        disableUserInput true;
        uiSleep 0.1;

        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
        uiNamespace setVariable ["MWF_IntroCallAttempted", true];

        private _introResult = false;
        if (!isNil "MWF_fnc_playIntroCinematic") then {
            _introResult = [] call MWF_fnc_playIntroCinematic;
        } else {
            _introResult = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
        };

        uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];

        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_DEPLOY"];
        private _deployPos = getMarkerPos "respawn_west";
        private _deployDir = markerDir "respawn_west";
        private _deployPad = missionNamespace getVariable ["mob_deploy_pad", objNull];

        if (isNull _deployPad && {!isNil "mob_deploy_pad"}) then {
            _deployPad = mob_deploy_pad;
        };

        if (!isNull _deployPad) then {
            _deployPos = getPosATL _deployPad;
            _deployDir = getDir _deployPad;
        };

        if !(_deployPos isEqualTo [0,0,0]) then {
            player setVehiclePosition [_deployPos, [], 0, "NONE"];
            player setDir _deployDir;
        };

        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [] call MWF_fnc_applyBaselineLoadout;
        };

        uiSleep 0.25;
        disableUserInput false;
        missionNamespace setVariable ["MWF_BlockRespawn", false];
        missionNamespace setVariable ["MWF_ClientInitStage", if (_introResult) then {"INTRO_DONE"} else {"INTRO_SKIPPED"}];
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
