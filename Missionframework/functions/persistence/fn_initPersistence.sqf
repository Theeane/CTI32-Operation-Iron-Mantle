/*
    Author: Theane / ChatGPT
    Function: fn_initPersistence
    Project: Military War Framework

    Description:
    Starts the persistence loop and provides a delayed save helper for bursty resource updates.
*/

if (!isServer) exitWith {};

private _intervalSeconds = (["MWF_Param_SaveInterval", 15] call BIS_fnc_getParamValue) * 60;

[
    {
        ["Scheduled Auto Save"] call MWF_fnc_saveGame;
    },
    _intervalSeconds
] call CBA_fnc_addPerFrameHandler;

MWF_fnc_requestDelayedSave = {
    if (!isServer) exitWith {};
    if (missionNamespace getVariable ["MWF_savePending", false]) exitWith {};

    missionNamespace setVariable ["MWF_savePending", true];

    [
        {
            ["Resource Update"] call MWF_fnc_saveGame;
            missionNamespace setVariable ["MWF_savePending", false];
        },
        [],
        5
    ] call CBA_fnc_waitAndExecute;
};

diag_log format ["[MWF] Persistence initialized. Auto save interval: %1 seconds.", _intervalSeconds];
