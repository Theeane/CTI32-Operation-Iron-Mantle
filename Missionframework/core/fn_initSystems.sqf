/*
    Author: Theane / ChatGPT
    Function: fn_initSystems
    Project: Military War Framework

    Description:
    Initializes core framework settings that should exist before background systems start.
*/

if (!isServer) exitWith {};

missionNamespace setVariable ["MWF_CoreVersion", "1.0", true];
missionNamespace setVariable ["MWF_isWiping", false, true];

setTimeMultiplier (["MWF_Param_TimeMultiplier", 1] call BIS_fnc_getParamValue);

private _wipeRequested = ["MWF_Param_WipeSave", 0] call BIS_fnc_getParamValue;
private _wipeConfirmed = ["MWF_Param_ConfirmWipe", 0] call BIS_fnc_getParamValue;

if (_wipeRequested == 1 && _wipeConfirmed == 1) then {
    missionNamespace setVariable ["MWF_isWiping", true, true];
    diag_log "[MWF] Save wipe requested by lobby parameters.";
};

missionNamespace setVariable ["MWF_systems_ready", true, true];
diag_log "[MWF] Core systems initialized.";
