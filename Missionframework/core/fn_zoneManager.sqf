/*
    Author: Theane using Gemini (AGS Project)
    Description: Advanced Hybrid Zone Manager. 
    Handles auto-detection of map locations, industrial scanning, auto-sizing for small maps,
    manual overrides via Game Logics, and dynamic map markers.
*/

if (!isServer) exitWith {};

// --- 1. HELPER FUNCTIONS: MARKERS & CLEANING ---

// Function to draw markers on the map for players to see
AGS_fnc_createZoneMarker = {
    params ["_logic", "_name", "_pos", "_range", "_type"];
    private _markerName = format ["marker_%1", _logic];
    
    // Create Area Circle
    private _m = createMarker [_markerName, _pos];
    _m setMarkerShape "ELLIPSE";
    _m setMarkerSize [_range, _range];
    _m setMarkerBrush "SolidBorder";
    _m setMarkerColor "ColorOPFOR"; // Red (Enemy) at start
    _m setMarkerAlpha 0.5;

    // Create Text Label (Icon style depends on zone type)
    private _mText = createMarker [format ["text_%1", _logic], _pos];
    _mText setMarkerType "EmptyIcon";
    
    // Custom label based on type
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

// Function to clear terrain (Bulldozer)
AGS_fnc_prepZoneBase = {
    params ["_pos", "_range"];
    private _terrain = nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH", "ROCK", "FOREST BORDER"], _range];
    { _x hideObjectGlobal true; } forEach _terrain;
    diag_log format ["AGS: Cleared %1 terrain objects at %2", count _terrain, _pos];
};

// --- 2. INITIALIZATION & SCANNING ---

private _allZones = [];

// A. SCAN FOR CITIES & VILLAGES
private _mapLocations = nearestLocations [[worldSize/2, worldSize/2, 0], ["NameCityCapital", "NameCity", "NameVillage"], worldSize];

// FAILSAFE: If no Capital exists, find the biggest City to promote
private _hasCapital = count (_mapLocations select {type _x == "NameCityCapital"}) > 0;
if (!_hasCapital && count _mapLocations > 0) then {
    _mapLocations = [_mapLocations, [], {type _x}, "DESCEND"] call BIS_fnc_sortBy;
    (_mapLocations select 0) setVariable ["AGS_isHonoraryCapital", true];
};

{
    private _locPos = locationPosition _x;
    private _locName = text _x;
    private _locType = type _x;

    // AUTO-SIZE (Calculates distance to neighbors to avoid clipping on small maps)
    private _nearby = _mapLocations - [_x];
    private _dist = 1000;
    if (count _nearby > 0) then {
        private _closest = [_nearby, _locPos] call BIS_fnc_nearestPosition;
        _dist = (_locPos distance (locationPosition _closest)) * 0.45;
    };
    private _finalRange = (_dist max 150) min 500;

    private _logic = "Logic" createVehicleLocal _locPos;
    
    // Determine Type
    private _type = "Village";
    if (_locType == "NameCity" || _locType == "NameCityCapital" || (_x getVariable ["AGS_isHonoraryCapital", false])) then {
        _type = "City";
        if (_locType == "NameCityCapital" || (_x getVariable ["AGS_isHonoraryCapital", false])) then { _type = "Factory"; }; // Capitals work as Factories for income
    };

    _logic setVariable ["AGS_zoneType", _type, true];
    _logic setVariable ["AGS_zoneName", _locName, true];
    _logic setVariable ["AGS_zoneRange", _finalRange, true];
    _logic setVariable ["AGS_isCaptured", false, true];

    [_logic, _locName, _locPos, _finalRange, _type] call AGS_fnc_createZoneMarker;
    _allZones pushBack _logic;
} forEach _mapLocations;

// B. SCAN FOR INDUSTRIAL BUILDINGS (Factories)
private _indClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_PowerStation_01_main_F", "Land_i_Shed_Ind_F"];
private _industrials = nearestObjects [[worldSize/2, worldSize/2, 0], _indClasses, worldSize];
private _factoryPoints = [];

{
    private _pos = getPos _x;
    // Ensure we don't create multiple zones for the same industrial park
    if ({_pos distance _x < 600} count _factoryPoints == 0) then {
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

// C. MANUAL OVERRIDES (KP-Style Game Logics)
private _manuals = entities "Logic" select { !isNil {_x getVariable "AGS_zoneType"} };
{
    _allZones pushBackUnique _x;
    private _r = _x getVariable ["AGS_zoneRange", 300];
    private _n = _x getVariable ["AGS_zoneName", "Military Outpost"];
    private _t = _x getVariable "AGS_zoneType";
    
    [_x, _n, getPos _x, _r, _t] call AGS_fnc_createZoneMarker;
    [getPos _x, _r] spawn AGS_fnc_prepZoneBase;
} forEach _manuals;

missionNamespace setVariable ["AGS_all_mission_zones", _allZones, true];
diag_log format ["AGS Zone Manager: Successfully initialized %1 zones.", count _allZones];

// --- 3. MONITOR LOOP (Capture Logic) ---
[] spawn {
    while {true} do {
        uiSleep 15; 
        private _capturedList = missionNamespace getVariable ["AGS_captured_zones_list", []];
        private _all = missionNamespace getVariable ["AGS_all_mission_zones", []];

        {
            if !(_x getVariable ["AGS_isCaptured", false]) then {
                private _pos = getPos _x;
                private _range = _x getVariable ["AGS_zoneRange", 400];
                
                // Only check for enemies if players are actually present
                if (count (allPlayers select {alive _x && (_x distance _pos) < _range}) > 0) then {
                    private _enemies = count (allUnits select {side _x == east && alive _x && _x distance _pos < _range});
                    
                    if (_enemies == 0) then {
                        _x setVariable ["AGS_isCaptured", true, true];
                        _capturedList pushBackUnique _x;
                        missionNamespace setVariable ["AGS_captured_zones_list", _capturedList, true];
                        
                        // Turn marker Blue/Green
                        (_x getVariable ["AGS_zoneMarker", ""]) setMarkerColor "ColorBLUFOR";
                        
                        [format ["Area Secured: %1", _x getVariable "AGS_zoneName"]] remoteExec ["systemChat", 0];
                        diag_log format ["AGS: %1 captured!", _x getVariable "AGS_zoneName"];
                    };
                };
            };
        } forEach _all;
    };
};
