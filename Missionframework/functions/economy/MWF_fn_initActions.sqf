/*
    Author: Theane / ChatGPT
    Function: fn_initActions
    Project: Military War Framework

    Description:
    Handles init actions for the economy system.
*/

params ["_unit"];

// 1. Logic for Civilians
if (side _unit == civilian) exitWith {
    _unit addAction [
        "<t color='#FFCC00'>Talk to Civilian</t>",
        {
            params ["_target", "_caller"];
            [_target, _caller] spawn MWF_fnc_civilianIntel;
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
            params ["_target", "_caller"];
            [_target, _caller] spawn MWF_fnc_searchBody;
        },
        nil,
        1.5,
        true,
        true,
        "",
        "!alive _target && _target distance _this < 2.5 && !(_target getVariable ['MWF_isSearched', false])",
        5
    ];
};
