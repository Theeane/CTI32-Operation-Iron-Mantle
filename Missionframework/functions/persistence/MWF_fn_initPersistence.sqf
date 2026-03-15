/*
    Author: Theane / ChatGPT
    Function: fn_initPersistence
    Project: Military War Framework

    Description:
    Starts the persistence loop and provides a delayed save helper without requiring external frameworks.
*/

if (!isServer) exitWith {};

private _intervalSeconds = (["MWF_Param_SaveInterval", 15] call BIS_fnc_getParamValue) * 60;

if !(missionNamespace getVariable ["MWF_AutoSaveLoopStarted", false]) then {
    missionNamespace setVariable ["MWF_AutoSaveLoopStarted", true, true];

    [] spawn {
        private _interval = missionNamespace getVariable ["MWF_PersistenceIntervalSeconds", 900];
        while {true} do {
            uiSleep _interval;
            ["Scheduled Auto Save"] call MWF_fnc_saveGame;
        };
    };
};

missionNamespace setVariable ["MWF_PersistenceIntervalSeconds", _intervalSeconds, true];
missionNamespace setVariable ["MWF_savePending", false, true];

MWF_fnc_requestDelayedSave = {
    if (!isServer) exitWith {};
    if (missionNamespace getVariable ["MWF_savePending", false]) exitWith {};

    missionNamespace setVariable ["MWF_savePending", true, true];

    [] spawn {
        uiSleep 5;
        ["Resource Update"] call MWF_fnc_saveGame;
        missionNamespace setVariable ["MWF_savePending", false, true];
    };
};

diag_log format ["[MWF] Persistence initialized. Auto save interval: %1 seconds.", _intervalSeconds];
