/*
    Author: Theane / ChatGPT
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Unified respawn entry point.
    All real post-spawn work is handled centrally by MWF_fnc_handlePostSpawn.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];

if (!isNil "MWF_fnc_handlePostSpawn") then {
    [false] call MWF_fnc_handlePostSpawn;
} else {
    diag_log "[MWF] ERROR: onPlayerRespawn could not call MWF_fnc_handlePostSpawn because the function is missing.";
};
