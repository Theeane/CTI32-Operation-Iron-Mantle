/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_getVehicleCatalog
    Project: Military War Framework

    Description:
    Reads all purchasable vehicle data from the active BLUFOR preset.
    The preset remains the single source of truth for classname, price, and min tier.

    Returns:
    [
        ["LIGHT", [[_className, _cost, _minTier, _displayName], ...]],
        ["APC",   [...]],
        ["TANKS", [...]],
        ["HELIS", [...]],
        ["JETS",  [...]],
        ["__META__", [
            ["totalEntries", _count],
            ["emptyCategories", [...]],
            ["invalidEntries", _count]
        ]]
    ]
*/

private _definitions = [
    ["LIGHT", "MWF_Preset_Light"],
    ["APC", "MWF_Preset_APC"],
    ["TANKS", "MWF_Preset_Tanks"],
    ["HELIS", "MWF_Preset_Helis"],
    ["JETS", "MWF_Preset_Jets"]
];

private _catalog = [];
private _totalEntries = 0;
private _emptyCategories = [];
private _invalidEntries = 0;

{
    _x params ["_category", "_varName"];

    private _source = missionNamespace getVariable [_varName, []];
    private _entries = [];

    {
        if (_x isEqualType [] && {(count _x) >= 3}) then {
            private _className = _x param [0, "", [""]];
            private _cost = _x param [1, 0, [0]];
            private _minTier = _x param [2, 1, [0]];

            if (_className isEqualTo "") then {
                _invalidEntries = _invalidEntries + 1;
            } else {
                private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
                if (_displayName isEqualTo "") then { _displayName = _className; };

                _entries pushBack [_className, _cost, _minTier, _displayName];
            };
        } else {
            _invalidEntries = _invalidEntries + 1;
        };
    } forEach _source;

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
