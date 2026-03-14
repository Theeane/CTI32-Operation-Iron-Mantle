/*
    Author: Theane / ChatGPT
    Function: fn_recalculateThreatState
    Project: Military War Framework

    Description:
    Builds a dedicated threat layer from stable world progression outputs.
    Keeps enemy pressure separate from temporary zone capture logic.

    Notes:
    - Uses a lightweight mutex to avoid overlapping recalculations.
    - Avoids broadcasting complex structures on objects or mission namespace.
    - Only updates public object variables when values actually changed.
*/

if (!isServer) exitWith {createHashMap};
if (missionNamespace getVariable ["MWF_ThreatRecalcRunning", false]) exitWith {
    missionNamespace getVariable ["MWF_ThreatSnapshot", createHashMap]
};

missionNamespace setVariable ["MWF_ThreatRecalcRunning", true, false];

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _validZones = _zones select { !isNull _x };
private _worldSnapshot = missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap];

private _worldTier = _worldSnapshot getOrDefault ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]];
private _mapControl = _worldSnapshot getOrDefault ["mapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]];
private _contestedZones = _worldSnapshot getOrDefault ["contestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0]];
private _underAttackZones = _worldSnapshot getOrDefault ["underAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0]];
private _capturedCapitals = _worldSnapshot getOrDefault ["capturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]];
private _capturedFactories = _worldSnapshot getOrDefault ["capturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
private _capturedMilitary = _worldSnapshot getOrDefault ["capturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]];

private _globalThreat = [
    _worldTier,
    _mapControl,
    _contestedZones,
    _underAttackZones,
    _capturedCapitals,
    _capturedFactories,
    _capturedMilitary
] call MWF_fnc_determineGlobalThreat;

private _globalThreatLevel = _globalThreat param [0, 0];
private _globalThreatState = _globalThreat param [1, "low"];
private _pressureScore = _globalThreat param [2, 0];

private _zoneThreatIndex = createHashMap;
private _zoneThreatSummary = [];
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

    if (_zoneId != "") then {
        _zoneThreatIndex set [_zoneId, _zoneThreat];
        _zoneThreatSummary pushBack [_zoneId, _zoneThreatLevel, _zoneThreatState, _responseProfile];
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

private _previousThreatLevel = missionNamespace getVariable ["MWF_GlobalThreatLevel", -1];
private _previousThreatState = missionNamespace getVariable ["MWF_GlobalThreatState", ""];
private _previousPressure = missionNamespace getVariable ["MWF_ThreatPressureScore", -1];
private _previousHighThreat = missionNamespace getVariable ["MWF_HighThreatZoneIDs", []];
private _stateChanged = (
    _previousThreatLevel != _globalThreatLevel ||
    _previousThreatState != _globalThreatState ||
    {abs (_previousPressure - _pressureScore) >= 0.01} ||
    {!(_previousHighThreat isEqualTo _highThreatZoneIds)}
);

missionNamespace setVariable ["MWF_GlobalThreatLevel", _globalThreatLevel, true];
missionNamespace setVariable ["MWF_GlobalThreatState", _globalThreatState, true];
missionNamespace setVariable ["MWF_ThreatPressureScore", _pressureScore, true];
missionNamespace setVariable ["MWF_HighThreatZoneIDs", _highThreatZoneIds, true];
missionNamespace setVariable ["MWF_CriticalThreatZoneIDs", _criticalThreatZoneIds, true];
missionNamespace setVariable ["MWF_ZoneThreatSummary", _zoneThreatSummary, true];

missionNamespace setVariable ["MWF_ZoneThreatIndex", _zoneThreatIndex, false];
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
        "[MWF Threat] Recalculated | Level: %1 | State: %2 | Pressure: %3 | High Threat Zones: %4",
        _globalThreatLevel,
        _globalThreatState,
        round _pressureScore,
        count _highThreatZoneIds
    ];
};

missionNamespace setVariable ["MWF_ThreatRecalcRunning", false, false];
_snapshot
