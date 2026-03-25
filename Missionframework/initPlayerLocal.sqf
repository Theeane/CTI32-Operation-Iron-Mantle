/*
    Author: Theeane / ChatGPT / Gemini
    File: initPlayerLocal.sqf
    Project: Military War Framework
    Description:
    Handles client-side initialization for each player.
    Defers world-facing startup until the initial respawn/map flow is finished,
    so intro cinematic and interactions do not run invisibly behind the respawn UI.
*/

// Wait until server initialization is complete
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// Log player initialization start
diag_log format ["[MWF] INFO: Player initialization started for %1.", name player];

// Initialize UI settings as soon as the client is authenticated.
[] call MWF_fnc_initUI;

[] spawn {
    // Wait for a real controllable player body.
    waitUntil { !isNull player };
    waitUntil { alive player };

    // When respawnOnStart/MenuPosition is active, Arma can run local init while the
    // respawn/map UI is still open. Wait until that flow is finished so the player
    // actually sees the intro and receives interactions on the first visible frame.
    waitUntil {
        uiSleep 0.1;
        alive player && {!visibleMap}
    };

    uiSleep 0.25;

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

    // Lightweight local intro cinematic near mission start to cover script warmup.
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

    // Log completion
    diag_log format ["[MWF] SUCCESS: Player initialization completed for %1.", name player];
};
