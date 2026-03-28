/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_handlePostSpawn
    Project: Military War Framework

    Description:
    Brutal post-spawn bootstrap for both the initial deploy and later respawns.
    The initial deploy path refuses to complete until the player is actually near
    a gameplay spawn position, so Arma's pre-deploy placeholder cannot consume the
    startup pass.
*/

params [
    ["_isInitialDeploy", false, [false]]
];

if (!hasInterface) exitWith { false };

private _now = diag_tickTime;
private _runningSince = missionNamespace getVariable ["MWF_PostSpawnInitSince", -1];
if (
    missionNamespace getVariable ["MWF_PostSpawnInitRunning", false]
    && {_runningSince >= 0}
    && {(_now - _runningSince) < 3}
) exitWith { false };

missionNamespace setVariable ["MWF_PostSpawnInitRunning", true];
missionNamespace setVariable ["MWF_PostSpawnInitSince", _now];
missionNamespace setVariable ["MWF_ClientInitStage", if (_isInitialDeploy) then {"INITIAL_DEPLOY_WAIT_SPAWN"} else {"RESPAWN_WAIT_SPAWN"}];

[_isInitialDeploy] spawn {
    params ["_isInitialDeploy"];

    private _spawnDeadline = diag_tickTime + 20;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {alive player}) || {diag_tickTime >= _spawnDeadline}
    };

    if (isNull player || {!alive player}) exitWith {
        missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
        missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
        missionNamespace setVariable ["MWF_ClientInitStage", "POSTSPAWN_TIMEOUT"];
        diag_log "[MWF] ERROR: Post-spawn bootstrap timed out before the player became alive.";
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
        if (_targets isEqualTo []) exitWith { true };
        (_targets findIf { player distance2D _x <= 300 }) >= 0
    };

    if (_isInitialDeploy && {!call _landedAtGameplaySpawn} && {(missionNamespace getVariable ["MWF_PlayerSpawnGeneration", 0]) <= 0}) exitWith {
        missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
        missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
        missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_WAIT_REAL_LANDING"];
        diag_log "[MWF] Post-spawn bootstrap ignored a pre-deploy player state. Waiting for actual gameplay landing.";
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
            [] spawn MWF_fnc_setupInteractions;
        };
    };

    private _appliedSaved = false;
    if (_isInitialDeploy) then {
        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [true] call MWF_fnc_applyBaselineLoadout;
        };

        {
            [_x] spawn {
                params ["_delay"];
                uiSleep _delay;
                if (!isNull player && {alive player} && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
                    private _needsReapply = (currentWeapon player isNotEqualTo "")
                        || {(vest player) isNotEqualTo ""}
                        || {(backpack player) isNotEqualTo ""}
                        || {(headgear player) isNotEqualTo ""}
                        || {!((assignedItems player) isEqualTo [])}
                        || {!((weapons player) isEqualTo [])};
                    if (_needsReapply) then {
                        [true] call MWF_fnc_applyBaselineLoadout;
                    };
                };
            };
        } forEach [1, 3, 6, 10, 20, 35];
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
            if (!isNull player && {alive player}) then {
                call _code;
            };
        };
    } forEach [1, 3, 6, 10, 20, 35];

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

    uiSleep 0.5;
    player allowDamage true;
    missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
    missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];

    diag_log format ["[MWF] SUCCESS: Post-spawn bootstrap completed for %1. Initial=%2", name player, _isInitialDeploy];
};

true
