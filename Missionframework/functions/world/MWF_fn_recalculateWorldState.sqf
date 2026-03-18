/*
    Author: Theane / ChatGPT
    Function: fn_recalculateWorldState
    Project: Military War Framework

    Description:
    Aggregates authoritative zone data into future-safe world progression values.
    Strategic tier progression is now score-driven and only uses map control for
    milestone locks such as the permanent Tier 3 floor at 50% map control.
*/

if (!isServer) exitWith {createHashMap};
if (missionNamespace getVariable ["MWF_WorldRecalcRunning", false]) exitWith {
    missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap]
};

missionNamespace setVariable ["MWF_WorldRecalcRunning", true, false];

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _validZones = _zones select { !isNull _x };

private _capturedZones = [];
private _capturedZoneIds = [];
private _capturedTowns = 0;
private _capturedCapitals = 0;
private _capturedFactories = 0;
private _capturedMilitary = 0;
private _contestedZones = 0;
private _underAttackZones = 0;

{
    private _zone = _x;
    private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
    private _zoneId = toLower (_zone getVariable ["MWF_zoneID", ""]);

    if (_zone getVariable ["MWF_contested", false]) then {
        _contestedZones = _contestedZones + 1;
    };

    if (_zone getVariable ["MWF_underAttack", false]) then {
        _underAttackZones = _underAttackZones + 1;
    };

    if (_zone getVariable ["MWF_isCaptured", false]) then {
        _capturedZones pushBack _zone;
        if (_zoneId != "") then {
            _capturedZoneIds pushBackUnique _zoneId;
        };

        switch (_zoneType) do {
            case "capital": { _capturedCapitals = _capturedCapitals + 1; };
            case "factory": { _capturedFactories = _capturedFactories + 1; };
            case "military": { _capturedMilitary = _capturedMilitary + 1; };
            default { _capturedTowns = _capturedTowns + 1; };
        };
    };
} forEach _validZones;

private _totalZones = count _validZones;
private _capturedCount = count _capturedZones;
private _mapControl = if (_totalZones > 0) then { ((_capturedCount / _totalZones) * 100) min 100 } else { 0 };

private _halfMapLock = _mapControl >= 50;
private _floorTier = if (_halfMapLock) then {3} else {1};
private _floorScore = if (_halfMapLock) then {200} else {0};
private _score = missionNamespace getVariable ["MWF_WorldTierScore", 0];
if (_score < _floorScore) then {
    _score = _floorScore;
    missionNamespace setVariable ["MWF_WorldTierScore", _score, true];
};

private _worldTier = ((_score / 100) call BIS_fnc_floor) + 1;
_worldTier = (_worldTier max _floorTier) min 5;
private _worldTierProgress = if (_worldTier >= 5) then {100} else {_score mod 100};

private _progressionState = [
    _mapControl,
    _capturedCount,
    _capturedCapitals,
    _contestedZones,
    _underAttackZones
] call MWF_fnc_determineProgressionState;

private _tierBlockedUntil = missionNamespace getVariable ["MWF_WorldTierProgressBlockedUntil", 0];
private _freezeActive = missionNamespace getVariable ["MWF_TierFreeze_Active", false];
if (_freezeActive && {serverTime >= (missionNamespace getVariable ["MWF_TierFreeze_EndTime", 0])}) then {
    missionNamespace setVariable ["MWF_TierFreeze_Active", false, true];
    missionNamespace setVariable ["MWF_TierFreeze_EndTime", 0, true];
    missionNamespace setVariable ["MWF_WorldTierProgressBlockedUntil", 0, true];
    _tierBlockedUntil = 0;
};

private _milestonesArray = [
    ["hasFoothold", _capturedCount >= 1],
    ["hasSupplyNetwork", _capturedTowns >= 3 || _capturedFactories >= 1],
    ["hasStrategicIndustry", _capturedFactories >= 1],
    ["hasMilitaryPresence", _capturedMilitary >= 1],
    ["hasCapitalPressure", _capturedCapitals >= 1 || _mapControl >= 60],
    ["mapHalfControlled", _halfMapLock],
    ["campaignNearVictory", _mapControl >= 80 || _capturedCapitals >= 1],
    ["tierFloorLocked", _halfMapLock],
    ["tierProgressBlocked", _tierBlockedUntil > serverTime]
];
private _milestones = createHashMapFromArray _milestonesArray;

private _previousTier = missionNamespace getVariable ["MWF_WorldTier", -1];
private _previousState = missionNamespace getVariable ["MWF_ProgressionState", ""];
private _previousMapControl = missionNamespace getVariable ["MWF_MapControlPercent", -1];
private _previousCapturedIds = missionNamespace getVariable ["MWF_CapturedZoneIDs", []];
private _previousFloorLock = missionNamespace getVariable ["MWF_WorldTierHalfMapLock", false];
private _stateChanged = (
    _previousTier != _worldTier ||
    _previousState != _progressionState ||
    {abs (_previousMapControl - _mapControl) >= 0.01} ||
    {!(_previousCapturedIds isEqualTo _capturedZoneIds)} ||
    {_previousFloorLock != _halfMapLock}
);

missionNamespace setVariable ["MWF_captured_zones_list", _capturedZones, true];
missionNamespace setVariable ["MWF_CapturedZoneIDs", _capturedZoneIds, true];
missionNamespace setVariable ["MWF_CapturedZoneCount", _capturedCount, true];
missionNamespace setVariable ["MWF_CapturedTownCount", _capturedTowns, true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", _capturedCapitals, true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", _capturedFactories, true];
missionNamespace setVariable ["MWF_ProductionBonus", _capturedFactories, true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", _capturedMilitary, true];
missionNamespace setVariable ["MWF_MapControlPercent", _mapControl, true];
missionNamespace setVariable ["MWF_WorldZoneCountTotal", _totalZones, true];
missionNamespace setVariable ["MWF_ContestedZoneCount", _contestedZones, true];
missionNamespace setVariable ["MWF_UnderAttackZoneCount", _underAttackZones, true];
missionNamespace setVariable ["MWF_WorldTier", _worldTier, true];
missionNamespace setVariable ["MWF_WorldTierProgress", _worldTierProgress, true];
missionNamespace setVariable ["MWF_WorldTierFloor", _floorTier, true];
missionNamespace setVariable ["MWF_WorldTierHalfMapLock", _halfMapLock, true];
missionNamespace setVariable ["MWF_ProgressionState", _progressionState, true];
missionNamespace setVariable ["MWF_ProgressionMilestonesArray", _milestonesArray, true];

missionNamespace setVariable ["MWF_ProgressionMilestones", _milestones, false];
missionNamespace setVariable ["MWF_WorldLastRecalcAt", diag_tickTime, false];
missionNamespace setVariable ["MWF_WorldStateDirty", false, false];

if (_stateChanged) then {
    private _version = (missionNamespace getVariable ["MWF_WorldStateVersion", 0]) + 1;
    missionNamespace setVariable ["MWF_WorldStateVersion", _version, true];
};

private _snapshot = [] call MWF_fnc_getWorldSnapshot;
missionNamespace setVariable ["MWF_WorldSnapshot", _snapshot, false];
missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];

if (_stateChanged) then {
    diag_log format [
        "[MWF World] Recalculated | Zones: %1/%2 | Control: %3%% | Tier: %4 (%5%%) | Floor: T%6 | State: %7",
        _capturedCount,
        _totalZones,
        round _mapControl,
        _worldTier,
        _worldTierProgress,
        _floorTier,
        _progressionState
    ];
};

missionNamespace setVariable ["MWF_WorldRecalcRunning", false, false];
_snapshot
