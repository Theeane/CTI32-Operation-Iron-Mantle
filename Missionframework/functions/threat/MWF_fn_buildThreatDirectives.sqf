/*
    Author: Theane / ChatGPT
    Function: fn_buildThreatDirectives
    Project: Military War Framework

    Description:
    Converts dynamic threat percent into gameplay-safe directives.
    Patrols always exist, but density and search aggressiveness scale upward with threat.
*/

params [
    ["_globalThreatLevel", 0, [0]],
    ["_globalThreatState", "low", [""]],
    ["_pressureScore", 0, [0]],
    ["_worldSnapshot", createHashMap, [createHashMap]],
    ["_baseThreat", createHashMap, [createHashMap]],
    ["_destroyedHQCount", 0, [0]],
    ["_destroyedRoadblockCount", 0, [0]],
    ["_priorityTargetCount", 0, [0]]
];

private _basePressure = _baseThreat getOrDefault ["basePressure", 0];
private _baseAttackState = _baseThreat getOrDefault ["baseAttackState", "idle"];
private _patrolDensity = (0.15 + (_pressureScore / 120)) min 1;
private _qrfInterval = (1200 - (_pressureScore * 6) - (_priorityTargetCount * 30)) max 180;
private _roadblockPressure = ((_pressureScore * 0.6) + (_destroyedRoadblockCount * 4)) min 100;
private _hqPressure = ((_pressureScore * 0.7) + (_destroyedHQCount * 8)) min 100;
private _missionEscalation = _globalThreatState;

private _enabledResponses = ["patrols"];
if (_pressureScore >= 20) then { _enabledResponses pushBackUnique "screening"; };
if (_pressureScore >= 40) then { _enabledResponses pushBackUnique "search"; };
if (_pressureScore >= 60) then { _enabledResponses pushBackUnique "qrf"; };
if (_pressureScore >= 80) then { _enabledResponses pushBackUnique "hunt"; };
if (_priorityTargetCount > 0 && _pressureScore >= 40) then { _enabledResponses pushBackUnique "priority_response"; };
if (_basePressure >= 25) then { _enabledResponses pushBackUnique "base_search"; };
if (_baseAttackState in ["hunt_window", "assault_window"]) then { _enabledResponses pushBackUnique "base_attack"; };

createHashMapFromArray [
    ["globalThreatLevel", _globalThreatLevel],
    ["globalThreatState", _globalThreatState],
    ["worldTier", _worldSnapshot getOrDefault ["worldTier", 1]],
    ["patrolDensity", _patrolDensity],
    ["qrfInterval", _qrfInterval],
    ["roadblockPressure", _roadblockPressure],
    ["hqPressure", _hqPressure],
    ["basePressure", _basePressure],
    ["baseAttackState", _baseAttackState],
    ["missionEscalation", _missionEscalation],
    ["enabledResponses", _enabledResponses]
]
