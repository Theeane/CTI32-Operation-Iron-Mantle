/*
    Author: Theane / ChatGPT
    Function: fn_getThreatSnapshot
    Project: Military War Framework

    Description:
    Returns a stable snapshot of the current threat layer for future systems.
    Complex structures are rebuilt locally to avoid unsafe network serialization.
*/

private _zoneThreatSummary = + (missionNamespace getVariable ["MWF_ZoneThreatSummary", []]);
private _zoneThreatIndex = createHashMap;

{
    private _zoneId = toLower (_x param [0, "", [""]]);
    if (_zoneId != "") then {
        _zoneThreatIndex set [_zoneId, createHashMapFromArray [
            ["zoneId", _zoneId],
            ["threatLevel", _x param [1, 0, [0]]],
            ["threatState", _x param [2, "low", [""]]],
            ["responseProfile", _x param [3, "monitor", [""]]]
        ]];
    };
} forEach _zoneThreatSummary;

createHashMapFromArray [
    ["globalThreatLevel", missionNamespace getVariable ["MWF_GlobalThreatLevel", 0]],
    ["globalThreatState", missionNamespace getVariable ["MWF_GlobalThreatState", "low"]],
    ["threatPressureScore", missionNamespace getVariable ["MWF_ThreatPressureScore", 0]],
    ["highThreatZoneIds", + (missionNamespace getVariable ["MWF_HighThreatZoneIDs", []])],
    ["criticalThreatZoneIds", + (missionNamespace getVariable ["MWF_CriticalThreatZoneIDs", []])],
    ["zoneThreatSummary", _zoneThreatSummary],
    ["zoneThreatIndex", _zoneThreatIndex],
    ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]],
    ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]],
    ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]],
    ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]],
    ["worldSnapshot", missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap]]
]
