/*
    Author: Theane using Gemini (AGS Project)
    Description: Hybrid Zone Manager with Auto-Cleaning, Base Spawning, and Map Markers.
*/

if (!isServer) exitWith {};

// --- 1. HELPER: CREATE MAP MARKER ---
AGS_fnc_createZoneMarker = {
    params ["_logic", "_name", "_pos", "_range"];
    private _markerName = format ["marker_%1", _logic];
    
    // Create Area Circle
    private _m = createMarker [_markerName, _pos];
    _m setMarkerShape "ELLIPSE";
    _m setMarkerSize [_range, _range];
    _m setMarkerBrush "SolidBorder";
    _m setMarkerColor "ColorOPFOR"; // Red by default
    _m setMarkerAlpha 0.5;

    // Create Text Label
    private _mText = createMarker [format ["text_%1", _logic], _pos];
    _mText setMarkerType "EmptyIcon";
    _mText setMarkerText _name;
    _mText setMarkerColor "ColorBlack";

    _logic setVariable ["AGS_zoneMarker", _markerName, true];
};

// --- 2. HELPER: CLEAN AND PREP ---
AGS_fnc_prepZoneBase = {
    params ["_pos", "_range", "_type"];
    private _terrainStuff = nearestTerrainObjects [_pos, ["TREE", "SMALL TREE", "BUSH", "ROCK"], _range];
    { _x hideObjectGlobal true; } forEach _terrainStuff;
};

// --- 3. SCAN AND INITIALIZE ---
private _allZones = [];
private _mapLocations = nearestLocations [[0,0,0], ["NameCityCapital", "NameCity", "NameVillage"], 50000];

{
    private _locPos = locationPosition _x;
    private _locName = text _x;
    private _logic = "Logic" createVehicleLocal _locPos;
    private _type = if (type _x == "NameVillage") then {"Village"} else {"City"};

    _logic setVariable ["AGS_zoneType", _type, true];
    _logic setVariable ["AGS_zoneName", _locName, true];
    _logic setVariable ["AGS_zoneRange", 400, true];
    _logic setVariable ["AGS_isCaptured", false, true];

    // Create the marker
    [_logic, _locName, _locPos, 400] call AGS_fnc_createZoneMarker;
    _allZones pushBack _logic;
} forEach _mapLocations;

// Add Manual Logics (KP-Style)
private _manualLogics = entities "Logic" select { !isNil {_x getVariable "AGS_zoneType"} };
{
    _allZones pushBackUnique _x;
    private _pos = getPos _x;
    private _range = _x getVariable ["AGS_zoneRange", 300];
    private _name = _x getVariable ["AGS_zoneName", "Military Outpost"];

    [_x, _name, _pos, _range] call AGS_fnc_createZoneMarker;
    [_pos, _range, _x getVariable "AGS_zoneType"] spawn AGS_fnc_prepZoneBase;
} forEach _manualLogics;

missionNamespace setVariable ["AGS_all_mission_zones", _allZones, true];

// --- 4. MONITOR LOOP ---
[] spawn {
    while {true} do {
        uiSleep 15; 
        private _captured = missionNamespace getVariable ["AGS_captured_zones_list", []];
        {
            if !(_x getVariable ["AGS_isCaptured", false]) then {
                private _pos = getPos _x;
                private _range = _x getVariable ["AGS_zoneRange", 400];
                
                if (count (allPlayers select {alive _x && (_x distance _pos) < _range}) > 0) then {
                    private _enemies = count (allUnits select {side _x == east && alive _x && (_x distance _pos) < _range});
                    if (_enemies == 0) then {
                        _x setVariable ["AGS_isCaptured", true, true];
                        _captured pushBackUnique _x;
                        missionNamespace setVariable ["AGS_captured_zones_list", _captured, true];

                        // Update Marker to Green/Blue
                        private _mName = _x getVariable ["AGS_zoneMarker", ""];
                        _mName setMarkerColor "ColorBLUFOR";
                        
                        [format ["Area Secured: %1", _x getVariable "AGS_zoneName"]] remoteExec ["systemChat", 0];
                    };
                };
            };
        } forEach (missionNamespace getVariable ["AGS_all_mission_zones", []]);
    };
};
