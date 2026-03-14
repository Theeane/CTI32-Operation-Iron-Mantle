/*
    Author: Theane / ChatGPT
    Function: fn_initGlobals
    Project: Military War Framework

    Description:
    Initializes shared global state, synchronizes core resource variables, and loads the selected faction presets.
*/

if (!isServer) exitWith {};

private _startSupplies = ["MWF_Param_StartSupplies", 200] call BIS_fnc_getParamValue;
private _startCivRep = ["MWF_Param_CivReputation", 0] call BIS_fnc_getParamValue;

if (isNil "MWF_Economy_Supplies") then {
    missionNamespace setVariable ["MWF_Economy_Supplies", _startSupplies, true];
};
if (isNil "MWF_res_intel") then {
    missionNamespace setVariable ["MWF_res_intel", 0, true];
};
if (isNil "MWF_res_notoriety") then {
    missionNamespace setVariable ["MWF_res_notoriety", 0, true];
};
if (isNil "MWF_CivRep") then {
    missionNamespace setVariable ["MWF_CivRep", _startCivRep, true];
};

missionNamespace setVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", _startSupplies], true];
missionNamespace setVariable ["MWF_Intel", missionNamespace getVariable ["MWF_res_intel", 0], true];

private _fnc_loadPreset = {
    params ["_folder", "_file"];
    private _path = format ["preset\%1\%2", _folder, _file];

    if (fileExists _path) then {
        [] execVM _path;
        diag_log format ["[MWF] Loaded preset: %1", _path];
    } else {
        diag_log format ["[MWF] Missing preset file: %1", _path];
    };
};

private _bluforFile = switch (["MWF_Param_Blufor", 0] call BIS_fnc_getParamValue) do {
    case 0:  {"NATO.sqf"};
    case 1:  {"NATO_Pacific.sqf"};
    case 2:  {"NATO_Woodland.sqf"};
    case 3:  {"CUP_ACR_Desert.sqf"};
    case 4:  {"CUP_ACR_Woodland.sqf"};
    case 5:  {"CUP_BAF_Desert.sqf"};
    case 6:  {"CUP_BAF_Woodland.sqf"};
    case 7:  {"CUP_USA_Desert.sqf"};
    case 8:  {"CUP_USA_Woodland.sqf"};
    case 9:  {"CUP_USMC_Desert.sqf"};
    case 10: {"GM_West_Germany.sqf"};
    case 11: {"LDF_Contact.sqf"};
    case 12: {"RHS_USAF_Desert.sqf"};
    case 13: {"RHS_USAF_Woodland.sqf"};
    case 14: {"SOG_MACV.sqf"};
    case 15: {"ws_blufor_desert.sqf"};
    case 99: {"Custom"};
    default {"NATO.sqf"};
};
["blufor", _bluforFile] call _fnc_loadPreset;

private _opforFile = switch (["MWF_Param_Opfor", 0] call BIS_fnc_getParamValue) do {
    case 0:  {"CSAT.sqf"};
    case 1:  {"CSAT_Pacific.sqf"};
    case 2:  {"CUP_AFRF_EMR.sqf"};
    case 3:  {"CUP_AFRF_Modern.sqf"};
    case 4:  {"CUP_CDF.sqf"};
    case 5:  {"CUP_ChDKZ.sqf"};
    case 6:  {"Contact.sqf"};
    case 7:  {"GM_East_Germany.sqf"};
    case 8:  {"Islamic_State.sqf"};
    case 9:  {"RHS_AFRF.sqf"};
    case 10: {"Takistan_Army.sqf"};
    case 11: {"Unsung_Vietnam.sqf"};
    case 99: {"Custom"};
    default {"CSAT.sqf"};
};
["opfor", _opforFile] call _fnc_loadPreset;

private _resistanceFile = switch (["MWF_Param_Resistance", 0] call BIS_fnc_getParamValue) do {
    case 0:  {"AAF.sqf"};
    case 1:  {"CUP_NAPA.sqf"};
    case 2:  {"LDF_Resistance.sqf"};
    case 3:  {"Middle_Eastern.sqf"};
    case 4:  {"RACS.sqf"};
    case 5:  {"RHS_GREF.sqf"};
    case 6:  {"Syndikat.sqf"};
    case 7:  {"Vietnam_CIDG.sqf"};
    case 99: {"Custom"};
    default {"AAF.sqf"};
};
["resistance", _resistanceFile] call _fnc_loadPreset;

private _civilianFile = switch (["MWF_Param_Civs", 0] call BIS_fnc_getParamValue) do {
    case 0:  {"Arma3_Civ.sqf"};
    case 1:  {"CUP_ChernoCivs.sqf"};
    case 2:  {"CUP_TakiCivs.sqf"};
    case 3:  {"Contact_Civ.sqf"};
    case 4:  {"Eastern_European.sqf"};
    case 5:  {"Global_Mobilization.sqf"};
    case 6:  {"Middle_Eastern.sqf"};
    case 7:  {"RDSCiv.sqf"};
    case 8:  {"Tanoa_Civ.sqf"};
    case 9:  {"Vietnam_Unsung.sqf"};
    case 99: {"Custom.sqf"};
    default {"Arma3_Civ.sqf"};
};
["civilians", _civilianFile] call _fnc_loadPreset;

missionNamespace setVariable ["MWF_Economy_SupplyInterval", ["MWF_Param_SupplyTimer", 10] call BIS_fnc_getParamValue, true];
missionNamespace setVariable ["MWF_Economy_HeatMult", ["MWF_Param_NotorietyMultiplier", 1] call BIS_fnc_getParamValue, true];

diag_log "[MWF] Global state initialized.";
