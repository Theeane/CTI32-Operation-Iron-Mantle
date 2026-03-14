/*
    Author: Theane / ChatGPT
    Template: MissionSupply_1
    Category: supply
    Difficulty: easy

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "supply", "easy", 1] call MWF_fnc_executeMissionTemplate;
