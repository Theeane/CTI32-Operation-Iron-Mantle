/*
    Author: Theane / ChatGPT
    Function: fn_initActions
    Project: Military War Framework

    Description:
    Handles interaction actions for civilians and searchable bodies.
*/

params [["_unit", objNull, [objNull]]];
if (isNull _unit) exitWith {};

if (side _unit == civilian) exitWith {
    if (_unit getVariable ["MWF_CivTalkActionInit", false]) exitWith {};
    _unit setVariable ["MWF_CivTalkActionInit", true];

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
        "alive _target && _target distance _this < 3 && !(_target getVariable ['MWF_isQuestioned', false])",
        5
    ];
};

if (_unit getVariable ["MWF_SearchBodyActionInit", false]) exitWith {};
_unit setVariable ["MWF_SearchBodyActionInit", true];

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
