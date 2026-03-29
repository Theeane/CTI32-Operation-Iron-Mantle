/*
    Author: OpenAI / Operation Iron Mantle
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Unified respawn hook. Runs a single controlled post-spawn pass instead of
    repeated bootstrap waves.
*/

if (!hasInterface) exitWith {};

missionNamespace setVariable ["MWF_BlockRespawn", false];
missionNamespace setVariable ["MWF_ClientInitComplete", false];
missionNamespace setVariable ["MWF_PostSpawnInitRunning", false];
missionNamespace setVariable ["MWF_PostSpawnInitSince", -1];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];
missionNamespace setVariable ["MWF_LastPostSpawnSignature", ""];

disableUserInput false;

[] spawn {
    uiSleep 0.35;
    if (!isNull player && {alive player} && {!isNil "MWF_fnc_handlePostSpawn"}) then {
        [false] call MWF_fnc_handlePostSpawn;
    };

    uiSleep 1.5;
    if (!isNull player && {alive player} && {!(missionNamespace getVariable ["MWF_ClientInitComplete", false])} && {!isNil "MWF_fnc_handlePostSpawn"}) then {
        [false] call MWF_fnc_handlePostSpawn;
    };
};

diag_log format ["[MWF] Respawn event handled for %1.", name player];
