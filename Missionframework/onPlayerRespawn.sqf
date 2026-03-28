/*
    Author: OpenAI / Operation Iron Mantle
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Function-first respawn hook.
    Every real respawn increments a generation counter and re-runs the same brutal
    post-spawn bootstrap several times.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
missionNamespace setVariable ["MWF_DeployUiClosed", true];
missionNamespace setVariable ["MWF_PlayerSpawnGeneration", (missionNamespace getVariable ["MWF_PlayerSpawnGeneration", 0]) + 1];

[] spawn {
    {
        [_x] spawn {
            params ["_delay"];
            uiSleep _delay;

            if (isNull player || {!alive player}) exitWith {};

            if (!isNil "MWF_fnc_handlePostSpawn") then {
                [false] call MWF_fnc_handlePostSpawn;
            };

            if (!isNil "MWF_fnc_setupInteractions") then {
                [] spawn MWF_fnc_setupInteractions;
            };

            if (!isNil "MWF_fnc_updateResourceUI") then {
                [] spawn MWF_fnc_updateResourceUI;
            };
        };
    } forEach [0, 1, 2, 4, 7, 12, 20];
};
