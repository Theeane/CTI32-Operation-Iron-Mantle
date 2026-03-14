/*
    Author: Theane / ChatGPT
    Function: fn_getThreatSnapshot
    Project: Military War Framework

    Description:
    Returns a stable snapshot of the current threat layer for future systems.
*/

private _snapshot = createHashMapFromArray [
    ["globalThreatLevel", missionNamespace getVariable ["MWF_GlobalThreatLevel", 0]],
    ["globalThreatState", missionNamespace getVariable ["MWF_GlobalThreatState", "low"]],
    ["threatPressureScore", missionNamespace getVariable ["MWF_ThreatPressureScore", 0]],
    ["highThreatZoneIds", + (missionNamespace getVariable ["MWF_HighThreatZoneIDs", []])],
    ["criticalThreatZoneIds", + (missionNamespace getVariable ["MWF_CriticalThreatZoneIDs", []])],
    ["zoneThreatIndex", + (missionNamespace getVariable ["MWF_ZoneThreatIndex", createHashMap])],
    ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]],
    ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]],
    ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]],
    ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]],
    ["worldSnapshot", + (missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap])]
];

_snapshot
