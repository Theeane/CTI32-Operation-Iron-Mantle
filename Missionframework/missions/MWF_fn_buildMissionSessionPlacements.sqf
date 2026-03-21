/*
    Author: Theane / ChatGPT
    Function: fn_buildMissionSessionPlacements
    Project: Military War Framework

    Description:
    Generates non-persistent session placements for every discovered mission template.
    Placements are randomized per server runtime, remain fixed during the runtime,
    and regenerate on restart.

    Rules:
    - land side missions prefer enemy-held zones when manual anchors are not supplied
    - side_mission_1..N are optional manual overrides and placeholders are ignored
    - Air currently reuses the land placement model when enabled later
    - Naval remains feature-switched and only reads suffixed markers
    - missions avoid the MOB
    - missions avoid FOBs
*/

if (!isServer) exitWith {[]};

params [
    ["_templates", [], [[]]]
];

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _allMarkers = allMapMarkers;
private _allowManualPlacements = !(missionNamespace getVariable ["MWF_HasCampaignSave", false]);

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

missionNamespace setVariable ["MWF_MissionDomainSupported_Land", _landEnabled && (!(_zones isEqualTo []) || !(_manualLandAnchors isEqualTo [])), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Naval", _navalEnabled && !(_manualNavalAnchors isEqualTo []), true];
missionNamespace setVariable ["MWF_MissionDomainSupported_Air", _airEnabled && (missionNamespace getVariable ["MWF_MissionDomainSupported_Land", false]), true];
missionNamespace setVariable ["MWF_LandMissionAnchors", _manualLandAnchors, true];
missionNamespace setVariable ["MWF_NavalMissionAnchors", _manualNavalAnchors, true];

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

private _isFarEnoughFromBases = {
    params ["_pos", "_mobMin", "_fobMin"];
    if ((_mobPos distance2D _pos) < _mobMin) exitWith { false };
    private _nearFob = _fobPositions findIf { (_x distance2D _pos) < _fobMin };
    _nearFob < 0
};

private _pickManualAnchor = {
    params ["_anchors", "_mobMin", "_fobMin"];
    private _picked = "";
    {
        private _candidate = _x;
        private _candidatePos = getMarkerPos _candidate;
        if ([_candidatePos, _mobMin, _fobMin] call _isFarEnoughFromBases) exitWith {
            _picked = _candidate;
        };
    } forEach (_anchors call BIS_fnc_arrayShuffle);
    _picked
};

{
    _x params ["_missionKey", "_category", "_difficulty", "_missionId", "_missionPath", ["_domain", "land", [""]]];

    private _position = [0,0,0];
    private _areaId = "";
    private _areaName = "Unknown Area";
    private _missionDefinition = [_missionPath] call _readMissionDefinition;
    private _allowedZoneTypes = [_missionDefinition, "allowedZoneTypes", []] call _getDefinitionValue;
    private _allowedZoneTypesLower = _allowedZoneTypes apply { toLower (str _x) };

    if (_domain in ["land", "air"]) then {
        private _pickedManual = [_manualLandAnchors, _primaryMobMin, _primaryFobMin] call _pickManualAnchor;
        if (_pickedManual isNotEqualTo "") then {
            _areaId = _pickedManual;
            _areaName = format ["Manual AO (%1)", _category];
            _position = [_pickedManual, 90, 360, false, true] call _pickMarkerPlacement;
        } else {
            private _zonePool = _zones select {
                private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
                private _zoneType = toLower (_x getVariable ["MWF_zoneType", "town"]);
                (_owner isEqualTo "enemy") && ((_allowedZoneTypesLower isEqualTo []) || {_zoneType in _allowedZoneTypesLower})
            };

            private _pickedZone = objNull;
            {
                _x params ["_mobMin", "_fobMin"];
                private _candidates = _zonePool select {
                    private _zonePos = getPosATL _x;
                    [_zonePos, _mobMin, _fobMin] call _isFarEnoughFromBases
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
    } else {
        if (_domain isEqualTo "naval") then {
            private _picked = [_manualNavalAnchors, _primaryMobMin, _primaryFobMin] call _pickManualAnchor;
            if (_picked isNotEqualTo "") then {
                _areaId = _picked;
                _areaName = format ["Naval AO (%1)", _category];
                _position = [_picked, 100, 450, true, false] call _pickMarkerPlacement;
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
