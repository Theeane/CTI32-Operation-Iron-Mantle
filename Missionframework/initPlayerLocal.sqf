/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player. First join stays on the
    intro/island flow until the cinematic finishes, then the player is script-deployed
    to a dedicated MOB pad. Normal respawn remains a separate engine path.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER"];
uiNamespace setVariable ["MWF_IntroCallAttempted", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "NOT_CALLED"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", false];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];

private _clientBootDeadline = diag_tickTime + 120;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
    {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"} ||
    {diag_tickTime >= _clientBootDeadline}
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

    if !(uiNamespace getVariable ["MWF_InitialIntroSequenceDone", false]) then {
        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_LOCK"];
        missionNamespace setVariable ["MWF_BlockRespawn", true];
        disableUserInput true;

        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
        uiNamespace setVariable ["MWF_IntroCallAttempted", true];

        private _introPlayed = false;
        if (!isNil "MWF_fnc_playIntroCinematic") then {
            _introPlayed = [] call MWF_fnc_playIntroCinematic;
        } else {
            _introPlayed = [] call compile preprocessFileLineNumbers "functions\cinematics\MWF_fn_playIntroCinematic.sqf";
        };

        diag_log format [
            "[MWF] Intro cinematic stage=%1 played=%2",
            uiNamespace getVariable ["MWF_IntroCinematicStage", "UNKNOWN"],
            _introPlayed
        ];

        uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];

        missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY"];

        private _deployPad = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];
        if (isNull _deployPad) then {
            _deployPad = missionNamespace getVariable ["mob_deploy_pad", objNull];
        };
        if (isNull _deployPad) then {
            _deployPad = missionNamespace getVariable ["MWF_MOB_FobPad", missionNamespace getVariable ["MWF_FOB_Box_Spawn", objNull]];
        };

        private _deployed = false;
        if (!isNull _deployPad) then {
            private _deployPos = getPosATL _deployPad;
            cutText ["", "BLACK OUT", 0.01];
            player setVehiclePosition [_deployPos, [], 0, "CAN_COLLIDE"];
            player setVelocity [0,0,0];
            player setDir (getDir _deployPad);
            _deployed = true;
        } else {
            private _spawnPos = getMarkerPos "respawn_west";
            if !(_spawnPos isEqualTo [0,0,0]) then {
                cutText ["", "BLACK OUT", 0.01];
                player setVehiclePosition [_spawnPos, [], 0, "CAN_COLLIDE"];
                player setVelocity [0,0,0];
                player setDir (markerDir "respawn_west");
                _deployed = true;
            };
        };

        if (_deployed) then {
            missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_SETTLE"];
            uiSleep 0.35;
            if (!isNil "MWF_fnc_applyBaselineLoadout") then {
                [] call MWF_fnc_applyBaselineLoadout;
            };
            cutText ["", "BLACK IN", 0.75];
        };

        disableUserInput false;
        missionNamespace setVariable ["MWF_BlockRespawn", false];
        missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_DONE"];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "ASYNC_SYSTEMS"];
    [] spawn {
        uiSleep 0.25;

        missionNamespace setVariable ["MWF_ClientInitStage", "SETUP_INTERACTIONS"];
        [] call MWF_fnc_setupInteractions;

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

        [] spawn {
            uiSleep 5;
            if (!isNil "MWF_fnc_setupInteractions") then {
                [] call MWF_fnc_setupInteractions;
            };
        };

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
