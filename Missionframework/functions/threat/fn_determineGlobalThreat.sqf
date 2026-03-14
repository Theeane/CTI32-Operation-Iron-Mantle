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
    ["_capturedMilitary", 0, [0]]
];

private _pressureScore = 0;
_pressureScore = _pressureScore + (_worldTier * 15);
_pressureScore = _pressureScore + (_mapControl * 0.45);
_pressureScore = _pressureScore + (_contestedZones * 8);
_pressureScore = _pressureScore + (_underAttackZones * 10);
_pressureScore = _pressureScore + (_capturedCapitals * 20);
_pressureScore = _pressureScore + (_capturedFactories * 8);
_pressureScore = _pressureScore + (_capturedMilitary * 12);

private _threatLevel = 0;
private _threatState = "low";

switch (true) do {
    case (_pressureScore >= 110): {
        _threatLevel = 4;
        _threatState = "critical";
    };
    case (_pressureScore >= 80): {
        _threatLevel = 3;
        _threatState = "severe";
    };
    case (_pressureScore >= 50): {
        _threatLevel = 2;
        _threatState = "active";
    };
    case (_pressureScore >= 25): {
        _threatLevel = 1;
        _threatState = "elevated";
    };
    default {
        _threatLevel = 0;
        _threatState = "low";
    };
};

[_threatLevel, _threatState, _pressureScore]
