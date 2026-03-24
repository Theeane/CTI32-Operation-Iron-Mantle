/*
    Author: Theane / ChatGPT
    Function: fn_buildMissionSessionPlacements
    Project: Military War Framework

    Description:
    Generates non-persistent session placements for every discovered mission template.
    Placements are randomized per server runtime, remain fixed during the runtime,
    and regenerate on restart.

    Rules:
    - land and air missions use side_mission_1..N as optional manual overrides
    - manual overrides are ignored after a campaign save exists
    - land and air fall back to free land AO generation when manual anchors are unavailable
    - campaign zones are avoidance-only for land and air placements
    - naval uses Naval_mission_1..N as optional manual overrides and otherwise falls back to open water generation
    - missions avoid the MOB
    - missions avoid FOBs
*/

if (!isServer) exitWith {[]};

params [
    ["_templates", [], [[]]]
];

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _zoneAvoidanceData = _zones apply {
    [
        getPosATL _x,
        ((_x getVariable ["MWF_zoneRange", 300]) max 25) + 25,
        toLower (_x getVariable ["MWF_zoneID", ""]),
        _x getVariable ["MWF_zoneName", "Unknown Area"]
    ]
};
private _allMarkers = allMapMarkers;
private _allowManualPlacements = !(missionNamespace getVariable ["MWF_HasCampaignSave", false]);
private _worldSize = worldSize max 1;
private _worldCenter = [_worldSize * 0.5, _worldSize * 0.5, 0];

private _collectMarkerSeries = {
    params ["_baseName"];
    private _result = [];
    for "_i" from 1 to 99 do {
        private _markerName = format ["%1_%2", _baseName, _i];
        if (_markerName in _allMarkers) then {
            _result pushBack _markerName;
        };
    };
    _result
};

private _manualLandAnchors = if (_allowManualPlacements) then { ["side_mission"] call _collectMarkerSeries } else { [] };
private _manualNavalAnchors = if (_allowManualPlacements) then { ["Naval_mission"] call _collectMarkerSeries } else { [] };

private _landEnabled = missionNamespace getVariable ["MWF_Feature_LandEnabled", true];
private _navalEnabled = missionNamespace getVariable ["MWF_Feature_NavalEnabled", false];
private _airEnabled = missionNamespace getVariable ["MWF_Feature_AirEnabled", false];

missionNamespace setVariable ["MWF_LandMissionAnchors", _manualLandAnchors, true];
missionNamespace setVariable ["MWF_NavalMissionAnchors", _manualNavalAnchors, true];

private _placements = [];
if (_templates isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_MissionSessionPlacements", [], true];
    missionNamespace setVariable ["MWF_MissionDomainSupported_Land", false, true];
    missionNamespace setVariable ["MWF_MissionDomainSupported_Naval", false, true];
    missionNamespace setVariable ["MWF_MissionDomainSupported_Air", false, true];
    []
};

private _mobRef = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mobRef) then { getPosATL _mobRef } else { getMarkerPos "respawn_west" };
private _fobObjects = (missionNamespace getVariable ["MWF_FOB_Registry", []]) apply { _x param [1, objNull, [objNull]] };
private _fobPositions = (_fobObjects select { !isNull _x }) apply { getPosATL _x };
private _primaryMobMin = 1000;
private _primaryFobMin = 2000;

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    if !(_definition isEqualType []) exitWith { _default };
    private _idx = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };
    if (_idx < 0) exitWith { _default };
    (_definition # _idx) # 1
};

private _isFarEnoughFromBases = {
    params ["_pos", "_mobMin", "_fobMin"];
    if ((_mobPos distance2D _pos) < _mobMin) exitWith { false };
    private _nearFob = _fobPositions findIf { (_x distance2D _pos) < _fobMin };
    _nearFob < 0
};

private _isOutsideMissionZones = {
    params ["_pos"];
    private _overlap = _zoneAvoidanceData findIf {
        private _zonePos = _x # 0;
        private _zoneRadius = _x # 1;
        (_zonePos distance2D _pos) <= _zoneRadius
    };
    _overlap < 0
};

private _hasOpenWater = {
    params ["_pos"];
    if !(surfaceIsWater _pos) exitWith { false };

    private _waterHits = 0;
    {
        private _sample = [
            (_pos # 0) + ((sin _x) * 120),
            (_pos # 1) + ((cos _x) * 120),
            0
        ];
        if (surfaceIsWater _sample) then {
            _waterHits = _waterHits + 1;
        };
    } forEach [0, 45, 90, 135, 180, 225, 270, 315];

    _waterHits >= 5
};

private _isValidLandMissionPos = {
    params ["_pos", ["_mobMin", _primaryMobMin, [0]], ["_fobMin", _primaryFobMin, [0]]];
    !(_pos isEqualTo [0,0,0]) &&
    {!surfaceIsWater _pos} &&
    {[_pos, _mobMin, _fobMin] call _isFarEnoughFromBases} &&
    {[_pos] call _isOutsideMissionZones}
};

private _isValidNavalMissionPos = {
    params ["_pos", ["_mobMin", _primaryMobMin, [0]], ["_fobMin", _primaryFobMin, [0]]];
    !(_pos isEqualTo [0,0,0]) &&
    {surfaceIsWater _pos} &&
    {[_pos] call _hasOpenWater} &&
    {[_pos, _mobMin, _fobMin] call _isFarEnoughFromBases}
};

private _pickMarkerPlacement = {
    params ["_markerName", ["_innerRadius", 80, [0]], ["_outerRadius", 350, [0]], ["_waterOnly", false, [false]], ["_landOnly", false, [false]]];

    private _center = getMarkerPos _markerName;
    if (_center isEqualTo [0,0,0]) exitWith {_center};

    private _candidate = _center;
    private _found = false;
    for "_attempt" from 0 to 24 do {
        private _probe = [_center, _innerRadius, _outerRadius, 5, 0, 0.25, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        if (_probe isEqualTo _center) then {
            private _angle = random 360;
            private _distance = _innerRadius + random ((_outerRadius - _innerRadius) max 25);
            _probe = [
                (_center # 0) + ((sin _angle) * _distance),
                (_center # 1) + ((cos _angle) * _distance),
                0
            ];
        };

        private _isWater = surfaceIsWater _probe;
        if ((!_waterOnly || {_isWater}) && (!_landOnly || {!_isWater})) exitWith {
            _candidate = _probe;
            _found = true;
        };
    };

    if (!_found) then { _candidate = +_center; };
    _candidate
};

private _pickValidatedMarkerPlacement = {
    params ["_markerName", "_innerRadius", "_outerRadius", "_validator", ["_waterOnly", false, [false]], ["_landOnly", false, [false]]];

    private _center = getMarkerPos _markerName;
    if (_center isEqualTo [0,0,0]) exitWith { [0,0,0] };

    private _candidate = [0,0,0];
    for "_attempt" from 0 to 11 do {
        private _probe = [_markerName, _innerRadius, _outerRadius, _waterOnly, _landOnly] call _pickMarkerPlacement;
        if ([_probe, _primaryMobMin, _primaryFobMin] call _validator) exitWith {
            _candidate = +_probe;
        };
    };

    if ((_candidate isEqualTo [0,0,0]) && {[_center, _primaryMobMin, _primaryFobMin] call _validator}) then {
        _candidate = +_center;
    };

    _candidate
};

private _pickManualAnchor = {
    params ["_anchors", "_innerRadius", "_outerRadius", "_validator", ["_waterOnly", false, [false]], ["_landOnly", false, [false]]];

    private _pickedMarker = "";
    private _pickedPos = [0,0,0];

    {
        private _candidatePos = [_x, _innerRadius, _outerRadius, _validator, _waterOnly, _landOnly] call _pickValidatedMarkerPlacement;
        if !(_candidatePos isEqualTo [0,0,0]) exitWith {
            _pickedMarker = _x;
            _pickedPos = +_candidatePos;
        };
    } forEach (_anchors call BIS_fnc_arrayShuffle);

    [_pickedMarker, _pickedPos]
};

private _resolveAreaName = {
    params ["_pos", ["_domain", "land", [""]], ["_fallbackPrefix", "Field AO", [""]]];

    private _locationTypes = if (_domain isEqualTo "naval") then {
        ["NameMarine", "NameCityCapital", "NameCity", "NameVillage", "Airport", "NameLocal"]
    } else {
        ["NameCityCapital", "NameCity", "NameVillage", "NameLocal", "Airport"]
    };

    private _nearby = nearestLocations [_pos, _locationTypes, 3000];
    if (_nearby isEqualTo []) exitWith { _fallbackPrefix };

    private _locName = text (_nearby # 0);
    if (_locName isEqualTo "") exitWith { _fallbackPrefix };
    format ["%1 - %2", _fallbackPrefix, _locName]
};

private _findFreeLandPosition = {
    private _result = [0,0,0];

    for "_attempt" from 0 to 199 do {
        private _anchor = [random _worldSize, random _worldSize, 0];
        private _probe = [_anchor, 60, 420, 5, 0, 0.25, 0, [], [_anchor, _anchor]] call BIS_fnc_findSafePos;
        if (_probe isEqualTo _anchor) then {
            private _angle = random 360;
            private _distance = 80 + random 340;
            _probe = [
                (_anchor # 0) + ((sin _angle) * _distance),
                (_anchor # 1) + ((cos _angle) * _distance),
                0
            ];
        };

        if ([_probe, _primaryMobMin, _primaryFobMin] call _isValidLandMissionPos) exitWith {
            _result = +_probe;
        };
    };

    _result
};

private _findFreeWaterPosition = {
    private _result = [0,0,0];

    for "_attempt" from 0 to 249 do {
        private _probe = [random _worldSize, random _worldSize, 0];
        if ([_probe, _primaryMobMin, _primaryFobMin] call _isValidNavalMissionPos) exitWith {
            _result = +_probe;
        };
    };

    _result
};

{
    _x params ["_missionKey", "_category", "_difficulty", "_missionId", "_missionPath", ["_domain", "land", [""]]];

    private _position = [0,0,0];
    private _areaId = "";
    private _areaName = "Unknown Area";
    private _missionDefinition = if (!isNil "MWF_fnc_readMissionDefinition") then { [_missionPath] call MWF_fnc_readMissionDefinition } else { [] };
    private _zoneBound = [_missionDefinition, "requiresZonePlacement", false] call _getDefinitionValue;

    if (_domain in ["land", "air"]) then {
        private _manualResult = [_manualLandAnchors, 90, 360, _isValidLandMissionPos, false, true] call _pickManualAnchor;
        private _pickedManual = _manualResult # 0;
        private _manualPos = _manualResult # 1;

        if (_pickedManual isNotEqualTo "") then {
            _areaId = _pickedManual;
            _position = +_manualPos;
            _areaName = [_position, _domain, "Manual AO"] call _resolveAreaName;
        } else {
            if (_zoneBound) then {
                private _zonePlacement = [0,0,0];
                private _zoneAreaId = "";
                private _zoneAreaName = "Unknown Area";
                {
                    private _zonePos = getPosATL _x;
                    private _zoneId = toLower (_x getVariable ["MWF_zoneID", ""]);
                    if (([_zonePos, _primaryMobMin, _primaryFobMin] call _isFarEnoughFromBases) && (_zoneId isNotEqualTo "")) exitWith {
                        _zonePlacement = +_zonePos;
                        _zoneAreaId = _x getVariable ["MWF_zoneID", "unknown_zone"];
                        _zoneAreaName = _x getVariable ["MWF_zoneName", "Unknown Area"];
                    };
                } forEach (_zones call BIS_fnc_arrayShuffle);

                if !(_zonePlacement isEqualTo [0,0,0]) then {
                    _position = +_zonePlacement;
                    _areaId = _zoneAreaId;
                    _areaName = _zoneAreaName;
                };
            };

            if (_position isEqualTo [0,0,0]) then {
                _position = call _findFreeLandPosition;
                if !(_position isEqualTo [0,0,0]) then {
                    _areaId = format ["free_land_%1", _missionKey];
                    _areaName = [_position, _domain, "Field AO"] call _resolveAreaName;
                };
            };
        };
    } else {
        if (_domain isEqualTo "naval") then {
            private _manualResult = [_manualNavalAnchors, 100, 450, _isValidNavalMissionPos, true, false] call _pickManualAnchor;
            private _pickedManual = _manualResult # 0;
            private _manualPos = _manualResult # 1;

            if (_pickedManual isNotEqualTo "") then {
                _areaId = _pickedManual;
                _position = +_manualPos;
                _areaName = [_position, _domain, "Naval AO"] call _resolveAreaName;
            } else {
                _position = call _findFreeWaterPosition;
                if !(_position isEqualTo [0,0,0]) then {
                    _areaId = format ["free_naval_%1", _missionKey];
                    _areaName = [_position, _domain, "Offshore AO"] call _resolveAreaName;
                };
            };
        };
    };

    if !(_position isEqualTo [0,0,0]) then {
        _placements pushBack [_missionKey, _position, _areaId, _areaName, _domain];
    } else {
        diag_log format ["[MWF Missions] No valid session placement generated for %1 (%2/%3/%4).", _missionKey, _domain, _category, _difficulty];
    };
} forEach _templates;

private _landPlacementCount = { (_x param [4, "land", [""]]) isEqualTo "land" } count _placements;
private _navalPlacementCount = { (_x param [4, "land", [""]]) isEqualTo "naval" } count _placements;
private _airPlacementCount = { (_x param [4, "land", [""]]) isEqualTo "air" } count _placements;

missionNamespace setVariable ["MWF_MissionDomainSupported_Land", _landEnabled && (_landPlacementCount > 0), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Naval", _navalEnabled && (_navalPlacementCount > 0), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Air", _airEnabled && (_airPlacementCount > 0), true];
missionNamespace setVariable ["MWF_MissionSessionPlacements", _placements, true];
_placements
