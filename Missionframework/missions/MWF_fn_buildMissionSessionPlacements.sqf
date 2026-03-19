/*
    Author: Theane / ChatGPT
    Function: fn_buildMissionSessionPlacements
    Project: Military War Framework

    Description:
    Generates non-persistent session placements for every discovered mission template.
    Placements are randomized per server runtime, remain fixed during the runtime,
    and regenerate on restart.

    Return:
    Array of placement records:
    [missionKey, positionATL, areaId, areaName, domain]
*/

if (!isServer) exitWith {[]};

params [
    ["_templates", [], [[]]]
];

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _allMarkers = allMapMarkers;
private _navalAnchors = _allMarkers select { toLower _x find "naval_mission" == 0 };
if (_navalAnchors isEqualTo [] && {"Naval_mission" in _allMarkers}) then {
    _navalAnchors pushBack "Naval_mission";
};
private _airAnchors = [];
for "_i" from 1 to 99 do {
    private _markerName = format ["MWF_Air_SideMission_%1", _i];
    if (_markerName in _allMarkers) then {
        _airAnchors pushBack _markerName;
    };
};
if (_airAnchors isEqualTo [] && {"MWF_Air_SideMission" in _allMarkers}) then {
    _airAnchors pushBack "MWF_Air_SideMission";
};

missionNamespace setVariable ["MWF_MissionDomainSupported_Land", !(_zones isEqualTo []), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Naval", !(_navalAnchors isEqualTo []), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Air", !(_airAnchors isEqualTo []), true];
missionNamespace setVariable ["MWF_NavalMissionAnchors", _navalAnchors, true];
missionNamespace setVariable ["MWF_AirMissionAnchors", _airAnchors, true];

private _placements = [];

if (_templates isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_MissionSessionPlacements", [], true];
    []
};

private _pickLandPlacement = {
    params ["_zone"];

    private _zonePos = getPosWorld _zone;
    private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
    private _safeRadius = (_zoneRange * 0.25) max 40;
    private _spawnRadius = (_zoneRange * 0.7) max 120;
    private _candidate = [_zonePos, _safeRadius, _spawnRadius, 5, 0, 0.3, 0, [], [_zonePos, _zonePos]] call BIS_fnc_findSafePos;

    if (_candidate isEqualTo _zonePos) then {
        private _angle = random 360;
        private _distance = _safeRadius + random ((_spawnRadius - _safeRadius) max 25);
        _candidate = [
            (_zonePos # 0) + ((sin _angle) * _distance),
            (_zonePos # 1) + ((cos _angle) * _distance),
            0
        ];
    };

    _candidate
};

private _pickMarkerPlacement = {
    params ["_markerName", ["_innerRadius", 80, [0]], ["_outerRadius", 350, [0]]];

    private _center = getMarkerPos _markerName;
    if (_center isEqualTo [0,0,0]) exitWith {_center};

    private _candidate = [_center, _innerRadius, _outerRadius, 5, 0, 0.25, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
    if (_candidate isEqualTo _center) then {
        private _angle = random 360;
        private _distance = _innerRadius + random ((_outerRadius - _innerRadius) max 25);
        _candidate = [
            (_center # 0) + ((sin _angle) * _distance),
            (_center # 1) + ((cos _angle) * _distance),
            0
        ];
    };

    _candidate
};

{
    _x params ["_missionKey", "_category", "_difficulty", "_missionId", "_missionPath", ["_domain", "land", [""]]];

    private _position = [0,0,0];
    private _areaId = "";
    private _areaName = "Unknown Area";

    switch (_domain) do {
        case "land": {
            if (_zones isNotEqualTo []) then {
                private _zone = selectRandom _zones;
                _areaId = _zone getVariable ["MWF_zoneID", "unknown_zone"];
                _areaName = _zone getVariable ["MWF_zoneName", "Unknown Area"];
                _position = [_zone] call _pickLandPlacement;
            };
        };

        case "naval": {
            if (_navalAnchors isNotEqualTo []) then {
                private _anchor = selectRandom _navalAnchors;
                _areaId = _anchor;
                _areaName = format ["Naval AO (%1)", _category];
                _position = [_anchor, 100, 450] call _pickMarkerPlacement;
            };
        };

        case "air": {
            if (_airAnchors isNotEqualTo []) then {
                private _anchor = selectRandom _airAnchors;
                _areaId = _anchor;
                _areaName = format ["Air AO (%1)", _category];
                _position = [_anchor, 120, 500] call _pickMarkerPlacement;
            };
        };
    };

    if !(_position isEqualTo [0,0,0]) then {
        _placements pushBack [_missionKey, _position, _areaId, _areaName, _domain];
    } else {
        diag_log format ["[MWF Missions] No valid session placement generated for %1 (%2/%3/%4).", _missionKey, _domain, _category, _difficulty];
    };
} forEach _templates;

missionNamespace setVariable ["MWF_MissionSessionPlacements", _placements, true];
_placements
