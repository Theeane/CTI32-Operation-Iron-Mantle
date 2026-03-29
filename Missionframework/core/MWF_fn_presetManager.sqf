/*
    Author: Theane / ChatGPT
    Function: MWF_fn_presetManager
    Project: Military War Framework

    Description:
    Resolves default vs custom faction presets for BLUFOR, OPFOR, RESISTANCE and CIVILIANS.
    This function owns the faction fallback logic, loads the resolved preset files, stores a
    campaign-safe preset registry in missionNamespace, and persists locked faction choices so they
    survive server restarts.

    Rules:
    - Default presets remain the current project defaults.
    - Custom presets are loaded from preset\<side>\custom\custom_X.sqf.
    - If a selected custom file is missing, the system falls back to custom_1.sqf.
    - Faction source + preset choice are campaign-persistent and must not drift across restarts.
*/

if (!isServer) exitWith {};

private _factionMap = createHashMap;

private _persistKeys = {
    params ["_prefix"];

    profileNamespace setVariable [format ["MWF_Save_%1Source", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Source", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1Choice", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Choice", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1ResolvedChoice", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1ResolvedChoice", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1Label", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Label", _prefix], ""]];
    profileNamespace setVariable [format ["MWF_Save_%1File", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1File", _prefix], ""]];
};

private _resolveSide = {
    params [
        "_prefix",
        "_displayName",
        "_folder",
        "_sourceParamName",
        "_defaultParamName",
        "_customParamName",
        "_defaultFiles",
        "_defaultLabels",
        "_defaultFallbackFile"
    ];

    private _lockedSourceVar = format ["MWF_Locked_%1Source", _prefix];
    private _lockedChoiceVar = format ["MWF_Locked_%1Choice", _prefix];
    private _lockedResolvedChoiceVar = format ["MWF_Locked_%1ResolvedChoice", _prefix];
    private _lockedLabelVar = format ["MWF_Locked_%1Label", _prefix];
    private _lockedFileVar = format ["MWF_Locked_%1File", _prefix];

    private _source = missionNamespace getVariable [_lockedSourceVar, -1];
    if (_source < 0) then {
        _source = [_sourceParamName, 0] call BIS_fnc_getParamValue;
    };

    private _selectedChoice = missionNamespace getVariable [_lockedChoiceVar, -9999];
    if (_selectedChoice == -9999) then {
        _selectedChoice = if (_source == 0) then {
            [_defaultParamName, 0] call BIS_fnc_getParamValue
        } else {
            [_customParamName, 1] call BIS_fnc_getParamValue
        };
    };

    private _resolvedChoice = _selectedChoice;
    private _resolvedLabel = "";
    private _resolvedFile = "";

    if (_source == 0) then {
        private _index = _selectedChoice;
        if (_index < 0 || {_index >= count _defaultFiles}) then {
            _index = 0;
        };

        _resolvedChoice = _index;
        _resolvedLabel = _defaultLabels param [_index, _defaultLabels select 0];
        _resolvedFile = format ["preset\%1\%2", _folder, _defaultFiles param [_index, _defaultFallbackFile]];

        if !(fileExists _resolvedFile) then {
            diag_log format ["[MWF] Missing default preset for %1: %2. Fallback to %3.", _displayName, _resolvedFile, _defaultFallbackFile];
            _resolvedChoice = 0;
            _resolvedLabel = _defaultLabels select 0;
            _resolvedFile = format ["preset\%1\%2", _folder, _defaultFallbackFile];
        };
    } else {
        private _customSlot = _selectedChoice;
        if (_customSlot < 1 || {_customSlot > 10}) then {
            _customSlot = 1;
        };

        _resolvedChoice = _customSlot;
        _resolvedLabel = format ["Custom %1", _customSlot];
        _resolvedFile = format ["preset\%1\custom\custom_%2.sqf", _folder, _customSlot];

        if !(fileExists _resolvedFile) then {
            diag_log format ["[MWF] Missing custom preset for %1: %2. Fallback to custom_1.sqf.", _displayName, _resolvedFile];
            _resolvedChoice = 1;
            _resolvedLabel = "Custom 1";
            _resolvedFile = format ["preset\%1\custom\custom_1.sqf", _folder];
        };
    };

    missionNamespace setVariable [_lockedSourceVar, _source, true];
    missionNamespace setVariable [_lockedChoiceVar, _selectedChoice, true];
    missionNamespace setVariable [_lockedResolvedChoiceVar, _resolvedChoice, true];
    missionNamespace setVariable [_lockedLabelVar, _resolvedLabel, true];
    missionNamespace setVariable [_lockedFileVar, _resolvedFile, true];

    if (fileExists _resolvedFile) then {
        call compile preprocessFileLineNumbers _resolvedFile;
        diag_log format ["[MWF] Loaded %1 preset: %2", _displayName, _resolvedFile];
    } else {
        diag_log format ["[MWF] Failed to resolve preset for %1. File still missing after fallback: %2", _displayName, _resolvedFile];
    };

    [_prefix] call _persistKeys;

    createHashMapFromArray [
        ["source", _source],
        ["selectedChoice", _selectedChoice],
        ["resolvedChoice", _resolvedChoice],
        ["label", _resolvedLabel],
        ["file", _resolvedFile]
    ]
};

private _bluforFiles = [
    "NATO.sqf",
    "NATO_Pacific.sqf",
    "NATO_Woodland.sqf",
    "CUP_ACR_Desert.sqf",
    "CUP_ACR_Woodland.sqf",
    "CUP_BAF_Desert.sqf",
    "CUP_BAF_Woodland.sqf",
    "CUP_USA_Desert.sqf",
    "CUP_USA_Woodland.sqf",
    "CUP_USMC_Desert.sqf",
    "GM_West_Germany.sqf",
    "LDF_Contact.sqf",
    "RHS_USAF_Desert.sqf",
    "RHS_USAF_Woodland.sqf",
    "SOG_MACV.sqf",
    "ws_blufor_desert.sqf"
];

private _bluforLabels = [
    "NATO",
    "NATO Pacific",
    "NATO Woodland",
    "CUP ACR Desert",
    "CUP ACR Woodland",
    "CUP BAF Desert",
    "CUP BAF Woodland",
    "CUP USA Desert",
    "CUP USA Woodland",
    "CUP USMC Desert",
    "GM West Germany",
    "LDF Contact",
    "RHS USAF Desert",
    "RHS USAF Woodland",
    "SOG MACV",
    "Western Sahara BLUFOR Desert"
];

private _opforFiles = [
    "CSAT.sqf",
    "CSAT_Pacific.sqf",
    "CUP_AFRF_EMR.sqf",
    "CUP_AFRF_Modern.sqf",
    "CUP_CDF.sqf",
    "CUP_ChDKZ.sqf",
    "Contact.sqf",
    "GM_East_Germany.sqf",
    "Islamic_State.sqf",
    "RHS_AFRF.sqf",
    "Takistan_Army.sqf",
    "Unsung_Vietnam.sqf"
];

private _opforLabels = [
    "CSAT",
    "CSAT Pacific",
    "CUP AFRF EMR",
    "CUP AFRF Modern",
    "CUP CDF",
    "CUP ChDKZ",
    "Contact",
    "GM East Germany",
    "Islamic State",
    "RHS AFRF",
    "Takistan Army",
    "Unsung Vietnam"
];

private _resistanceFiles = [
    "AAF.sqf",
    "CUP_NAPA.sqf",
    "LDF_Resistance.sqf",
    "Middle_Eastern.sqf",
    "RACS.sqf",
    "RHS_GREF.sqf",
    "Syndikat.sqf",
    "Vietnam_CIDG.sqf"
];

private _resistanceLabels = [
    "AAF",
    "CUP NAPA",
    "LDF Resistance",
    "Middle Eastern",
    "RACS",
    "RHS GREF",
    "Syndikat",
    "Vietnam CIDG"
];

private _civilianFiles = [
    "Arma3_Civ.sqf",
    "CUP_ChernoCivs.sqf",
    "CUP_TakiCivs.sqf",
    "Contact_Civ.sqf",
    "Eastern_European.sqf",
    "Global_Mobilization.sqf",
    "Middle_Eastern.sqf",
    "RDSCiv.sqf",
    "Tanoa_Civ.sqf",
    "Vietnam_Unsung.sqf"
];

private _civilianLabels = [
    "Arma 3 Civilians",
    "CUP Chernarus Civilians",
    "CUP Takistan Civilians",
    "Contact Civilians",
    "Eastern European",
    "Global Mobilization",
    "Middle Eastern",
    "RDS Civilians",
    "Tanoa Civilians",
    "Vietnam Unsung"
];

_factionMap set ["BLUFOR", [
    "Blufor",
    "BLUFOR",
    "blufor",
    "MWF_Param_BluforSource",
    "MWF_Param_Blufor",
    "MWF_Param_CustomBlufor",
    _bluforFiles,
    _bluforLabels,
    "NATO.sqf"
] call _resolveSide];

_factionMap set ["OPFOR", [
    "Opfor",
    "OPFOR",
    "opfor",
    "MWF_Param_OpforSource",
    "MWF_Param_Opfor",
    "MWF_Param_CustomOpfor",
    _opforFiles,
    _opforLabels,
    "CSAT.sqf"
] call _resolveSide];

_factionMap set ["RESISTANCE", [
    "Resistance",
    "RESISTANCE",
    "resistance",
    "MWF_Param_ResistanceSource",
    "MWF_Param_Resistance",
    "MWF_Param_CustomResistance",
    _resistanceFiles,
    _resistanceLabels,
    "AAF.sqf"
] call _resolveSide];

_factionMap set ["CIVILIANS", [
    "Civs",
    "CIVILIANS",
    "civilians",
    "MWF_Param_CivsSource",
    "MWF_Param_Civs",
    "MWF_Param_CustomCivs",
    _civilianFiles,
    _civilianLabels,
    "Arma3_Civ.sqf"
] call _resolveSide];

missionNamespace setVariable ["MWF_FactionPresets", _factionMap, true];
saveProfileNamespace;

diag_log "[MWF] Preset manager initialized.";


// Vehicle/support preset data must be JIP-safe after the active BLUFOR preset has loaded,
// otherwise terminal vehicle menus on clients can see empty catalogs even though the server
// resolved the preset correctly.
{
    private _value = missionNamespace getVariable [_x, nil];
    if (isNil "_value") then {
        _value = [];
    } else {
        if (_value isEqualType []) then {
            _value = +_value;
        } else {
            if (_value isEqualType createHashMap) then {
                _value = +_value;
            };
        };
    };
    missionNamespace setVariable [_x, _value, true];
} forEach [
    "MWF_Preset_Light",
    "MWF_Preset_APC",
    "MWF_Preset_Tanks",
    "MWF_Preset_Helis",
    "MWF_Preset_Jets",
    "MWF_Preset_Light_T5",
    "MWF_Preset_Armor_T5",
    "MWF_Preset_Helis_T5",
    "MWF_Preset_Jets_T5",
    "MWF_Heli_Tower_Class",
    "MWF_Jet_Control_Class",
    "MWF_Respawn_Truck",
    "MWF_Respawn_Heli",
    "MWF_Support_Group1",
    "MWF_Support_Group2",
    "MWF_Support_Group3",
    "MWF_Support_Group4",
    "MWF_Support_Group5",
    "MWF_Support_GroupMeta"
];
