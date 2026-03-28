/*
    Author: OpenAI / Operation Iron Mantle
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Unified respawn entrypoint. This is now the main gameplay bootstrap hook for both
    initial spawn (with respawnOnStart = 1) and later respawns.
*/

if (!hasInterface) exitWith {};

missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_BOOTSTRAP"];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_IntroCinematicStage", "DISABLED"];
disableUserInput false;

[] spawn {
    uiSleep 0.1;
    if (!isNil "MWF_fnc_handlePostSpawn") then {
        [false, "ONPLAYERRESPAWN"] call MWF_fnc_handlePostSpawn;
    } else {
        diag_log "[MWF] ERROR: onPlayerRespawn could not call MWF_fnc_handlePostSpawn because the function is unavailable.";
    };
};
