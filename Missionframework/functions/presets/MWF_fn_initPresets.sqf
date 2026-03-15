/*
    Author: Theane / ChatGPT
    Function: fn_initPresets
    Project: Military War Framework

    Description:
    Legacy compatibility wrapper.
    The faction system is now owned by core\MWF_fn_presetManager.sqf.
    This file intentionally forwards to the new preset manager if it is called by any old hook.
*/

if (!isServer) exitWith {};

if (!isNil "MWF_fnc_presetManager") then {
    [] call MWF_fnc_presetManager;
    diag_log "[MWF] Legacy fn_initPresets forwarded to MWF_fnc_presetManager.";
} else {
    diag_log "[MWF] Legacy fn_initPresets called, but MWF_fnc_presetManager is unavailable.";
};
