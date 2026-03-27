/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_handlePostSpawn
    Project: Military War Framework

    Description:
    Central post-spawn initializer used for the first playable deploy after the
    intro cinematic and for later player respawns.

    Params:
    0: BOOL - true when this is the first playable spawn after the intro/deploy menu
*/

params [
    ["_isInitialDeploy", false, [false]]
];

if (!hasInterface) exitWith { false };
if (missionNamespace getVariable ["MWF_PostSpawnInitRunning", false]) exitWith { false };

missionNamespace setVariable ["MWF_PostSpawnInitRunning", true];
missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_WAIT_SPAWN"} else {"RESPAWN_WAIT_SPAWN"}];

[_isInitialDeploy] spawn {
    params ["_isInitialDeploy"];

    waitUntil {
        uiSleep 0.1;
        !isNull player && {alive player} && {!isNull findDisplay 46}
    };

    missionNamespace setVariable ["MWF_BlockRespawn", false];
    missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_POSTSPAWN"} else {"RESPAWN_POSTSPAWN"}];
    missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
    missionNamespace setVariable ["MWF_system_active", true, true];
    player setVariable ["MWF_Player_Authenticated", true, true];

    disableUserInput false;
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
    player allowDamage false;
    player enableSimulation true;
    player setVelocity [0, 0, 0];

    ["close"] call BIS_fnc_showRespawnMenu;

    private _appliedSaved = false;
    if (_isInitialDeploy) then {
        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [] call MWF_fnc_applyBaselineLoadout;
        };
    } else {
        if (!isNil "MWF_fnc_applyRespawnLoadout") then {
            _appliedSaved = [] call MWF_fnc_applyRespawnLoadout;
            if (isNil "_appliedSaved") then {
                _appliedSaved = false;
            };
        };

        if (!_appliedSaved && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
            [] call MWF_fnc_applyBaselineLoadout;
        };
    };

    [] call MWF_fnc_setupInteractions;

    if (!(missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false])) then {
        [] call MWF_fnc_initLoadoutSystem;
    };

    if (!(missionNamespace getVariable ["MWF_UndercoverHandlerStarted", false])) then {
        [] spawn MWF_fnc_undercoverHandler;
    };

    if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
        [] spawn MWF_fnc_infrastructureMarkerManager;
    };

    [] spawn MWF_fnc_updateResourceUI;

    if !(player getVariable ["MWF_DamageInterruptEHAdded", false]) then {
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

    missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_COMPLETE"} else {"RESPAWN_READY"}];
    missionNamespace setVariable ["MWF_ClientInitComplete", true];

    if (_isInitialDeploy) then {
        missionNamespace setVariable ["MWF_InitialDeployCompleted", true];
    };

    uiSleep 0.25;
    player allowDamage true;
    missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
};

true
