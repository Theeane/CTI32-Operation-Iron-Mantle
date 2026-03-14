
/*
    File: fn_presetManager.sqf
    Author: CTI32 Operation Iron Mantle

    Purpose:
    Resolves faction presets based on lobby params, supports default/custom presets,
    applies fallback logic, and prepares data for save locking via CBA.

    This function DOES NOT directly spawn units. It only resolves which preset files
    should be used for each faction.

    Fallback rule:
    If a selected custom preset file does not exist, custom_1.sqf is used.
*/

private _presetData = createHashMap;

private _resolvePreset = {
    params ["_sideName","_sourceParam","_defaultParam","_customParam","_defaultPath","_customPath"];

    private _source = missionNamespace getVariable [_sourceParam,0];

    private _presetFile = "";
    private _presetKey = "";

    if (_source == 0) then {
        // Default preset
        _presetKey = missionNamespace getVariable [_defaultParam,0];
        _presetFile = format ["%1%2.sqf",_defaultPath,_presetKey];
    } else {
        // Custom preset
        private _customIndex = missionNamespace getVariable [_customParam,1];
        _presetFile = format ["%1custom_%2.sqf",_customPath,_customIndex];

        if !(fileExists _presetFile) then {
            diag_log format ["[MWF] %1 custom preset %2 missing. Fallback to custom_1.",_sideName,_customIndex];
            _presetFile = format ["%1custom_1.sqf",_customPath];
        };

        _presetKey = format ["custom_%1",_customIndex];
    };

    [_presetKey,_presetFile]
};

// BLUFOR
private _blufor = [
    "BLUFOR",
    "MWF_Param_BluforSource",
    "MWF_Param_Blufor",
    "MWF_Param_CustomBlufor",
    "Missionframework\preset\blufor\",
    "Missionframework\preset\blufor\custom\"
] call _resolvePreset;

// OPFOR
private _opfor = [
    "OPFOR",
    "MWF_Param_OpforSource",
    "MWF_Param_Opfor",
    "MWF_Param_CustomOpfor",
    "Missionframework\preset\opfor\",
    "Missionframework\preset\opfor\custom\"
] call _resolvePreset;

// RESISTANCE
private _res = [
    "RESISTANCE",
    "MWF_Param_ResistanceSource",
    "MWF_Param_Resistance",
    "MWF_Param_CustomResistance",
    "Missionframework\preset\resistance\",
    "Missionframework\preset\resistance\custom\"
] call _resolvePreset;

// CIVILIANS
private _civ = [
    "CIVILIANS",
    "MWF_Param_CivsSource",
    "MWF_Param_Civs",
    "MWF_Param_CustomCivs",
    "Missionframework\preset\civilians\",
    "Missionframework\preset\civilians\custom\"
] call _resolvePreset;

// Store results
_presetData set ["BLUFOR",_blufor];
_presetData set ["OPFOR",_opfor];
_presetData set ["RESISTANCE",_res];
_presetData set ["CIVILIANS",_civ];

missionNamespace setVariable ["MWF_FactionPresets",_presetData,true];

diag_log "[MWF] Preset manager initialized.";
