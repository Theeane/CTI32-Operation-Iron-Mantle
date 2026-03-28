/*
    Author: OpenAI / Operation Iron Mantle
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Function-first respawn hook.
    Fires the same post-spawn/bootstrap path several times so normal death respawns
    recover even if Arma delays one specific callback/frame.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];

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
    } forEach [0, 1, 3, 6, 10];
};
