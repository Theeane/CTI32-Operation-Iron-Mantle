/*
    Author: Theane / ChatGPT
    Template: MissionIntel_2
    Category: intel
    Difficulty: easy

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "intel", "easy", 2] call MWF_fnc_executeMissionTemplate;
