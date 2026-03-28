/*
    Author: OpenAI / Operation Iron Mantle
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Unified respawn hook. This script triggers the client-side bootstrap 
    every time a player object is created and placed in the world.
*/

if (!hasInterface) exitWith {};

// 1. Reset client states to allow a clean re-init
missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];

// 2. Clear UI artifacts
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];

// 3. Execution Loop
// We spawn this to ensure we don't block the engine's respawn flow.
// We run the bootstrap multiple times with increasing delays to ensure 
// that even with network lag, the interactions and systems eventually "catch".
[] spawn {
    // Small initial sleep to let the player object settle in the world
    uiSleep 0.5;

    {
        [_x] spawn {
            params ["_delay"];
            uiSleep _delay;

            // Safety check: only run if the player is actually alive
            if (isNull player || {!alive player}) exitWith {};

            // Trigger the centralized post-spawn logic
            // First parameter 'false' indicates this is a standard spawn (not initial forced deploy)
            if (!isNil "MWF_fnc_handlePostSpawn") then {
                [false] call MWF_fnc_handlePostSpawn;
            };

            // Ensure interactions are updated (finds the laptop/terminal)
            if (!isNil "MWF_fnc_setupInteractions") then {
                [] spawn MWF_fnc_setupInteractions;
            };

            // Refresh the Resource Bar (Supplies/Intel)
            if (!isNil "MWF_fnc_updateResourceUI") then {
                [] spawn MWF_fnc_updateResourceUI;
            };
        };
    } forEach [0, 2, 5, 10, 20]; // Staggered retry waves
};

diag_log format ["[MWF] Respawn event handled for %1. Bootstrap sequence started.", name player];