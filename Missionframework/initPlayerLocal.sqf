/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
    The intro cinematic is kicked off early and in its own script so later local
    subsystem errors cannot prevent it from running.
*/

missionNamespace setVariable ["MWF_ClientInitStage", "WAIT_SERVER"];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_ClientUIInitDone", false];
missionNamespace setVariable ["MWF_ClientInteractionsInitDone", false];
missionNamespace setVariable ["MWF_ClientLoadoutInitDone", false];

private _clientBootDeadline = diag_tickTime + 120;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
    { (missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED" } ||
    { diag_tickTime >= _clientBootDeadline }
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

    uiSleep 0.5;

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
        missionNamespace setVariable ["MWF_ClientInitStage", "INTRO_CALL"];
        uiNamespace setVariable ["MWF_IntroCallAttempted", true];
        [] spawn MWF_fnc_playIntroCinematic;
    };

    [] spawn {
        missionNamespace setVariable ["MWF_ClientInitStage", "INIT_UI"];
        [] call MWF_fnc_initUI;
        missionNamespace setVariable ["MWF_ClientUIInitDone", true];
    };

    [] spawn {
        missionNamespace setVariable ["MWF_ClientInitStage", "SETUP_INTERACTIONS"];
        [] call MWF_fnc_setupInteractions;
        missionNamespace setVariable ["MWF_ClientInteractionsInitDone", true];
    };

    [] spawn {
        missionNamespace setVariable ["MWF_ClientInitStage", "LOADOUT_INIT"];
        [] call MWF_fnc_initLoadoutSystem;
        missionNamespace setVariable ["MWF_ClientLoadoutInitDone", true];
    };

    missionNamespace setVariable ["MWF_ClientInitStage", "UNDERCOVER_INIT"];
    [] spawn MWF_fnc_undercoverHandler;

    if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
        [] spawn MWF_fnc_infrastructureMarkerManager;
    };

    [] spawn MWF_fnc_updateResourceUI;

    missionNamespace setVariable ["MWF_ClientInitStage", "COMPLETE"];
    missionNamespace setVariable ["MWF_ClientInitComplete", true];
    diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
};
