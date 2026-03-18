/*
    Author: Theane / ChatGPT
    Function: fn_determineZoneThreat
    Project: Military War Framework

    Description:
    Calculates a zone-local threat profile from global dynamic threat posture, zone status,
    and recent loud-operation priority markers.
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

private _hotZones = + (missionNamespace getVariable ["MWF_ThreatHotZones", []]);
private _hotScore = 0;
{
    if (toLower (_x param [0, "", [""]]) isEqualTo _zoneId) exitWith {
        _hotScore = _x param [2, 0, [0]];
    };
} forEach _hotZones;

private _zoneScore = (_pressureScore * 0.55) + (_globalThreatLevel * 6);
if (_isContested) then { _zoneScore = _zoneScore + 8; };
if (_isUnderAttack) then { _zoneScore = _zoneScore + 12; };
if (_isCaptured) then { _zoneScore = _zoneScore + 5; };
_zoneScore = _zoneScore + _hotScore;

switch (_zoneType) do {
    case "capital": { _zoneScore = _zoneScore + 10; };
    case "military": { _zoneScore = _zoneScore + 7; };
    case "factory": { _zoneScore = _zoneScore + 6; };
    default { _zoneScore = _zoneScore + 3; };
};

private _zoneThreatLevel = 0;
private _zoneThreatState = "low";
private _responseProfile = "ambient_patrols";

switch (true) do {
    case (_zoneScore >= 80): {
        _zoneThreatLevel = 5;
        _zoneThreatState = "hunt";
        _responseProfile = if (_hotScore > 0 || _isUnderAttack) then {"active_hunt"} else {"major_counterattack"};
    };
    case (_zoneScore >= 60): {
        _zoneThreatLevel = 4;
        _zoneThreatState = "search";
        _responseProfile = if (_hotScore > 0 || _isUnderAttack) then {"search_grid"} else {"counterattack"};
    };
    case (_zoneScore >= 40): {
        _zoneThreatLevel = 3;
        _zoneThreatState = "active";
        _responseProfile = if (_hotScore > 0) then {"reinforced_search"} else {"reinforced_patrols"};
    };
    case (_zoneScore >= 20): {
        _zoneThreatLevel = 2;
        _zoneThreatState = "elevated";
        _responseProfile = "patrols";
    };
    case (_zoneScore >= 5): {
        _zoneThreatLevel = 1;
        _zoneThreatState = "watch";
        _responseProfile = "light_patrols";
    };
    default {
        _zoneThreatLevel = 0;
        _zoneThreatState = "low";
        _responseProfile = "ambient_patrols";
    };
};

private _priorityScore = _zoneScore + (_hotScore * 2);

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
    ["priorityScore", _priorityScore],
    ["responseProfile", _responseProfile]
]
