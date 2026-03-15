/*
    Author: Theane / ChatGPT
    Function: fn_buildThreatDirectives
    Project: Military War Framework

    Description:
    Converts threat state into gameplay-safe strategic directives.
    Returns a hashMap that later systems can consume without duplicating logic.
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

private _mapControl = _worldSnapshot getOrDefault ["mapControlPercent", 0];
private _contestedCount = _worldSnapshot getOrDefault ["contestedZoneCount", 0];
private _underAttackCount = _worldSnapshot getOrDefault ["underAttackZoneCount", 0];
private _worldTier = _worldSnapshot getOrDefault ["worldTier", 1];
private _basePressure = _baseThreat getOrDefault ["basePressure", 0];
private _baseAttackState = _baseThreat getOrDefault ["baseAttackState", "idle"];

private _patrolDensity = (0.15 + (_globalThreatLevel * 0.10) + (_contestedCount * 0.03)) min 1;
private _qrfInterval = (1200 - (_globalThreatLevel * 120) - (_priorityTargetCount * 45)) max 240;
private _roadblockPressure = ((_globalThreatLevel * 10) + (_mapControl * 0.18) + (_destroyedRoadblockCount * 6)) min 100;
private _hqPressure = ((_globalThreatLevel * 12) + (_mapControl * 0.25) + (_destroyedHQCount * 10)) min 100;
private _missionEscalation = "low";

switch (true) do {
    case (_globalThreatLevel >= 5 || _pressureScore >= 130): { _missionEscalation = "war"; };
    case (_globalThreatLevel >= 4 || _pressureScore >= 100): { _missionEscalation = "critical"; };
    case (_globalThreatLevel >= 3 || _pressureScore >= 70): { _missionEscalation = "high"; };
    case (_globalThreatLevel >= 2 || _pressureScore >= 40): { _missionEscalation = "medium"; };
    default { _missionEscalation = "low"; };
};

private _enabledResponses = [];

if (_patrolDensity >= 0.25) then { _enabledResponses pushBackUnique "patrol_surge"; };
if (_globalThreatLevel >= 2 || _underAttackCount > 0) then { _enabledResponses pushBackUnique "qrf"; };
if (_roadblockPressure >= 35) then { _enabledResponses pushBackUnique "roadblocks"; };
if (_hqPressure >= 40) then { _enabledResponses pushBackUnique "hq_reinforcement"; };
if (_basePressure >= 25) then { _enabledResponses pushBackUnique "base_search"; };
if (_baseAttackState in ["hunt_window", "assault_window"]) then { _enabledResponses pushBackUnique "base_attack"; };
if (_priorityTargetCount > 0 && _globalThreatLevel >= 2) then { _enabledResponses pushBackUnique "counterattack"; };

createHashMapFromArray [
    ["globalThreatLevel", _globalThreatLevel],
    ["globalThreatState", _globalThreatState],
    ["worldTier", _worldTier],
    ["patrolDensity", _patrolDensity],
    ["qrfInterval", _qrfInterval],
    ["roadblockPressure", _roadblockPressure],
    ["hqPressure", _hqPressure],
    ["basePressure", _basePressure],
    ["baseAttackState", _baseAttackState],
    ["missionEscalation", _missionEscalation],
    ["enabledResponses", _enabledResponses]
]
