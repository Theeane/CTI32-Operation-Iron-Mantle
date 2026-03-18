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
            ["responseProfile", _x param [3, "monitor", [""]]],
            ["priorityScore", _x param [4, 0, [0]]]
        ]];
    };
} forEach _zoneThreatSummary;

private _directiveArray = + (missionNamespace getVariable ["MWF_ThreatDirectiveArray", []]);
private _directives = createHashMapFromArray _directiveArray;

private _priorityTargetsArray = + (missionNamespace getVariable ["MWF_ThreatPriorityTargets", []]);
private _priorityTargets = [];
{
    _priorityTargets pushBack (createHashMapFromArray [
        ["zoneId", toLower (_x param [0, "", [""]])],
        ["zoneType", _x param [1, "town", [""]]],
        ["threatLevel", _x param [2, 0, [0]]],
        ["threatState", _x param [3, "low", [""]]],
        ["responseProfile", _x param [4, "monitor", [""]]],
        ["priorityScore", _x param [5, 0, [0]]]
    ]);
} forEach _priorityTargetsArray;

private _responseQueueArray = + (missionNamespace getVariable ["MWF_ThreatResponseQueueArray", []]);
private _responseQueue = [];
{
    _responseQueue pushBack (createHashMapFromArray [
        ["priority", _x param [0, 0, [0]]],
        ["type", _x param [1, "", [""]]],
        ["zoneId", toLower (_x param [2, "", [""]])],
        ["profile", _x param [3, "", [""]]],
        ["score", _x param [4, 0, [0]]]
    ]);
} forEach _responseQueueArray;

createHashMapFromArray [
    ["globalThreatLevel", missionNamespace getVariable ["MWF_GlobalThreatLevel", 0]],
    ["globalThreatPercent", missionNamespace getVariable ["MWF_GlobalThreatPercent", 0]],
    ["globalThreatState", missionNamespace getVariable ["MWF_GlobalThreatState", "low"]],
    ["threatPressureScore", missionNamespace getVariable ["MWF_ThreatPressureScore", 0]],
    ["highThreatZoneIds", + (missionNamespace getVariable ["MWF_HighThreatZoneIDs", []])],
    ["criticalThreatZoneIds", + (missionNamespace getVariable ["MWF_CriticalThreatZoneIDs", []])],
    ["priorityZoneIds", + (missionNamespace getVariable ["MWF_ThreatPriorityZoneIDs", []])],
    ["zoneThreatSummary", _zoneThreatSummary],
    ["zoneThreatIndex", _zoneThreatIndex],
    ["directives", _directives],
    ["priorityTargets", _priorityTargets],
    ["responseQueue", _responseQueue],
    ["incidentLog", + (missionNamespace getVariable ["MWF_ThreatIncidentLog", []])],
    ["hotZones", + (missionNamespace getVariable ["MWF_ThreatHotZones", []])],
    ["mainOpThreatProgressBlockedUntil", missionNamespace getVariable ["MWF_MainOpThreatProgressBlockedUntil", 0]],
    ["basePressure", missionNamespace getVariable ["MWF_ThreatBasePressure", 0]],
    ["baseAttackState", missionNamespace getVariable ["MWF_ThreatBaseAttackState", "idle"]],
    ["roadblockPressure", missionNamespace getVariable ["MWF_ThreatRoadblockPressure", 0]],
    ["hqPressure", missionNamespace getVariable ["MWF_ThreatHQPressure", 0]],
    ["patrolDensity", missionNamespace getVariable ["MWF_ThreatPatrolDensity", 0.2]],
    ["qrfInterval", missionNamespace getVariable ["MWF_ThreatQRFInterval", 900]],
    ["missionEscalation", missionNamespace getVariable ["MWF_ThreatMissionEscalation", "low"]],
    ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]],
    ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]],
    ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]],
    ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]],
    ["worldSnapshot", missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap]]
]
