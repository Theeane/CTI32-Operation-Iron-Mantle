/*
    Author: Theane / ChatGPT
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Handles both the first post-cinematic deploy spawn and later death respawns.
    The intro cinematic is never replayed here.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];

private _initialDeploy = missionNamespace getVariable ["MWF_InitialDeployPending", false];
if (_initialDeploy) then {
    missionNamespace setVariable ["MWF_ClientInitStage", "INITIAL_DEPLOY_RESPAWN"];
    missionNamespace setVariable ["MWF_InitialDeployPending", false];
    setPlayerRespawnTime 5;
} else {
    missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_REINIT"];
};

missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];

[_initialDeploy] spawn {
    params [["_initialDeployLocal", false, [true]]];

    waitUntil {
        uiSleep 0.1;
        !isNull player && {alive player} && {!isNull findDisplay 46}
    };

    cutText ["", "BLACK IN", 0.25];
    player allowDamage true;
    player enableSimulation true;
    player setVariable ["MWF_Player_Authenticated", true, true];
    missionNamespace setVariable ["MWF_system_active", true, true];

    private _appliedSaved = false;
    if (_initialDeployLocal) then {
        if (!isNil "MWF_fnc_applyBaselineLoadout") then {
            [] call MWF_fnc_applyBaselineLoadout;
        };

        if (!isNil "MWF_fnc_registerAuthenticatedPlayer") then {
            [player] remoteExecCall ["MWF_fnc_registerAuthenticatedPlayer", 2];
        };
    } else {
        if (!isNil "MWF_fnc_applyRespawnLoadout") then {
            _appliedSaved = [] call MWF_fnc_applyRespawnLoadout;
            if (isNil "_appliedSaved") then {
                _appliedSaved = false;
            };
        };

        if (!_appliedSaved && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
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

    [] call MWF_fnc_setupInteractions;

    if !(missionNamespace getVariable ["MWF_RuntimeSystemsInitialized", false]) then {
        missionNamespace setVariable ["MWF_RuntimeSystemsInitialized", true];

        [] spawn {
            uiSleep 4;
            [] call MWF_fnc_setupInteractions;
        };
        [] spawn {
            uiSleep 10;
            [] call MWF_fnc_setupInteractions;
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

        if (!isNil "MWF_fnc_updateResourceUI") then {
            [] spawn MWF_fnc_updateResourceUI;
        };
    } else {
        if (!isNil "MWF_fnc_updateResourceUI") then {
            [] spawn MWF_fnc_updateResourceUI;
        };
    };

    missionNamespace setVariable ["MWF_ClientInitStage", if (_initialDeployLocal) then { "INITIAL_DEPLOY_READY" } else { "RESPAWN_READY" }];
    missionNamespace setVariable ["MWF_ClientInitComplete", true];
    diag_log format ["[MWF] SUCCESS: Player respawn initialization completed for %1. Initial deploy=%2", name player, _initialDeployLocal];
};
