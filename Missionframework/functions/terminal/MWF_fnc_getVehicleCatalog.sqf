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
    ["APC", "MWF_Preset_APC", "MWF_Preset_APC_T5", "ARMOR"],
    ["TANKS", "MWF_Preset_Tanks", "MWF_Preset_Armor_T5", "ARMOR"],
    ["HELIS", "MWF_Preset_Helis", "MWF_Preset_Helis_T5", "HELI"],
    ["JETS", "MWF_Preset_Jets", "MWF_Preset_Jets_T5", "JETS"]
];

private _catalog = [];
private _totalEntries = 0;
private _emptyCategories = [];
private _invalidEntries = 0;

private _appendEntries = {
    params ["_targetEntries", "_source", "_requiredUnlock", ["_forceTier5", false, [false]]];

    {
        if (_x isEqualType [] && {(count _x) >= 2}) then {
            private _className = _x param [0, "", [""]];
            private _cost = _x param [1, 0, [0]];
            private _minTier = _x param [2, 1, [0]];

            if (_className isEqualTo "") then {
                _invalidEntries = _invalidEntries + 1;
            } else {
                if (_forceTier5) then { _minTier = _minTier max 5; };
                private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
                if (_displayName isEqualTo "") then { _displayName = _className; };
                _targetEntries pushBack [_className, _cost, _minTier, _displayName, _requiredUnlock, _forceTier5];
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
    private _source = missionNamespace getVariable [_varName, []];
    _entries = [_entries, _source, _requiredUnlock, false] call _appendEntries;

    private _tier5Source = missionNamespace getVariable [_tier5VarName, []];
    if (_category isEqualTo "TANKS") then {
        private _altArmor = missionNamespace getVariable ["MWF_Preset_Tanks_T5", []];
        if (_tier5Source isEqualTo [] && {_altArmor isNotEqualTo []}) then { _tier5Source = _altArmor; };
    };
    _entries = [_entries, _tier5Source, _requiredUnlock, true] call _appendEntries;

    if (_entries isEqualTo []) then {
        _emptyCategories pushBack _category;
    };

    _totalEntries = _totalEntries + (count _entries);
    _catalog pushBack [_category, _entries];
} forEach _definitions;

_catalog pushBack ["__META__", [
    ["totalEntries", _totalEntries],
    ["emptyCategories", _emptyCategories],
    ["invalidEntries", _invalidEntries]
]];

_catalog
