/*
    Author: Theane / ChatGPT
    Template: MissionSupply_3
    Category: supply
    Difficulty: medium

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "supply", "medium", 3] call MWF_fnc_executeMissionTemplate;
