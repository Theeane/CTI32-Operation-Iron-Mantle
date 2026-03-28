/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_handlePostSpawn
    Project: Military War Framework

    Description:
    Central post-spawn initializer used for the first playable deploy and for all
    later death respawns.

    This version is intentionally aggressive about waking client systems.
    Instead of relying on one one-shot runtime gate, it starts the core local
    systems every time and lets those systems use their own singleton guards.
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

    private _spawnDeadline = diag_tickTime + 20;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {alive player} && {!isNull findDisplay 46}) || {diag_tickTime >= _spawnDeadline}
    };

    if (isNull player || {!alive player}) exitWith {
        missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
        missionNamespace setVariable ["MWF_ClientInitStage", "POSTSPAWN_TIMEOUT"];
        diag_log "[MWF] ERROR: Post-spawn bootstrap timed out before the player became playable.";
    };

    missionNamespace setVariable ["MWF_BlockRespawn", false];
    missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_POSTSPAWN"} else {"RESPAWN_POSTSPAWN"}];
    missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
    missionNamespace setVariable ["MWF_system_active", true, true];
    missionNamespace setVariable ["MWF_RuntimeSystemsInitialized", true];
    player setVariable ["MWF_Player_Authenticated", true, true];

    disableUserInput false;
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
    cutText ["", "BLACK IN", 0.25];
    player allowDamage false;
    player enableSimulation true;
    player setVelocity [0, 0, 0];

    private _kickClientSystems = {
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
            [] call MWF_fnc_setupInteractions;
        };
    };

    private _applyInitialBaseline = {
        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [true] call MWF_fnc_applyBaselineLoadout;
        };
    };

    private _appliedSaved = false;
    if (_isInitialDeploy) then {
        call _applyInitialBaseline;

        {
            [_x] spawn {
                params ["_delay"];
                uiSleep _delay;

                if (!isNull player && {alive player}) then {
                    private _needsReapply = (currentWeapon player isNotEqualTo "")
                        || {(vest player) isNotEqualTo ""}
                        || {(backpack player) isNotEqualTo ""}
                        || {(headgear player) isNotEqualTo ""}
                        || {!((assignedItems player) isEqualTo [])}
                        || {!((weapons player) isEqualTo [])};

                    if (_needsReapply && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
                        [true] call MWF_fnc_applyBaselineLoadout;
                    };
                };
            };
        } forEach [1, 3];
    } else {
        if (!isNil "MWF_fnc_applyRespawnLoadout") then {
            _appliedSaved = [] call MWF_fnc_applyRespawnLoadout;
            if (isNil "_appliedSaved") then {
                _appliedSaved = false;
            };
        };

        if (!_appliedSaved && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
            [false] call MWF_fnc_applyBaselineLoadout;
        };
    };

    if (!isNil "MWF_fnc_registerAuthenticatedPlayer") then {
        [player] remoteExecCall ["MWF_fnc_registerAuthenticatedPlayer", 2];
    };

    call _kickClientSystems;
    {
        [_x, _kickClientSystems] spawn {
            params ["_delay", "_code"];
            uiSleep _delay;
            call _code;
        };
    } forEach [1, 3, 6, 10];

    if !(player getVariable ["MWF_DamageInterruptEHAdded", false]) then {
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

    missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_READY"} else {"RESPAWN_READY"}];
    missionNamespace setVariable ["MWF_ClientInitComplete", true];

    if (_isInitialDeploy) then {
        missionNamespace setVariable ["MWF_InitialDeployCompleted", true];
    };

    uiSleep 0.25;
    player allowDamage true;
    missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];

    diag_log format ["[MWF] SUCCESS: Post-spawn bootstrap completed for %1. Initial=%2", name player, _isInitialDeploy];
};

true
