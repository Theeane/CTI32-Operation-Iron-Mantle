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
        ["JETS",  [...]]
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

{
    _x params ["_category", "_varName"];

    private _source = missionNamespace getVariable [_varName, []];
    private _entries = [];

    {
        if (_x isEqualType [] && {(count _x) >= 3}) then {
            private _className = _x param [0, "", [""]];
            private _cost = _x param [1, 0, [0]];
            private _minTier = _x param [2, 1, [0]];

            if !(_className isEqualTo "") then {
                private _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
                if (_displayName isEqualTo "") then { _displayName = _className; };

                _entries pushBack [_className, _cost, _minTier, _displayName];
            };
        };
    } forEach _source;

    _catalog pushBack [_category, _entries];
} forEach _definitions;

_catalog
