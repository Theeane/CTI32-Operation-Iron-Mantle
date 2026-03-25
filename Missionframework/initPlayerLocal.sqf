/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
*/

private _clientBootDeadline = diag_tickTime + 90;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
    {diag_tickTime >= _clientBootDeadline}
};

if (!(missionNamespace getVariable ["MWF_ServerInitialized", false])) then {
    diag_log "[MWF] WARNING: Client init timeout reached before server-ready flag. Continuing with local startup.";
};

diag_log format ["[MWF] INFO: Player initialization started for %1.", name player];

[] spawn {
    waitUntil { !isNull player };
    waitUntil { alive player };

    private _spawnPos = getMarkerPos "respawn_west";
    waitUntil {
        uiSleep 0.25;
        alive player
        && {!visibleMap}
        && {!dialog}
        && {!isNull findDisplay 46}
        && ((_spawnPos isEqualTo [0,0,0]) || {player distance2D _spawnPos < 40})
    };

    uiSleep 1;

    [] call MWF_fnc_initUI;
    [] call MWF_fnc_setupInteractions;
    [] call MWF_fnc_initLoadoutSystem;
    [] spawn MWF_fnc_undercoverHandler;

    if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
        [] spawn MWF_fnc_infrastructureMarkerManager;
    };

    [] spawn MWF_fnc_updateResourceUI;

    if (!isNil "MWF_fnc_playIntroCinematic") then {
        [] spawn MWF_fnc_playIntroCinematic;
    };

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

    diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
};
