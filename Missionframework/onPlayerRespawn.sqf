/*
    Author: Theane / ChatGPT
    File: onPlayerRespawn.sqf
    Project: Military War Framework

    Description:
    Unified respawn entry point.
    All real post-spawn work is handled centrally by MWF_fnc_handlePostSpawn.
    The call is deferred slightly so Arma has time to finish the actual respawn.
*/

missionNamespace setVariable ["MWF_BlockRespawn", false];
disableUserInput false;
uiNamespace setVariable ["MWF_IntroCinematicActive", false];
uiNamespace setVariable ["MWF_InitialIntroSequenceDone", true];
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", false];
missionNamespace setVariable ["MWF_ClientInitStage", "RESPAWN_TRIGGERED"];

[] spawn {
    private _deadline = diag_tickTime + 20;
    waitUntil {
        uiSleep 0.1;
        (!isNull player && {alive player} && {!visibleMap} && {!isNull findDisplay 46}) || {diag_tickTime >= _deadline}
    };

    if (!isNil "MWF_fnc_handlePostSpawn") then {
        [false] call MWF_fnc_handlePostSpawn;
    } else {
        diag_log "[MWF] ERROR: onPlayerRespawn could not call MWF_fnc_handlePostSpawn because the function is missing.";
    };
};
