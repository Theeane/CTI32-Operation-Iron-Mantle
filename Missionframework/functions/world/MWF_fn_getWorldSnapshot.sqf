/*
    Author: Theane / ChatGPT
    Function: fn_getWorldSnapshot
    Project: Military War Framework

    Description:
    Returns a stable snapshot of strategic world-state values for future systems.
    Complex structures are rebuilt locally to avoid unsafe network serialization.
*/

private _milestonesArray = + (missionNamespace getVariable ["MWF_ProgressionMilestonesArray", []]);
private _milestones = createHashMapFromArray _milestonesArray;

private _snapshot = createHashMapFromArray [
    ["zoneCountTotal", missionNamespace getVariable ["MWF_WorldZoneCountTotal", 0]],
    ["zoneCountCaptured", missionNamespace getVariable ["MWF_CapturedZoneCount", 0]],
    ["capturedZoneIds", + (missionNamespace getVariable ["MWF_CapturedZoneIDs", []])],
    ["capturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]],
    ["capturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]],
    ["capturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]],
    ["capturedTownCount", missionNamespace getVariable ["MWF_CapturedTownCount", 0]],
    ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]],
    ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]],
    ["progressionState", missionNamespace getVariable ["MWF_ProgressionState", "opening"]],
    ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]],
    ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]],
    ["milestones", _milestones]
];

_snapshot
