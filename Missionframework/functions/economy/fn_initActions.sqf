/*
    Author: Theeane
    Function: CTI_fnc_initActions
    Description: 
    Adds interaction menus (Search/Talk) to units.
    This can be called on units when they spawn.
*/

params ["_unit"];

// 1. Logic for Civilians
if (side _unit == civilian) exitWith {
    _unit addAction [
        "<t color='#FFCC00'>Talk to Civilian</t>", 
        {
            params ["_target", "_caller", "_id", "_args"];
            [_target] spawn CTI_fnc_civilianIntel;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "alive _target && _target distance _this < 3",
        5
    ];
};

// 2. Logic for Soldiers (Searching bodies)
// We add this to all soldiers, but the action is only visible if they are dead.
if (side _unit != civilian) exitWith {
    _unit addAction [
        "<t color='#FF0000'>Search Body</t>", 
        {
            params ["_target", "_caller", "_id", "_args"];
            [_target] spawn CTI_fnc_searchBody;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "!alive _target && _target distance _this < 2.5 && !(_target getVariable ['GVAR_isSearched', false])",
        5
    ];
};
