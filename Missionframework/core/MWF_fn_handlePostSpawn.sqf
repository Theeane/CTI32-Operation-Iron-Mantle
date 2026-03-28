/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_handlePostSpawn
    Project: Military War Framework

    Description:
    Centralized player-local post-spawn bootstrap.

    Responsibilities:
    - determine whether this is the first playable spawn
    - apply baseline/respawn loadout
    - initialize terminal interactions
    - initialize player-local systems that should be active after a real spawn
*/

params [
    ["_isInitialHint", false, [false]],
    ["_source", "UNKNOWN", [""]]
];

if (!hasInterface) exitWith { false };

if (missionNamespace getVariable ["MWF_PostSpawnInitRunning", false]) exitWith {
    diag_log format ["[MWF] PostSpawn skipped because bootstrap is already running. Source=%1", _source];
    false
};

missionNamespace setVariable ["MWF_PostSpawnInitRunning", true];

private _firstPlayableSpawn = _isInitialHint;
if !(missionNamespace getVariable ["MWF_InitialSpawnHandled", false]) then {
    _firstPlayableSpawn = true;
    missionNamespace setVariable ["MWF_InitialSpawnHandled", true];
};

private _readyDeadline = diag_tickTime + 20;
waitUntil {
    uiSleep 0.1;
    (!isNull player && {alive player} && {!isNull findDisplay 46}) || {diag_tickTime >= _readyDeadline}
};

if (isNull player || {!alive player}) exitWith {
    missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
    missionNamespace setVariable ["MWF_ClientInitStage", "POSTSPAWN_ABORTED"];
    diag_log format ["[MWF] ERROR: PostSpawn aborted because player was not alive/ready in time. Source=%1", _source];
    false
};

missionNamespace setVariable ["MWF_ClientInitStage", if (_firstPlayableSpawn) then {"INITIAL_POSTSPAWN"} else {"RESPAWN_POSTSPAWN"}];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;

if (!isNil "MWF_fnc_initUI") then {
    [] call MWF_fnc_initUI;
};

private _appliedSaved = false;
if (!_firstPlayableSpawn && {!isNil "MWF_fnc_applyRespawnLoadout"}) then {
    _appliedSaved = [] call MWF_fnc_applyRespawnLoadout;
    if (isNil "_appliedSaved") then {
        _appliedSaved = false;
    };
};

if ((!_appliedSaved) && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
    [] call MWF_fnc_applyBaselineLoadout;
};

missionNamespace setVariable ["MWF_ClientInitStage", "SETUP_INTERACTIONS"];
[] call MWF_fnc_setupInteractions;
[] spawn {
    uiSleep 3;
    [] call MWF_fnc_setupInteractions;
};
[] spawn {
    uiSleep 8;
    [] call MWF_fnc_setupInteractions;
};

missionNamespace setVariable ["MWF_ClientInitStage", "LOADOUT_INIT"];
if (!isNil "MWF_fnc_initLoadoutSystem") then {
    [] call MWF_fnc_initLoadoutSystem;
};

if (!(missionNamespace getVariable ["MWF_UndercoverLoopStarted", false]) && {!isNil "MWF_fnc_undercoverHandler"}) then {
    missionNamespace setVariable ["MWF_UndercoverLoopStarted", true];
    [] spawn MWF_fnc_undercoverHandler;
};

if (!(missionNamespace getVariable ["MWF_InfrastructureMarkerLoopStarted", false]) && {!isNil "MWF_fnc_infrastructureMarkerManager"}) then {
    missionNamespace setVariable ["MWF_InfrastructureMarkerLoopStarted", true];
    [] spawn MWF_fnc_infrastructureMarkerManager;
};

if (!isNil "MWF_fnc_updateResourceUI") then {
    [] spawn MWF_fnc_updateResourceUI;
};

if !(player getVariable ["MWF_DamageInterruptEHAdded", false]) then {
    player setVariable ["MWF_DamageInterruptEHAdded", true];
    player addEventHandler ["HandleDamage", {
        params ["_unit", "_selection", "_damage", "_sourceObj", "_projectile"];
        private _currentDamage = damage _unit;
        if ((_damage > _currentDamage) || {(_projectile isEqualType "") && {_projectile isNotEqualTo ""}} || {(_sourceObj isEqualType objNull) && {!isNull _sourceObj}}) then {
            [] call MWF_fnc_interruptSensitiveInteraction;
        };
        _damage
    }];
};

private _generation = (missionNamespace getVariable ["MWF_PostSpawnGeneration", 0]) + 1;
missionNamespace setVariable ["MWF_PostSpawnGeneration", _generation];
missionNamespace setVariable ["MWF_ClientInitStage", if (_firstPlayableSpawn) then {"INITIAL_READY"} else {"RESPAWN_READY"}];
missionNamespace setVariable ["MWF_ClientInitComplete", true];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];

diag_log format [
    "[MWF] SUCCESS: PostSpawn bootstrap complete. Initial=%1 Source=%2 Generation=%3",
    _firstPlayableSpawn,
    _source,
    _generation
];

true
