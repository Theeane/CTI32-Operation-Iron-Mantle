/*
    Author: Theeane / PETG
    Description: Dynamic Faction Loader for Operation Iron Mantle.
    Language: English
*/

if (!isServer) exitWith {};

// --- 1. RESOURCES ---
private _startSupplies = "AGS_Param_StartSupplies" call BIS_fnc_getParamValue;
missionNamespace setVariable ["GVAR_Economy_Supplies", _startSupplies, true];

// --- 2. DYNAMIC LOADER FUNCTION ---
// Helper function to load preset files cleanly and handle missing files
private _fnc_loadPreset = {
    params ["_folder", "_file"];
    private _path = format ["Missionframework\preset\%1\%2", _folder, _file];
    
    if (fileExists _path) then {
        [] execVM _path;
        diag_log format ["[AGS] Loaded Preset: %1", _path];
    } else {
        diag_log format ["[AGS] ERROR: File not found: %1", _path];
    };
};

// --- 3. BLUFOR ---
private _bluFile = switch ("AGS_Param_Blufor" call BIS_fnc_getParamValue) do {
    case 0: {"NATO.sqf"}; case 1: {"NATO_Pacific.sqf"}; case 2: {"CUP_ACR_Desert.sqf"};
    case 3: {"CUP_ACR_Woodland.sqf"}; case 4: {"CUP_BAF_Desert.sqf"}; case 5: {"CUP_BAF_Woodland.sqf"};
    case 6: {"CUP_USA_Desert.sqf"}; case 7: {"CUP_USA_Woodland.sqf"}; case 8: {"CUP_USMC_Desert.sqf"};
    case 9: {"GM_West_Germany.sqf"}; case 10: {"LDF_Contact.sqf"}; case 11: {"RHS_USAF_Desert.sqf"};
    case 99: {"Custom_NATO.sqf"}; default {"NATO.sqf"};
};
["blufor", _bluFile] call _fnc_loadPreset;

// --- 4. OPFOR ---
private _opfFile = switch ("AGS_Param_Opfor" call BIS_fnc_getParamValue) do {
    case 0: {"CSAT.sqf"}; case 1: {"CSAT_Pacific.sqf"}; case 2: {"CUP_AFRF_EMR.sqf"};
    case 3: {"CUP_AFRF_Modern.sqf"}; case 4: {"CUP_CDF.sqf"}; case 5: {"CUP_ChDKZ.sqf"};
    case 6: {"Contact.sqf"}; case 7: {"GM_East_Germany.sqf"}; case 8: {"Islamic_State.sqf"};
    case 9: {"RHS_AFRF.sqf"}; case 10: {"Takistan_Army.sqf"}; case 11: {"Unsung_Vietnam.sqf"};
    case 99: {"Custom.sqf"}; default {"CSAT.sqf"};
};
["opfor", _opfFile] call _fnc_loadPreset;

// --- 5. RESISTANCE ---
private _resFile = switch ("AGS_Param_Resistance" call BIS_fnc_getParamValue) do {
    case 0: {"AAF.sqf"}; case 1: {"CUP_NAPA.sqf"}; case 2: {"LDF_Resistance.sqf"};
    case 3: {"Middle_Eastern.sqf"}; case 4: {"RACS.sqf"}; case 5: {"RHS_GREF.sqf"};
    case 6: {"Syndikat.sqf"}; case 7: {"Vietnam_CIDG.sqf"};
    case 99: {"Custom.sqf"}; default {"AAF.sqf"};
};
["resistance", _resFile] call _fnc_loadPreset;

// --- 6. CIVILIANS ---
private _civFile = switch ("AGS_Param_Civs" call BIS_fnc_getParamValue) do {
    case 0: {"Arma3_Civ.sqf"}; case 1: {"CUP_ChernoCivs.sqf"}; case 2: {"CUP_TakiCivs.sqf"};
    case 3: {"Contact_Civ.sqf"}; case 4: {"Eastern_European.sqf"}; case 5: {"Global_Mobilization.sqf"};
    case 6: {"Middle_Eastern.sqf"}; case 7: {"RDSCiv.sqf"}; case 8: {"Tanoa_Civ.sqf"};
    case 9: {"Vietnam_Unsung.sqf"};
    case 99: {"Custom.sqf"}; default {"Arma3_Civ.sqf"};
};
["civilians", _civFile] call _fnc_loadPreset;

// --- 7. SYSTEM & ECONOMY TIMERS ---
private _supplyTimer = "AGS_Param_SupplyTimer" call BIS_fnc_getParamValue;
missionNamespace setVariable ["GVAR_Economy_SupplyInterval", _supplyTimer, true];

diag_log "[AGS] All faction globals and economy parameters initialized.";
