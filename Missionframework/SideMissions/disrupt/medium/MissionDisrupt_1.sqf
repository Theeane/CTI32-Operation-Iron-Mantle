/*
    Author: Theane / ChatGPT
    Template: MissionDisrupt_1
    Category: disrupt
    Difficulty: medium

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "disrupt", "medium", 1] call MWF_fnc_executeMissionTemplate;
