/*
    Author: Theane / ChatGPT
    Function: fn_buildMissionSessionPlacements
    Project: Military War Framework

    Description:
    Generates non-persistent session placements for every discovered mission template.
    Placements are randomized per server runtime, remain fixed during the runtime,
    and regenerate on restart.

    Rules added in this patch:
    - land side missions prefer enemy-held zones only
    - mission templates respect allowedZoneTypes where possible
    - missions avoid the MOB
    - missions avoid FOBs
    - tutorial remains the exception elsewhere; this generator only handles side missions
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

private _mobRef = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mobRef) then { getPosATL _mobRef } else { getMarkerPos "respawn_west" };
private _fobObjects = (missionNamespace getVariable ["MWF_FOB_Registry", []]) apply { _x param [1, objNull, [objNull]] };
private _fobPositions = (_fobObjects select { !isNull _x }) apply { getPosATL _x };
private _distanceSteps = [
    [1000, 2000],
    [750, 1500],
    [500, 1000],
    [250, 500],
    [100, 100]
];
private _primaryMobMin = (_distanceSteps # 0) # 0;
private _primaryFobMin = (_distanceSteps # 0) # 1;

private _readMissionDefinition = {
    params ["_missionPath"];
    if !(fileExists _missionPath) exitWith { [] };

    private _raw = loadFile _missionPath;
    if (_raw isEqualTo "") exitWith { [] };

    private _marker = "private _missionDefinition = ";
    private _markerPos = _raw find _marker;
    if (_markerPos < 0) exitWith { [] };

    private _afterMarker = _markerPos + (count _marker);
    private _tail = _raw select [_afterMarker];
    private _localOpen = _tail find "[";
    if (_localOpen < 0) exitWith { [] };

    private _start = _afterMarker + _localOpen;
    private _depth = 0;
    private _inString = false;
    private _end = -1;

    for "_i" from _start to ((count _raw) - 1) do {
        private _ch = _raw select [_i, 1];
        if (_ch isEqualTo (toString [34])) then {
            _inString = !_inString;
        } else {
            if (!_inString) then {
                if (_ch isEqualTo "[") then { _depth = _depth + 1; };
                if (_ch isEqualTo "]") then {
                    _depth = _depth - 1;
                    if (_depth <= 0) exitWith { _end = _i; };
                };
            };
        };
    };

    if (_end < _start) exitWith { [] };
    private _arrayText = _raw select [_start, (_end - _start) + 1];
    private _definition = call compile _arrayText;
    if !(_definition isEqualType []) exitWith { [] };
    _definition
};

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    if !(_definition isEqualType []) exitWith { _default };
    private _idx = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };
    if (_idx < 0) exitWith { _default };
    (_definition # _idx) # 1
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

private _isFarEnoughFromBases = {
    params ["_pos", "_mobMin", "_fobMin"];
    if ((_mobPos distance2D _pos) < _mobMin) exitWith { false };
    private _nearFob = _fobPositions findIf { (_x distance2D _pos) < _fobMin };
    _nearFob < 0
};

{
    _x params ["_missionKey", "_category", "_difficulty", "_missionId", "_missionPath", ["_domain", "land", [""]]];

    private _position = [0,0,0];
    private _areaId = "";
    private _areaName = "Unknown Area";
    private _missionDefinition = [_missionPath] call _readMissionDefinition;
    private _allowedZoneTypes = [_missionDefinition, "allowedZoneTypes", []] call _getDefinitionValue;
    private _allowedZoneTypesLower = _allowedZoneTypes apply { toLower (str _x) };

    switch (_domain) do {
        case "land": {
            private _zonePool = _zones select {
                private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
                private _zoneType = toLower (_x getVariable ["MWF_zoneType", "town"]);
                (_owner isEqualTo "enemy") && ((_allowedZoneTypesLower isEqualTo []) || {_zoneType in _allowedZoneTypesLower})
            };

            private _pickedZone = objNull;
            {
                _x params ["_mobMin", "_fobMin"];
                private _candidates = _zonePool select {
                    [_x, _mobMin, _fobMin] call {
                        params ["_zone", "_mobMinLocal", "_fobMinLocal"];
                        private _zonePos = getPosATL _zone;
                        [_zonePos, _mobMinLocal, _fobMinLocal] call _isFarEnoughFromBases
                    }
                };
                if (_candidates isNotEqualTo []) exitWith {
                    _pickedZone = selectRandom _candidates;
                };
            } forEach _distanceSteps;

            if (!isNull _pickedZone) then {
                _areaId = _pickedZone getVariable ["MWF_zoneID", "unknown_zone"];
                _areaName = _pickedZone getVariable ["MWF_zoneName", "Unknown Area"];
                _position = [_pickedZone] call _pickLandPlacement;
            };
        };

        case "naval": {
            private _picked = "";
            {
                private _candidate = _x;
                private _candidatePos = getMarkerPos _candidate;
                if ([_candidatePos, _primaryMobMin, _primaryFobMin] call _isFarEnoughFromBases) exitWith {
                    _picked = _candidate;
                };
            } forEach (_navalAnchors call BIS_fnc_arrayShuffle);

            if (_picked isNotEqualTo "") then {
                _areaId = _picked;
                _areaName = format ["Naval AO (%1)", _category];
                _position = [_picked, 100, 450] call _pickMarkerPlacement;
            };
        };

        case "air": {
            private _picked = "";
            {
                private _candidate = _x;
                private _candidatePos = getMarkerPos _candidate;
                if ([_candidatePos, _primaryMobMin, _primaryFobMin] call _isFarEnoughFromBases) exitWith {
                    _picked = _candidate;
                };
            } forEach (_airAnchors call BIS_fnc_arrayShuffle);

            if (_picked isNotEqualTo "") then {
                _areaId = _picked;
                _areaName = format ["Air AO (%1)", _category];
                _position = [_picked, 120, 500] call _pickMarkerPlacement;
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
