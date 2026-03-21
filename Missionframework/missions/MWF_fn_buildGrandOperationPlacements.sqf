/*
    Author: Theane / ChatGPT
    Function: fn_buildGrandOperationPlacements
    Project: Military War Framework

    Description:
    Generates session-based, non-persistent placement anchors for grand operations.
    main_op_1..N are optional manual overrides. Placeholder marker names are ignored.
    If no manual anchors exist, placements fall back to enemy-held zones.
*/

if (!isServer) exitWith {[]};

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _placements = [];
private _allMarkers = allMapMarkers;

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

private _manualAnchors = ["main_op"] call _collectMarkerSeries;
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

private _isFarEnoughFromBases = {
    params ["_pos", "_mobMin", "_fobMin"];
    if ((_mobPos distance2D _pos) < _mobMin) exitWith { false };
    ((_fobPositions findIf { (_x distance2D _pos) < _fobMin }) < 0)
};

private _pickMarkerPlacement = {
    params ["_markerName", ["_innerRadius", 100, [0]], ["_outerRadius", 450, [0]]];
    private _center = getMarkerPos _markerName;
    if (_center isEqualTo [0,0,0]) exitWith { _center };

    private _candidate = [_center, _innerRadius, _outerRadius, 5, 0, 0.25, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
    if (_candidate isEqualTo _center) then {
        _candidate = +_center;
    };
    _candidate
};

if (_manualAnchors isNotEqualTo []) then {
    private _candidateAnchors = [];
    {
        _x params ["_mobMin", "_fobMin"];
        _candidateAnchors = _manualAnchors select {
            [getMarkerPos _x, _mobMin, _fobMin] call _isFarEnoughFromBases
        };
        if (_candidateAnchors isNotEqualTo []) exitWith {};
    } forEach _distanceSteps;

    if (_candidateAnchors isEqualTo []) then {
        _candidateAnchors = _manualAnchors;
    };

    _candidateAnchors = _candidateAnchors call BIS_fnc_arrayShuffle;
    private _anchorsToCreate = ((count _candidateAnchors) min 3) max 1;

    for "_i" from 0 to (_anchorsToCreate - 1) do {
        private _markerName = _candidateAnchors # _i;
        _placements pushBack [
            _i,
            [_markerName, 110, 500] call _pickMarkerPlacement,
            _markerName,
            format ["Manual Main Op AO %1", _i + 1]
        ];
    };

    missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", _placements, true];
    _placements
} else {
    if (_zones isEqualTo []) exitWith {
        missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", [], true];
        []
    };

    private _enemyZones = _zones select {
        private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
        _owner isEqualTo "enemy"
    };

    private _isValidZone = {
        params ["_zone", "_mobMin", "_fobMin"];
        private _zonePos = getPosATL _zone;
        if ((_mobPos distance2D _zonePos) < _mobMin) exitWith { false };
        ((_fobPositions findIf { (_x distance2D _zonePos) < _fobMin }) < 0)
    };

    private _candidateZones = [];
    {
        _x params ["_mobMin", "_fobMin"];
        _candidateZones = _enemyZones select { [_x, _mobMin, _fobMin] call _isValidZone };
        if (_candidateZones isNotEqualTo []) exitWith {};
    } forEach _distanceSteps;

    if (_candidateZones isEqualTo []) then {
        _candidateZones = _enemyZones;
    };

    if (_candidateZones isEqualTo []) exitWith {
        missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", [], true];
        []
    };

    private _anchorsToCreate = ((count _candidateZones) min 3) max 1;
    private _shuffledZones = +_candidateZones;
    _shuffledZones = _shuffledZones call BIS_fnc_arrayShuffle;

    for "_i" from 0 to (_anchorsToCreate - 1) do {
        private _zone = _shuffledZones # _i;
        private _zonePos = getPosWorld _zone;
        private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
        private _position = [_zonePos, (_zoneRange * 0.2) max 40, (_zoneRange * 0.75) max 120, 5, 0, 0.3, 0, [], [_zonePos, _zonePos]] call BIS_fnc_findSafePos;

        if (_position isEqualTo _zonePos) then {
            _position = +_zonePos;
        };

        _placements pushBack [
            _i,
            _position,
            _zone getVariable ["MWF_zoneID", format ["grandop_zone_%1", _i]],
            _zone getVariable ["MWF_zoneName", "Unknown Area"]
        ];
    };

    missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", _placements, true];
    _placements
};
