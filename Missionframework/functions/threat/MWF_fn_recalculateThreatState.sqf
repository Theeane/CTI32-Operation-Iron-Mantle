/*
    Author: Theane / ChatGPT
    Function: fn_recalculateThreatState
    Project: Military War Framework

    Description:
    Rebuilds the strategic threat layer from stable world and infrastructure data.

    Notes:
    - Keeps writes to zones minimal and value-based to reduce network noise.
    - Publishes simple arrays for network-safe consumers.
    - Stores richer hashMaps server-local for future planners and mission systems.
*/

if (!isServer) exitWith {createHashMap};
if (missionNamespace getVariable ["MWF_ThreatRecalcRunning", false]) exitWith {
    missionNamespace getVariable ["MWF_ThreatSnapshot", createHashMap]
};

missionNamespace setVariable ["MWF_ThreatRecalcRunning", true, false];

private _worldSnapshot = missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap];
if ((count _worldSnapshot) == 0 && !isNil "MWF_fnc_getWorldSnapshot") then {
    _worldSnapshot = [] call MWF_fnc_getWorldSnapshot;
    missionNamespace setVariable ["MWF_WorldSnapshot", _worldSnapshot, false];
};

private _worldTier = _worldSnapshot getOrDefault ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]];
private _mapControl = _worldSnapshot getOrDefault ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]];
private _contestedZones = _worldSnapshot getOrDefault ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]];
private _underAttackZones = _worldSnapshot getOrDefault ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]];
private _capturedCapitals = _worldSnapshot getOrDefault ["capturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]];
private _capturedFactories = _worldSnapshot getOrDefault ["capturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
private _capturedMilitary = _worldSnapshot getOrDefault ["capturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]];

private _destroyedHQs = count (missionNamespace getVariable ["MWF_DestroyedHQs", []]);
private _destroyedRoadblocks = count (missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]);
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _incidentLog = + (missionNamespace getVariable ["MWF_ThreatIncidentLog", []]);
private _threatPercent = (missionNamespace getVariable ["MWF_GlobalThreatPercent", 0]) max 0 min 100;
private _hotZones = + (missionNamespace getVariable ["MWF_ThreatHotZones", []]);
_hotZones = _hotZones select { (_x param [1, 0, [0]]) > serverTime };
missionNamespace setVariable ["MWF_ThreatHotZones", _hotZones, true];

private _incidentPressure = 0;
{
    _incidentPressure = _incidentPressure + (_x param [3, 0, [0]]);
} forEach _incidentLog;

private _globalThreatData = [
    _worldTier,
    _mapControl,
    _contestedZones,
    _underAttackZones,
    _capturedCapitals,
    _capturedFactories,
    _capturedMilitary,
    _destroyedHQs,
    _destroyedRoadblocks,
    _notoriety,
    _incidentPressure
] call MWF_fnc_determineGlobalThreat;

private _globalThreatLevel = _globalThreatData param [0, 0, [0]];
private _globalThreatState = _globalThreatData param [1, "low", [""]];
private _pressureScore = _globalThreatData param [2, 0, [0]];

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _validZones = _zones select { !isNull _x };

private _zoneThreatSummary = [];
private _zoneThreatSummariesDetailed = [];
private _zoneThreatIndex = createHashMap;
private _highThreatZoneIds = [];
private _criticalThreatZoneIds = [];

{
    private _zone = _x;
    private _zoneThreat = [
        _zone,
        _globalThreatLevel,
        _globalThreatState,
        _pressureScore
    ] call MWF_fnc_determineZoneThreat;

    private _zoneId = _zoneThreat getOrDefault ["zoneId", ""];
    private _zoneThreatLevel = _zoneThreat getOrDefault ["threatLevel", 0];
    private _zoneThreatState = _zoneThreat getOrDefault ["threatState", "low"];
    private _responseProfile = _zoneThreat getOrDefault ["responseProfile", "monitor"];
    private _priorityScore = _zoneThreat getOrDefault ["priorityScore", 0];

    if (_zoneId != "") then {
        _zoneThreatIndex set [_zoneId, _zoneThreat];
        _zoneThreatSummary pushBack [_zoneId, _zoneThreatLevel, _zoneThreatState, _responseProfile, _priorityScore];
        _zoneThreatSummariesDetailed pushBack _zoneThreat;
    };

    if ((_zone getVariable ["MWF_zoneThreatLevel", -1]) != _zoneThreatLevel) then {
        _zone setVariable ["MWF_zoneThreatLevel", _zoneThreatLevel, true];
    };

    if ((_zone getVariable ["MWF_zoneThreatState", ""]) != _zoneThreatState) then {
        _zone setVariable ["MWF_zoneThreatState", _zoneThreatState, true];
    };

    if ((_zone getVariable ["MWF_zoneResponseProfile", ""]) != _responseProfile) then {
        _zone setVariable ["MWF_zoneResponseProfile", _responseProfile, true];
    };

    if (_zoneThreatLevel >= 3 && _zoneId != "") then {
        _highThreatZoneIds pushBackUnique _zoneId;
    };

    if (_zoneThreatLevel >= 4 && _zoneId != "") then {
        _criticalThreatZoneIds pushBackUnique _zoneId;
    };
} forEach _validZones;

private _priorityTargets = [
    _zoneThreatSummariesDetailed,
    (2 + _globalThreatLevel) min 6
] call MWF_fnc_selectThreatTargets;

private _priorityTargetArray = [];
private _priorityZoneIds = [];
{
    private _zoneId = _x getOrDefault ["zoneId", ""];
    if (_zoneId != "") then {
        _priorityZoneIds pushBackUnique _zoneId;
        _priorityTargetArray pushBack [
            _zoneId,
            _x getOrDefault ["zoneType", "town"],
            _x getOrDefault ["threatLevel", 0],
            _x getOrDefault ["threatState", "low"],
            _x getOrDefault ["responseProfile", "monitor"],
            _x getOrDefault ["priorityScore", 0]
        ];
    };
} forEach _priorityTargets;

private _baseThreat = [
    _globalThreatLevel,
    _pressureScore,
    missionNamespace getVariable ["MWF_FOB_Positions", []],
    _incidentLog
] call MWF_fnc_evaluateBaseThreat;

private _directives = [
    _globalThreatLevel,
    _globalThreatState,
    _pressureScore,
    _worldSnapshot,
    _baseThreat,
    _destroyedHQs,
    _destroyedRoadblocks,
    count _priorityTargets
] call MWF_fnc_buildThreatDirectives;

private _responseQueue = [
    _globalThreatLevel,
    _globalThreatState,
    _priorityTargets,
    _directives,
    _baseThreat
] call MWF_fnc_buildThreatResponses;

private _responseQueueArray = [];
{
    _responseQueueArray pushBack [
        _x getOrDefault ["priority", 0],
        _x getOrDefault ["type", ""],
        _x getOrDefault ["zoneId", ""],
        _x getOrDefault ["profile", ""],
        _x getOrDefault ["score", 0]
    ];
} forEach _responseQueue;

private _pressureMultiplier = missionNamespace getVariable ["MWF_AIPressureMultiplier", 1];
private _patrolDensityMultiplier = missionNamespace getVariable ["MWF_AIPatrolDensityMultiplier", _pressureMultiplier];
private _qrfIntervalMultiplier = missionNamespace getVariable ["MWF_AIQRFIntervalMultiplier", 1];

private _scaledPatrolDensity = ((_directives getOrDefault ["patrolDensity", 0.2]) * _patrolDensityMultiplier) min 0.95;
private _scaledQrfInterval = round ((((_directives getOrDefault ["qrfInterval", 900]) * _qrfIntervalMultiplier) max 180) min 1800);
private _scaledRoadblockPressure = round (((_directives getOrDefault ["roadblockPressure", 0]) * _pressureMultiplier) min 100);
private _scaledHQPressure = round (((_directives getOrDefault ["hqPressure", 0]) * _pressureMultiplier) min 100);

private _directiveArray = [
    ["globalThreatLevel", _globalThreatLevel],
    ["globalThreatPercent", _threatPercent],
    ["globalThreatState", _globalThreatState],
    ["patrolDensity", _scaledPatrolDensity],
    ["qrfInterval", _scaledQrfInterval],
    ["roadblockPressure", _scaledRoadblockPressure],
    ["hqPressure", _scaledHQPressure],
    ["basePressure", _directives getOrDefault ["basePressure", 0]],
    ["baseAttackState", _directives getOrDefault ["baseAttackState", "idle"]],
    ["missionEscalation", _directives getOrDefault ["missionEscalation", "low"]],
    ["enabledResponses", _directives getOrDefault ["enabledResponses", []]],
    ["playerScaling", missionNamespace getVariable ["MWF_PlayerScalingLabel", "9-16 Players (Medium Group)"]],
    ["dynamicUnitCap", missionNamespace getVariable ["MWF_DynamicUnitCap", 100]]
];

private _previousThreatLevel = missionNamespace getVariable ["MWF_GlobalThreatLevel", -1];
private _previousThreatState = missionNamespace getVariable ["MWF_GlobalThreatState", ""];
private _previousPressure = missionNamespace getVariable ["MWF_ThreatPressureScore", -1];
private _previousHighThreat = missionNamespace getVariable ["MWF_HighThreatZoneIDs", []];
private _previousPriorityZones = missionNamespace getVariable ["MWF_ThreatPriorityZoneIDs", []];
private _stateChanged = (
    _previousThreatLevel != _globalThreatLevel ||
    _previousThreatState != _globalThreatState ||
    {abs (_previousPressure - _pressureScore) >= 0.01} ||
    {!(_previousHighThreat isEqualTo _highThreatZoneIds)} ||
    {!(_previousPriorityZones isEqualTo _priorityZoneIds)}
);

missionNamespace setVariable ["MWF_GlobalThreatLevel", _globalThreatLevel, true];
missionNamespace setVariable ["MWF_GlobalThreatPercent", _threatPercent, true];
missionNamespace setVariable ["MWF_GlobalThreatState", _globalThreatState, true];
missionNamespace setVariable ["MWF_ThreatPressureScore", _pressureScore, true];
missionNamespace setVariable ["MWF_HighThreatZoneIDs", _highThreatZoneIds, true];
missionNamespace setVariable ["MWF_CriticalThreatZoneIDs", _criticalThreatZoneIds, true];
missionNamespace setVariable ["MWF_ThreatPriorityZoneIDs", _priorityZoneIds, true];
missionNamespace setVariable ["MWF_ZoneThreatSummary", _zoneThreatSummary, true];
missionNamespace setVariable ["MWF_ThreatDirectiveArray", _directiveArray, true];
missionNamespace setVariable ["MWF_ThreatResponseQueueArray", _responseQueueArray, true];
missionNamespace setVariable ["MWF_ThreatBasePressure", _baseThreat getOrDefault ["basePressure", 0], true];
missionNamespace setVariable ["MWF_ThreatBaseAttackState", _baseThreat getOrDefault ["baseAttackState", "idle"], true];
missionNamespace setVariable ["MWF_ThreatRoadblockPressure", _scaledRoadblockPressure, true];
missionNamespace setVariable ["MWF_ThreatHQPressure", _scaledHQPressure, true];
missionNamespace setVariable ["MWF_ThreatPatrolDensity", _scaledPatrolDensity, true];
missionNamespace setVariable ["MWF_ThreatQRFInterval", _scaledQrfInterval, true];
missionNamespace setVariable ["MWF_ThreatMissionEscalation", _directives getOrDefault ["missionEscalation", "low"], true];

missionNamespace setVariable ["MWF_ZoneThreatIndex", _zoneThreatIndex, false];
missionNamespace setVariable ["MWF_ThreatDirectives", _directives, false];
missionNamespace setVariable ["MWF_ThreatPriorityTargets", _priorityTargetArray, false];
missionNamespace setVariable ["MWF_ThreatResponseQueue", _responseQueue, false];
missionNamespace setVariable ["MWF_ThreatLastRecalcAt", diag_tickTime, false];
missionNamespace setVariable ["MWF_ThreatStateDirty", false, false];

if (_stateChanged) then {
    private _version = (missionNamespace getVariable ["MWF_ThreatStateVersion", 0]) + 1;
    missionNamespace setVariable ["MWF_ThreatStateVersion", _version, true];
};

private _snapshot = [] call MWF_fnc_getThreatSnapshot;
missionNamespace setVariable ["MWF_ThreatSnapshot", _snapshot, false];

if (_stateChanged) then {
    diag_log format [
        "[MWF Threat] Recalculated | Level: %1 | State: %2 | Pressure: %3 | Priority Targets: %4 | Queue Entries: %5",
        _globalThreatLevel,
        _globalThreatState,
        round _pressureScore,
        count _priorityZoneIds,
        count _responseQueueArray
    ];
};

missionNamespace setVariable ["MWF_ThreatRecalcRunning", false, false];
_snapshot
