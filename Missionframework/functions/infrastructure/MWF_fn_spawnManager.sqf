/*
    Author: Theane / ChatGPT
    Function: fn_spawnManager
    Project: Military War Framework

    Description:
    Handles infrastructure site generation and spawning.

    Rules:
    - hq_1..N and roadblock_1..N are optional manual overrides
    - placeholder markers without numeric suffix are ignored
    - if no manual markers exist, sites are autogen'd from the current zone network
    - land infrastructure is active now; naval / air stay behind separate feature switches elsewhere
*/

if (!isServer) exitWith {};

params [["_mode", "BOOTSTRAP"], ["_params", []]];

private _allMarkers = allMapMarkers;
private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _mobRef = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mobRef) then { getPosATL _mobRef } else { getMarkerPos "respawn_west" };
private _fobObjects = (missionNamespace getVariable ["MWF_FOB_Registry", []]) apply { _x param [1, objNull, [objNull]] };
private _fobPositions = (_fobObjects select { !isNull _x }) apply { getPosATL _x };

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

private _isFarEnoughFromBases = {
    params ["_pos", ["_mobMin", 1000, [0]], ["_fobMin", 1500, [0]]];
    if ((_mobPos distance2D _pos) < _mobMin) exitWith { false };
    ((_fobPositions findIf { (_x distance2D _pos) < _fobMin }) < 0)
};

private _siteMatchesDestroyed = {
    params ["_pos", "_destroyedRegistry"];
    (_destroyedRegistry findIf { _x distance2D _pos < 35 }) >= 0
};

private _siteOccupied = {
    params ["_pos", ["_radius", 60, [0]]];
    ({ !isNull _x && {alive _x} && {_x distance2D _pos < _radius} && {(_x getVariable ["MWF_InfraType", ""]) isNotEqualTo ""} } count allMissionObjects "All") > 0
};

private _manualMarkerPositions = {
    params ["_markerNames"];
    private _result = [];
    {
        private _pos = getMarkerPos _x;
        if (_pos isEqualType [] && {count _pos >= 2} && {!surfaceIsWater _pos}) then {
            if ([_pos, 1000, 1500] call _isFarEnoughFromBases) then {
                _result pushBackUnique _pos;
            };
        };
    } forEach _markerNames;
    _result
};

private _resolveStableInfrastructureId = {
    params ["_pos", ["_normalizedType", "ROADBLOCK", [""]]];
    private _siteList = if ((toUpper _normalizedType) isEqualTo "HQ") then {
        +(missionNamespace getVariable ["MWF_FixedInfrastructure", []])
    } else {
        +(missionNamespace getVariable ["MWF_PotentialBaseSites", []])
    };

    private _siteIndex = _siteList findIf {
        (_x isEqualType []) && {count _x >= 2} && {(_x distance2D _pos) < 35}
    };

    if (_siteIndex < 0) exitWith { "" };
    format ["%1_%2", toLower _normalizedType, _siteIndex]
};

private _enemyZones = _zones select {
    private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
    _owner isEqualTo "enemy"
};

private _generateHQSites = {
    private _manual = [["hq"] call _collectMarkerSeries] call _manualMarkerPositions;
    if !(_manual isEqualTo []) exitWith { _manual };

    private _preferred = _enemyZones select {
        private _zoneType = toLower (_x getVariable ["MWF_zoneType", "town"]);
        _zoneType in ["military", "capital", "factory"]
    };
    if (_preferred isEqualTo []) then { _preferred = +_enemyZones; };
    _preferred = _preferred call BIS_fnc_arrayShuffle;

    private _siteCount = (((count _preferred) max 1) min 3);
    private _sites = [];

    {
        private _zonePos = getPosATL _x;
        if ([_zonePos, 1000, 2000] call _isFarEnoughFromBases) then {
            _sites pushBackUnique _zonePos;
        };
        if ((count _sites) >= _siteCount) exitWith {};
    } forEach _preferred;

    _sites
};

private _generateRoadblockSites = {
    private _manual = [["roadblock"] call _collectMarkerSeries] call _manualMarkerPositions;
    if !(_manual isEqualTo []) exitWith { _manual };

    private _pool = +_enemyZones;
    _pool = _pool call BIS_fnc_arrayShuffle;
    private _siteCount = (((count _pool) max 2) min 8);
    private _sites = [];

    {
        private _zone = _x;
        private _zonePos = getPosATL _zone;
        if ([_zonePos, 1000, 1500] call _isFarEnoughFromBases) then {
            private _roads = _zonePos nearRoads (((_zone getVariable ["MWF_zoneRange", 300]) max 250) min 600);
            private _candidatePos = if (_roads isNotEqualTo []) then { getPosATL (selectRandom _roads) } else { _zonePos };
            if (!surfaceIsWater _candidatePos) then {
                if ((_sites findIf { _x distance2D _candidatePos < 250 }) < 0) then {
                    _sites pushBack _candidatePos;
                };
            };
        };
        if ((count _sites) >= _siteCount) exitWith {};
    } forEach _pool;

    _sites
};

if (_mode == "BOOTSTRAP") exitWith {
    if (missionNamespace getVariable ["MWF_InfrastructureBootstrapped", false]) exitWith {};

    private _hqSites = +(missionNamespace getVariable ["MWF_FixedInfrastructure", []]);
    private _roadblockSites = +(missionNamespace getVariable ["MWF_PotentialBaseSites", []]);

    if (_hqSites isEqualTo []) then {
        _hqSites = call _generateHQSites;
        missionNamespace setVariable ["MWF_FixedInfrastructure", _hqSites, true];
    };
    if (_roadblockSites isEqualTo []) then {
        _roadblockSites = call _generateRoadblockSites;
        missionNamespace setVariable ["MWF_PotentialBaseSites", _roadblockSites, true];
    };

    missionNamespace setVariable ["MWF_HQSiteRegistry", _hqSites, true];
    missionNamespace setVariable ["MWF_RoadblockSiteRegistry", _roadblockSites, true];

    ["REFRESH_FIXED_BASES"] call MWF_fnc_spawnManager;

    {
        ["CREATE_BASE", [_x, "ROADBLOCK", [_x, "ROADBLOCK"] call _resolveStableInfrastructureId]] call MWF_fnc_spawnManager;
    } forEach _roadblockSites;

    missionNamespace setVariable ["MWF_InfrastructureBootstrapped", true, true];
    diag_log format ["[MWF SPAWN] Infrastructure bootstrapped. HQ sites: %1 | Roadblock sites: %2", count _hqSites, count _roadblockSites];
};

if (_mode == "REFRESH_FIXED_BASES") exitWith {
    private _fixedBases = +(missionNamespace getVariable ["MWF_FixedInfrastructure", []]);
    private _destroyedHQs = +(missionNamespace getVariable ["MWF_DestroyedHQs", []]);

    {
        private _pos = _x;
        if !([_pos, _destroyedHQs] call _siteMatchesDestroyed) then {
            if !([_pos, 75] call _siteOccupied) then {
                ["CREATE_BASE", [_pos, "HQ", [_pos, "HQ"] call _resolveStableInfrastructureId]] call MWF_fnc_spawnManager;
            };
        };
    } forEach _fixedBases;
};

if (_mode == "CREATE_BASE") exitWith {
    _params params [
        ["_pos", [], [[]]],
        ["_type", "ROADBLOCK", [""]],
        ["_stableId", "", [""]]
    ];

    if !((_pos isEqualType []) && {count _pos >= 2}) exitWith { objNull };
    if !([_pos, 1000, 1500] call _isFarEnoughFromBases) exitWith { objNull };

    private _normalizedType = toUpper _type;
    private _destroyedRegistry = if (_normalizedType == "HQ") then {
        missionNamespace getVariable ["MWF_DestroyedHQs", []]
    } else {
        missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]
    };

    if ([_pos, _destroyedRegistry] call _siteMatchesDestroyed) exitWith { objNull };
    if ([_pos, 75] call _siteOccupied) exitWith { objNull };

    private _composition = objNull;
    if (_normalizedType == "HQ") then {
        _composition = createVehicle ["Land_Cargo_HQ_V1_F", _pos, [], 0, "NONE"];
    } else {
        _composition = createVehicle ["Land_BagBunker_Large_F", _pos, [], 0, "NONE"];
    };

    if (!isNull _composition) then {
        _composition setPosATL _pos;
        _composition allowDamage true;
        if (!isNil "MWF_fnc_infrastructureManager") then {
            ["REGISTER", [_composition, _normalizedType, _stableId]] call MWF_fnc_infrastructureManager;
        };
    };

    diag_log format ["[MWF SPAWN] %1 created at %2 and registered.", _normalizedType, _pos];
    _composition
};
