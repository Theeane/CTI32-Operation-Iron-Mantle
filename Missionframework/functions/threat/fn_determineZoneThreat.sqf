/*
    Author: Theane / ChatGPT
    Function: fn_determineZoneThreat
    Project: Military War Framework

    Description:
    Calculates a zone-local threat profile from global threat posture and zone status.
    Returns a hashMap for future mission and response systems.
*/

params [
    ["_zone", objNull, [objNull]],
    ["_globalThreatLevel", 0, [0]],
    ["_globalThreatState", "low", [""]],
    ["_pressureScore", 0, [0]]
];

if (isNull _zone) exitWith {createHashMap};

private _zoneId = toLower (_zone getVariable ["MWF_zoneID", ""]);
private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
private _isCaptured = _zone getVariable ["MWF_isCaptured", false];
private _isContested = _zone getVariable ["MWF_contested", false];
private _isUnderAttack = _zone getVariable ["MWF_underAttack", false];

private _zoneScore = (_globalThreatLevel * 12) + (_pressureScore * 0.10);

if (_isContested) then {
    _zoneScore = _zoneScore + 12;
};

if (_isUnderAttack) then {
    _zoneScore = _zoneScore + 15;
};

if (_isCaptured) then {
    _zoneScore = _zoneScore + 4;
} else {
    _zoneScore = _zoneScore + 2;
};

switch (_zoneType) do {
    case "capital": {
        _zoneScore = _zoneScore + 12;
    };
    case "military": {
        _zoneScore = _zoneScore + 9;
    };
    case "factory": {
        _zoneScore = _zoneScore + 8;
    };
    default {
        _zoneScore = _zoneScore + 4;
    };
};

private _zoneThreatLevel = 0;
private _zoneThreatState = "low";
private _responseProfile = "monitor";

switch (true) do {
    case (_zoneScore >= 65): {
        _zoneThreatLevel = 4;
        _zoneThreatState = "critical";
        _responseProfile = if (_isCaptured) then {"counterattack"} else {"fortified_front"};
    };
    case (_zoneScore >= 50): {
        _zoneThreatLevel = 3;
        _zoneThreatState = "high";
        _responseProfile = if (_isCaptured) then {"pressure"} else {"reinforced_front"};
    };
    case (_zoneScore >= 35): {
        _zoneThreatLevel = 2;
        _zoneThreatState = "active";
        _responseProfile = "patrols";
    };
    case (_zoneScore >= 20): {
        _zoneThreatLevel = 1;
        _zoneThreatState = "elevated";
        _responseProfile = "screening";
    };
    default {
        _zoneThreatLevel = 0;
        _zoneThreatState = "low";
        _responseProfile = "monitor";
    };
};

createHashMapFromArray [
    ["zoneId", _zoneId],
    ["zoneType", _zoneType],
    ["isCaptured", _isCaptured],
    ["isContested", _isContested],
    ["isUnderAttack", _isUnderAttack],
    ["globalThreatLevel", _globalThreatLevel],
    ["globalThreatState", _globalThreatState],
    ["threatLevel", _zoneThreatLevel],
    ["threatState", _zoneThreatState],
    ["pressureScore", _zoneScore],
    ["responseProfile", _responseProfile]
]
