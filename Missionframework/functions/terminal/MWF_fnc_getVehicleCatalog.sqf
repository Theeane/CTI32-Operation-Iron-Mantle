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
    private _source = missionNamespace getVariable [_varName, []];
    _entries = [_entries, _source, _requiredUnlock, false, _category] call _appendEntries;

    private _tier5Source = if (_tier5VarName isEqualTo "") then {
        []
    } else {
        missionNamespace getVariable [_tier5VarName, []]
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
    ["invalidEntries", _invalidEntries]
]];

_catalog
