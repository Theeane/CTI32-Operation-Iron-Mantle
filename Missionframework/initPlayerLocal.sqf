/*
    Author: Theane / ChatGPT
    File: initPlayerLocal.sqf
    Project: Military War Framework

    Description:
    Systems-first local bootstrap for debugging/stability.

    Goal:
    - no forced teleport
    - no intro/cinematic gate
    - no login gate
    - let Arma native respawn/deploy own initial spawn flow
    - get terminal/interactions/loadout/UI online as early and safely as possible
*/

missionNamespace setVariable ["MWF_ClientInitStage", "BOOT"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", false];
missionNamespace setVariable ["MWF_system_active", true, true];

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
        diag_log "[MWF] ERROR: systems-first initPlayerLocal aborted because player was not ready in time.";
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    if (!isNil "MWF_fnc_initUI") then {
        [] call MWF_fnc_initUI;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER_SOFT"];
    private _serverDeadline = diag_tickTime + 20;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false])
        || {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"}
        || {diag_tickTime >= _serverDeadline}
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "ASYNC_SYSTEMS"];

    [] spawn {
        uiSleep 0.5;

        missionNamespace setVariable ["MWF_ClientInitStage", "SETUP_INTERACTIONS"];
        if (!isNil "MWF_fnc_setupInteractions") then {
            [] call MWF_fnc_setupInteractions;
            [] spawn {
                uiSleep 4;
                [] call MWF_fnc_setupInteractions;
            };
            [] spawn {
                uiSleep 10;
                [] call MWF_fnc_setupInteractions;
            };
            [] spawn {
                uiSleep 20;
                [] call MWF_fnc_setupInteractions;
            };
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "LOADOUT_INIT"];
        if (!isNil "MWF_fnc_initLoadoutSystem") then {
            [] call MWF_fnc_initLoadoutSystem;
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "UNDERCOVER_INIT"];
        if (!isNil "MWF_fnc_undercoverHandler") then {
            [] spawn MWF_fnc_undercoverHandler;
        };

        if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
            missionNamespace setVariable ["MWF_ClientInitStage", "INFRA_MARKERS"];
            [] spawn MWF_fnc_infrastructureMarkerManager;
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "RESOURCE_UI"];
        if (!isNil "MWF_fnc_updateResourceUI") then {
            [] spawn MWF_fnc_updateResourceUI;
        };

        if !(player getVariable ["MWF_DamageInterruptEHAdded", false]) then {
            missionNamespace setVariable ["MWF_ClientInitStage", "DAMAGE_EH"];
            player setVariable ["MWF_DamageInterruptEHAdded", true];
            player addEventHandler ["HandleDamage", {
                params ["_unit", "_selection", "_damage", "_source", "_projectile"];
                private _currentDamage = damage _unit;
                if ((_damage > _currentDamage) || {(_projectile isEqualType "") && {_projectile isNotEqualTo ""}} || {(_source isEqualType objNull) && {!isNull _source}}) then {
                    if (!isNil "MWF_fnc_interruptSensitiveInteraction") then {
                        [] call MWF_fnc_interruptSensitiveInteraction;
                    };
                };
                _damage
            }];
        };

        missionNamespace setVariable ["MWF_ClientInitStage", "COMPLETE"];
        missionNamespace setVariable ["MWF_ClientInitComplete", true];
        diag_log format ["[MWF] SUCCESS: Systems-first local initialization completed for %1.", name player];
    };
};
