/*
    Author: Theeane / Gemini
    Description: 
    Initializes global variables based on Mission Parameters.
    Handles faction folder assignment and starting resources.
    Language: English
*/

if (!isServer) exitWith {};

// --- 1. STARTING SUPPLIES ---
// Fetches value from AGS_Param_StartSupplies in Params.hpp
private _startSupplies = "AGS_Param_StartSupplies" call BIS_fnc_getParamValue;

// Only set if not already defined (prevents overwriting persistence)
if (isNil "GVAR_Economy_Supplies") then {
    missionNamespace setVariable ["GVAR_Economy_Supplies", _startSupplies, true];
};

// --- 2. FACTION SELECTION ---
private _bluforParam = "AGS_Param_Blufor" call BIS_fnc_getParamValue;
private _opforParam = "AGS_Param_Opfor" call BIS_fnc_getParamValue;
private _civParam   = "AGS_Param_Civs"   call BIS_fnc_getParamValue;

// Map Parameter indices to folder names
private _bluforFolder = switch (_bluforParam) do {
    case 0: { "vanilla_nato" };
    case 1: { "rhs_us_army" };
    case 99: { "custom" };
    default { "vanilla_nato" };
};

private _opforFolder = switch (_opforParam) do {
    case 0: { "vanilla_csat" };
    case 1: { "rhs_russia_msv" };
    case 99: { "custom" };
    default { "vanilla_csat" };
};

private _civFolder = switch (_civParam) do {
    case 0: { "vanilla_civ" };
    case 1: { "rhs_civ" };
    case 99: { "custom_civ" };
    default { "vanilla_civ" };
};

// Store folder names globally for other scripts to reference
missionNamespace setVariable ["GVAR_Faction_Blufor_Folder", _bluforFolder, true];
missionNamespace setVariable ["GVAR_Faction_Opfor_Folder", _opforFolder, true];
missionNamespace setVariable ["GVAR_Faction_Civ_Folder", _civFolder, true];

// --- 3. AUTO-LOAD UNIT CONFIGS ---
// This attempts to execute the units.sqf within the selected faction folders
{
    private _path = format ["factions\%1\units.sqf", _x];
    if (fileExists _path) then {
        [] execVM _path;
        diag_log format ["[AGS] Globals: Loaded faction file: %1", _path];
    } else {
        diag_log format ["[AGS] Globals: WARNING - Faction file not found: %1", _path];
    };
} forEach [_bluforFolder, _opforFolder, _civFolder];

// --- 4. ADDITIONAL PARAMETERS ---
private _notorietyMult = "AGS_Param_NotorietyMultiplier" call BIS_fnc_getParamValue;
missionNamespace setVariable ["GVAR_Economy_HeatMult", _notorietyMult, true];

private _supplyTimer = "AGS_Param_SupplyTimer" call BIS_fnc_getParamValue;
missionNamespace setVariable ["GVAR_Economy_SupplyInterval", _supplyTimer
