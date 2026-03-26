/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player. Uses a timeout and the
    CRITICAL_RELEASED boot stage so local systems are never hard-locked behind
    slower background server work.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER"];

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

    private _spawnPos = getMarkerPos "respawn_west";
    missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_WORLD_READY"];
    waitUntil {
        uiSleep 0.25;
        alive player
        && {!visibleMap}
        && {!dialog}
        && {!isNull findDisplay 46}
        && ((_spawnPos isEqualTo [0,0,0]) || {player distance2D _spawnPos < 40})
    };

    uiSleep 1;

    missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
    [] call MWF_fnc_initUI;

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

    if (!isNil "MWF_fnc_playIntroCinematic") then {
        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CINEMATIC"];
        [] spawn MWF_fnc_playIntroCinematic;
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "COMPLETE"];
    missionNamespace setVariable ["MWF_ClientInitComplete", true];
    diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
};
