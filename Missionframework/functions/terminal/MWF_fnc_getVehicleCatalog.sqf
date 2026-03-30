/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_getVehicleCatalog
    Project: Military War Framework

    Description:
    Reads all purchasable vehicle data from the active BLUFOR preset.
    Preset order is preserved exactly. Tier 5 entries are appended to the bottom
    of their respective categories and omitted entirely when the Tier 5 list is empty.

    Entry format:
    [_className, _cost, _minTier, _displayName, _requiredUnlock, _isTier5]
*/

private _definitions = [
    ["LIGHT", "MWF_Preset_Light", "MWF_Preset_Light_T5", ""],
    ["APC", "MWF_Preset_APC", "MWF_Preset_Armor_T5", "ARMOR"],
    ["TANKS", "MWF_Preset_Tanks", "MWF_Preset_Tanks_T5", "TANKS"],
    ["HELIS", "MWF_Preset_Helis", "MWF_Preset_Helis_T5", "HELI"],
    ["JETS", "MWF_Preset_Jets", "MWF_Preset_Jets_T5", "JETS"]
];

private _corePresetVars = [
    "MWF_Preset_Light",
    "MWF_Preset_APC",
    "MWF_Preset_Tanks",
    "MWF_Preset_Helis",
    "MWF_Preset_Jets"
];

private _allPresetVars = [
    "MWF_Preset_Light",
    "MWF_Preset_APC",
    "MWF_Preset_Tanks",
    "MWF_Preset_Helis",
    "MWF_Preset_Jets",
    "MWF_Preset_Light_T5",
    "MWF_Preset_Armor_T5",
    "MWF_Preset_Tanks_T5",
    "MWF_Preset_Helis_T5",
    "MWF_Preset_Jets_T5",
    "MWF_Heli_Tower_Class",
    "MWF_Jet_Control_Class",
    "MWF_Respawn_Truck",
    "MWF_Respawn_Heli"
];

private _countValidPresetRows = {
    params ["_source"];

    private _count = 0;
    {
        if (_x isEqualType [] && {(count _x) >= 2}) then {
            private _className = _x param [0, "", [""]];
            if !(_className isEqualTo "") then {
                _count = _count + 1;
            };
        };
    } forEach _source;

    _count
};

private _readPresetVar = {
    params ["_varName"];

    private _value = missionNamespace getVariable [_varName, nil];
    if (!isNil "_value") exitWith { _value };

    if !(isNil _varName) exitWith { missionNamespace getVariable [_varName, call compile _varName] };

    nil
};

private _ensureClientPresetData = {
    if (isServer) exitWith { false };
    if (missionNamespace getVariable ["MWF_VehicleMenu_PresetBootstrapAttempted", false]) exitWith { false };

    private _hasAnyPresetData = false;
    {
        private _value = [_x] call _readPresetVar;
        if (_value isEqualType [] && {([_value] call _countValidPresetRows) > 0}) exitWith {
            _hasAnyPresetData = true;
        };
    } forEach _corePresetVars;

    if (_hasAnyPresetData) exitWith { false };

    missionNamespace setVariable ["MWF_VehicleMenu_PresetBootstrapAttempted", true];

    private _resolvedFile = missionNamespace getVariable ["MWF_Locked_BluforFile", ""];
    if (_resolvedFile isEqualTo "") then {
        private _registry = missionNamespace getVariable ["MWF_FactionPresets", createHashMap];
        if (_registry isEqualType createHashMap) then {
            private _entry = _registry getOrDefault ["BLUFOR", createHashMap];
            if (_entry isEqualType createHashMap) then {
                _resolvedFile = _entry getOrDefault ["file", ""];
            };
        };
    };

    if (_resolvedFile isEqualTo "") exitWith { false };
    if !(fileExists _resolvedFile) exitWith {
        diag_log format ["[MWF] Vehicle catalog bootstrap failed. Missing preset file on client: %1", _resolvedFile];
        false
    };

    call compile preprocessFileLineNumbers _resolvedFile;

    {
        if (isNil { missionNamespace getVariable _x }) then {
            missionNamespace setVariable [_x, []];
        };
    } forEach _allPresetVars;

    diag_log format ["[MWF] Vehicle catalog bootstrap loaded preset locally on client: %1", _resolvedFile];
    true
};

private _bootstrapTriggered = call _ensureClientPresetData;

private _catalog = [];
private _totalEntries = 0;
private _emptyCategories = [];
private _invalidEntries = 0;

private _classMatchesCategory = {
    params ["_className", "_category", ["_isTier5", false, [false]]];

    if (!_isTier5 || {_className isEqualTo ""}) exitWith { true };
    if !(_category in ["APC", "TANKS"]) exitWith { true };

    private _cfg = configFile >> "CfgVehicles" >> _className;
    if (!isClass _cfg) exitWith { true };

    private _transportSeats = getNumber (_cfg >> "transportSoldier");
    private _isAPC =
        (_className isKindOf "Wheeled_APC_F") ||
        (_className isKindOf "APC_Tracked_01_base_F") ||
        (_className isKindOf "APC_Tracked_02_base_F") ||
        (_className isKindOf "APC_Tracked_03_base_F") ||
        (_className isKindOf "AFV_Wheeled_01_base_F") ||
        (_className isKindOf "AFV_Wheeled_02_base_F") ||
        (_transportSeats > 0);

    if (_category isEqualTo "APC") exitWith { _isAPC };
    !_isAPC
};

private _appendEntries = {
    params ["_targetEntries", "_source", "_requiredUnlock", ["_forceTier5", false, [false]], ["_category", "", [""]]];

    {
        if (_x isEqualType [] && {(count _x) >= 2}) then {
            private _className = _x param [0, "", [""]];
            private _cost = _x param [1, 0, [0]];
            private _minTier = _x param [2, 1, [0]];

            if (_className isEqualTo "") then {
                // Allow empty placeholder rows in preset arrays without surfacing warnings.
            } else {
                if ([_className, _category, _forceTier5] call _classMatchesCategory) then {
                    if (_forceTier5) then { _minTier = _minTier max 5; };

                    private _alreadyExists = _targetEntries findIf {
                        ((_x param [0, ""]) isEqualTo _className) &&
                        ((_x param [1, -1]) isEqualTo _cost) &&
                        ((_x param [2, -1]) isEqualTo _minTier) &&
                        ((_x param [4, ""]) isEqualTo _requiredUnlock)
                    };

                    if (_alreadyExists < 0) then {
                        private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
                        if (_displayName isEqualTo "") then { _displayName = _className; };
                        _targetEntries pushBack [_className, _cost, _minTier, _displayName, _requiredUnlock, _forceTier5];
                    };
                };
            };
        } else {
            _invalidEntries = _invalidEntries + 1;
        };
    } forEach _source;

    _targetEntries
};

{
    _x params ["_category", "_varName", "_tier5VarName", "_requiredUnlock"];

    private _entries = [];
    private _source = [_varName] call _readPresetVar;
    if !(_source isEqualType []) then { _source = []; };
    _entries = [_entries, _source, _requiredUnlock, false, _category] call _appendEntries;

    private _tier5Source = if (_tier5VarName isEqualTo "") then {
        []
    } else {
        private _tierSource = [_tier5VarName] call _readPresetVar;
        if (_tierSource isEqualType []) then { _tierSource } else { [] };
    };
    _entries = [_entries, _tier5Source, _requiredUnlock, true, _category] call _appendEntries;

    if (_entries isEqualTo []) then {
        _emptyCategories pushBack _category;
    };

    _totalEntries = _totalEntries + (count _entries);
    _catalog pushBack [_category, _entries];
} forEach _definitions;

_catalog pushBack ["__META__", [
    ["totalEntries", _totalEntries],
    ["emptyCategories", _emptyCategories],
    ["invalidEntries", _invalidEntries],
    ["bootstrapTriggered", _bootstrapTriggered]
]];

_catalog
