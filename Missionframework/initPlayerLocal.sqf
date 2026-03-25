/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
*/

// Wait until server initialization is complete
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// Log player initialization start
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

    // Initialize UI
    [] call MWF_fnc_initUI;

    // Setup player interactions
    [] call MWF_fnc_setupInteractions;

    // Initialize loadout + undercover client systems
    [] call MWF_fnc_initLoadoutSystem;
    [] spawn MWF_fnc_undercoverHandler;

    // Local HQ / roadblock discovery markers
    if (!isNil "MWF_fnc_infrastructureMarkerManager") then {
        [] spawn MWF_fnc_infrastructureMarkerManager;
    };

    // Update resource display
    [] spawn MWF_fnc_updateResourceUI;

    // Lightweight local intro cinematic after actual spawn.
    if (!isNil "MWF_fnc_playIntroCinematic") then {
        [] spawn MWF_fnc_playIntroCinematic;
    };

    // Damage should interrupt sensitive interactions cleanly without granting invulnerability.
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
