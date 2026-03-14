/*
    Author: Theane / ChatGPT
    Template: MissionIntel_3
    Category: intel
    Difficulty: medium

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "intel", "medium", 3] call MWF_fnc_executeMissionTemplate;
