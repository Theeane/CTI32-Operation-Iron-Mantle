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

// Initialize UI
[] call MWF_fnc_initUI;

// Setup player interactions
[] call MWF_fnc_setupInteractions;

// Initialize loadout + undercover client systems
[] call MWF_fnc_initLoadoutSystem;
[] spawn MWF_fnc_undercoverHandler;

// Update resource display
[] call MWF_fnc_updateResourceUI;

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

// Log completion
diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];