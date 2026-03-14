/*
    Author: Theane / ChatGPT
    Function: fn_determineGlobalThreat
    Project: Military War Framework

    Description:
    Converts stable world-state values into a global enemy threat posture.
    Returns [threatLevel, threatState, pressureScore].
*/

params [
    ["_worldTier", 1, [0]],
    ["_mapControl", 0, [0]],
    ["_contestedZones", 0, [0]],
    ["_underAttackZones", 0, [0]],
    ["_capturedCapitals", 0, [0]],
    ["_capturedFactories", 0, [0]],
    ["_capturedMilitary", 0, [0]],
    ["_destroyedHQs", 0, [0]],
    ["_destroyedRoadblocks", 0, [0]],
    ["_notoriety", 0, [0]],
    ["_incidentPressure", 0, [0]]
];

_worldTier = _worldTier max 0;
_mapControl = (_mapControl max 0) min 100;
_contestedZones = _contestedZones max 0;
_underAttackZones = _underAttackZones max 0;
_capturedCapitals = _capturedCapitals max 0;
_capturedFactories = _capturedFactories max 0;
_capturedMilitary = _capturedMilitary max 0;
_destroyedHQs = _destroyedHQs max 0;
_destroyedRoadblocks = _destroyedRoadblocks max 0;
_notoriety = _notoriety max 0;
_incidentPressure = _incidentPressure max 0;

private _pressureScore = 0;
_pressureScore = _pressureScore + (_worldTier * 15);
_pressureScore = _pressureScore + (_mapControl * 0.45);
_pressureScore = _pressureScore + (_contestedZones * 8);
_pressureScore = _pressureScore + (_underAttackZones * 10);
_pressureScore = _pressureScore + (_capturedCapitals * 20);
_pressureScore = _pressureScore + (_capturedFactories * 8);
_pressureScore = _pressureScore + (_capturedMilitary * 12);
_pressureScore = _pressureScore + (_destroyedHQs * 18);
_pressureScore = _pressureScore + (_destroyedRoadblocks * 6);
_pressureScore = _pressureScore + (_notoriety * 0.20);
_pressureScore = _pressureScore + (_incidentPressure * 0.75);

private _threatLevel = 0;
private _threatState = "low";

switch (true) do {
    case (_pressureScore >= 130): {
        _threatLevel = 5;
        _threatState = "war";
    };
    case (_pressureScore >= 100): {
        _threatLevel = 4;
        _threatState = "critical";
    };
    case (_pressureScore >= 70): {
        _threatLevel = 3;
        _threatState = "severe";
    };
    case (_pressureScore >= 40): {
        _threatLevel = 2;
        _threatState = "active";
    };
    case (_pressureScore >= 20): {
        _threatLevel = 1;
        _threatState = "elevated";
    };
    default {
        _threatLevel = 0;
        _threatState = "low";
    };
};

[_threatLevel, _threatState, _pressureScore]
