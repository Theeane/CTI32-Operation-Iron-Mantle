/*
    Author: Theane / ChatGPT
    Function: fn_initPresets
    Project: Military War Framework

    Description:
    Handles init presets for the presets system.
*/

// 1. Read the selected options from mission parameters
private _bluforFaction = ["MWF_Param_Blufor", 0] call BIS_fnc_getParamValue;
private _opforFaction  = ["MWF_Param_Opfor", 0] call BIS_fnc_getParamValue;
private _resFaction    = ["MWF_Param_Resistance", 0] call BIS_fnc_getParamValue;
private _civFaction    = ["MWF_Param_Civilians", 0] call BIS_fnc_getParamValue;

// 2. Load the BLUFOR preset
switch (_bluforFaction) do {
    case 0: { [] execVM "Missionframework\presets\blufor\RHS_USAF_Army_Woodland.sqf" };
    case 1: { [] execVM "Missionframework\presets\blufor\CUP_BAF_Desert.sqf" };
    // Add more cases here based on description.ext
};

// 3. Load the OPFOR preset using the hash map structure
switch (_opforFaction) do {
    case 0: { [] execVM "Missionframework\presets\opfor\CUP_AFRF_Modern.sqf" };
    case 1: { [] execVM "Missionframework\presets\opfor\Contact.sqf" };
    case 2: { [] execVM "Missionframework\presets\opfor\Islamic_State.sqf" };
    // Osv...
};

// 4. Load the resistance preset using the hash map structure
switch (_resFaction) do {
    case 0: { [] execVM "Missionframework\presets\resistance\AAF.sqf" };
    case 1: { [] execVM "Missionframework\presets\resistance\RACS.sqf" };
    case 2: { [] execVM "Missionframework\presets\resistance\Vietnam_CIDG.sqf" };
};

// 5. Load the civilian preset
switch (_civFaction) do {
    case 0: { [] execVM "Missionframework\presets\civilians\European.sqf" };
    case 1: { [] execVM "Missionframework\presets\civilians\Middle_Eastern.sqf" };
    case 2: { [] execVM "Missionframework\presets\civilians\Vietnam.sqf" };
};

// Log to the RPT that all presets have been loaded
diag_log "[Iron Mantle] All presets have been successfully initialized.";
