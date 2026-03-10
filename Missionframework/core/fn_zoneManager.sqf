/*
    Author: Theane using Gemini (AGS Project)
    Description: Advanced Hybrid Zone Manager. 
    Fixed: Added Collision Detection to prevent double-zones when using manual logics.
*/

if (!isServer) exitWith {};

// --- 1. HELPERS ---

AGS_fnc_createZoneMarker = {
    params ["_logic", "_name", "_pos", "_range", "_type"];
    private _markerName = format ["marker_%1", _logic];
    private _m = createMarker [_markerName, _pos];
    _m setMarkerShape "ELLIPSE";
    _m setMarkerSize [_range, _range];
    _m setMarkerBrush "SolidBorder";
    _m setMarkerColor "ColorOPFOR";
    _m setMarkerAlpha 0.5;

    private _mText = createMarker [format ["text_%1", _logic], _pos];
    _mText setMarkerType "EmptyIcon";
    private _label = switch (_type) do {
        case "Factory": { format ["Factory: %1", _name] };
        case "City":    { format ["City: %1", _name] };
        case "Outpost": { format ["Military: %1", _name] };
        default         { _name };
    };
    _mText setMarkerText _label;
    _mText setMarkerColor "ColorBlack";
    _logic setVariable ["AGS_zoneMarker", _markerName, true];
};

AGS_fnc_prepZoneBase = {
    params ["_pos", "_range"];
    private _terrain = nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH", "ROCK"], _range];
    { _x hideObjectGlobal true; } forEach _terrain;
};

// --- 2. INITIALIZATION ---

private _allZones = [];

// A. PRE-SCAN MANUAL LOGICS (We do this first to know where NOT to auto-scan)
private _manuals = entities "Logic" select { !isNil {_x getVariable "AGS_zoneType"} };

// B. SCAN MAP LOCATIONS
private _mapLocations = nearestLocations [[worldSize/2, worldSize/2, 0], ["NameCityCapital", "NameCity", "NameVillage"], worldSize];

{
    private _locPos = locationPosition _x;
    private _locName = text _x;
    
    // --- COLLISION CHECK ---
    // If a manual logic exists within 300m, skip the auto-generation for this city
    private _isManualNearby = { (_x distance _locPos) < 300 } count _manuals > 0;

    if (!_isManualNearby) then {
        private _nearby = _mapLocations - [_x];
        private _dist = 1000;
        if (count _nearby > 0) then {
            private _closest = [_nearby, _locPos] call BIS_fnc_nearestPosition;
            _dist = (_locPos distance (locationPosition _closest)) * 0.45;
        };
        private _finalRange = (_dist max 150) min 500;

        private _logic = "Logic" createVehicleLocal _locPos;
        private _type = "Village";
        if (type _x == "NameCity" || type _x == "NameCityCapital") then {
            _type = "City";
            if (type _x == "NameCityCapital") then { _type = "Factory"; };
        };

        _logic setVariable ["AGS_zoneType", _type, true];
        _logic setVariable ["AGS_zoneName", _locName, true];
        _logic setVariable ["AGS_zoneRange", _finalRange, true];
        _logic setVariable ["AGS_isCaptured", false, true];

        [_logic, _locName, _locPos, _finalRange, _type] call AGS_fnc_createZoneMarker;
        _allZones pushBack _logic;
    } else {
        diag_log format ["AGS: Skipping auto-zone for %1, manual override detected.", _locName];
    };
} forEach _mapLocations;

// C. SCAN FOR INDUSTRIAL (Factories)
private _indClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_PowerStation_01_main_F"];
private _industrials = nearestObjects [[worldSize/2, worldSize/2, 0], _indClasses, worldSize];
private _factoryPoints = [];

{
    private _pos = getPos _x;
    // Check collision with both manual logics AND already created auto-zones
    private _isOccupied = { (_x distance _pos) < 600 } count (_manuals + _allZones) > 0;

    if (!_isOccupied) then {
        _factoryPoints pushBack _pos;
        private _logic = "Logic" createVehicleLocal _pos;
        _logic setVariable ["AGS_zoneType", "Factory", true];
        _logic setVariable ["AGS_zoneName", "Industrial Complex", true];
        _logic setVariable ["AGS_zoneRange", 300, true];
        _logic setVariable ["AGS_isCaptured", false, true];

        [_logic, "Industrial Complex", _pos, 300, "Factory"] call AGS_fnc_createZoneMarker;
        [_pos, 300] spawn AGS_fnc_prepZoneBase;
        _allZones pushBackUnique _logic;
    };
} forEach _industrials;

// D. APPLY MANUAL LOGICS (Theane's custom placements)
{
    _allZones pushBackUnique _x;
    private _r = _x getVariable ["AGS_zoneRange", 300];
    private _n = _x getVariable ["AGS_zoneName", "Military Outpost"];
    private _t = _x getVariable "AGS_zoneType";
    [_x, _n, getPos _x, _r, _t] call AGS_fnc_createZoneMarker;
    [getPos _x, _r] spawn AGS_fnc_prepZoneBase;
} forEach _manuals;

missionNamespace setVariable ["AGS_all_mission_zones", _allZones, true];

// --- 3. MONITOR LOOP ---
[] spawn {
    private _spawnDist = ["AGS_Param_SpawnDist", 1000] call BIS_fnc_getParamValue;
    while {true} do {
        uiSleep 15; 
        private _capturedList = missionNamespace getVariable ["AGS_captured_zones_list", []];
        {
            if !(_x getVariable ["AGS_isCaptured", false]) then {
                private _pos = getPos _x;
                private _range = _x getVariable ["AGS_zoneRange", 400];
                if (count (allPlayers select {alive _x && (_x distance _pos) < _spawnDist}) > 0) then {
                    private _enemies = count (allUnits select {side _x == east && alive _x && _x distance _pos < _range});
                    if (_enemies == 0) then {
                        _x setVariable ["AGS_isCaptured", true, true];
                        _capturedList pushBackUnique _x;
                        missionNamespace setVariable ["AGS_captured_zones_list", _capturedList, true];
                        (_x getVariable ["AGS_zoneMarker", ""]) setMarkerColor "ColorBLUFOR";
                        [format ["Area Secured: %1", _x getVariable "AGS_zoneName"]] remoteExec ["systemChat", 0];
                    };
                };
            };
        } forEach (missionNamespace getVariable ["AGS_all_mission_zones", []]);
    };
};
