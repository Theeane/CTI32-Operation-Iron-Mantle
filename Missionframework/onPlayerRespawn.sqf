/*
    Author: Theane / ChatGPT
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Cleans up any leftover first-join cinematic locks and reapplies player-local
    post-respawn setup without replaying the intro cinematic.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_REINIT"];

[] spawn {
    waitUntil {
        uiSleep 0.1;
        !isNull player && {alive player} && {!isNull findDisplay 46}
    };

    if (!isNil "MWF_fnc_applyRespawnLoadout") then {
        private _appliedSaved = [] call MWF_fnc_applyRespawnLoadout;
        if (!_appliedSaved && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
            [] call MWF_fnc_applyBaselineLoadout;
        };
    } else {
        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [] call MWF_fnc_applyBaselineLoadout;
        };
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

    missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_READY"];
};
