/*
    Author: Theane / ChatGPT
    Function: fn_recalculateWorldState
    Project: Military War Framework

    Description:
    Aggregates authoritative zone data into future-safe world progression values.
    Designed as the layer above zones for threat, missions, and economy hooks.
*/

if (!isServer) exitWith {createHashMap};

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

    if (_zone getVariable ["MWF_contested", false]) then {
        _contestedZones = _contestedZones + 1;
    };

    if (_zone getVariable ["MWF_underAttack", false]) then {
        _underAttackZones = _underAttackZones + 1;
    };

    if (_zone getVariable ["MWF_isCaptured", false]) then {
        _capturedZones pushBack _zone;
        _capturedZoneIds pushBackUnique (toLower (_zone getVariable ["MWF_zoneID", ""]));

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

private _worldTier = [
    _mapControl,
    _capturedCount,
    _capturedCapitals,
    _capturedFactories,
    _capturedMilitary
] call MWF_fnc_determineWorldTier;

private _progressionState = [
    _mapControl,
    _capturedCount,
    _capturedCapitals,
    _contestedZones,
    _underAttackZones
] call MWF_fnc_determineProgressionState;

private _milestones = createHashMapFromArray [
    ["hasFoothold", _capturedCount >= 1],
    ["hasSupplyNetwork", _capturedTowns >= 3 || _capturedFactories >= 1],
    ["hasStrategicIndustry", _capturedFactories >= 1],
    ["hasMilitaryPresence", _capturedMilitary >= 1],
    ["hasCapitalPressure", _capturedCapitals >= 1 || _mapControl >= 60],
    ["mapHalfControlled", _mapControl >= 50],
    ["campaignNearVictory", _mapControl >= 80 || _capturedCapitals >= 1]
];

private _previousTier = missionNamespace getVariable ["MWF_WorldTier", -1];
private _previousState = missionNamespace getVariable ["MWF_ProgressionState", ""];
private _previousMapControl = missionNamespace getVariable ["MWF_MapControlPercent", -1];

missionNamespace setVariable ["MWF_captured_zones_list", _capturedZones, true];
missionNamespace setVariable ["MWF_CapturedZoneIDs", _capturedZoneIds, true];
missionNamespace setVariable ["MWF_CapturedZoneCount", _capturedCount, true];
missionNamespace setVariable ["MWF_CapturedTownCount", _capturedTowns, true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", _capturedCapitals, true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", _capturedFactories, true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", _capturedMilitary, true];
missionNamespace setVariable ["MWF_MapControlPercent", _mapControl, true];
missionNamespace setVariable ["MWF_WorldZoneCountTotal", _totalZones, true];
missionNamespace setVariable ["MWF_ContestedZoneCount", _contestedZones, true];
missionNamespace setVariable ["MWF_UnderAttackZoneCount", _underAttackZones, true];
missionNamespace setVariable ["MWF_WorldTier", _worldTier, true];
missionNamespace setVariable ["MWF_ProgressionState", _progressionState, true];
missionNamespace setVariable ["MWF_ProgressionMilestones", _milestones, true];
missionNamespace setVariable ["MWF_WorldStateVersion", 1, true];

private _snapshot = [] call MWF_fnc_getWorldSnapshot;
missionNamespace setVariable ["MWF_WorldSnapshot", _snapshot, true];

if (_previousTier != _worldTier || _previousState != _progressionState || {abs (_previousMapControl - _mapControl) >= 0.01}) then {
    diag_log format [
        "[MWF World] Recalculated | Zones: %1/%2 | Control: %3%% | Tier: %4 | State: %5",
        _capturedCount,
        _totalZones,
        round _mapControl,
        _worldTier,
        _progressionState
    ];
};

_snapshot
