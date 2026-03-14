/*
    Author: Theane / ChatGPT
    Template: MissionIntel_1
    Category: intel
    Difficulty: hard

    Description:
    Baseline community-expandable mission template scaffold.
    Manual mission assets, classnames, and editor placements are intentionally left for later authoring.
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

[_slotData, _caller, "intel", "hard", 1] call MWF_fnc_executeMissionTemplate;
