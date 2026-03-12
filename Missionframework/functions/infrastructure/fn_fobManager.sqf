/*
    Author: Theane using gemini
    Function: KPIN_fnc_fobManager
    Description: 
    Handles the deployment and repacking of Forward Operating Bases (FOB).
    Retrieves classnames and compositions from the active Blufor preset.
*/

if (!isServer) exitWith {};

params [["_mode", "DEPLOY"], ["_params", []]];

// --- MODE: DEPLOY ---
// Converts a Truck or Box into a static FOB
if (_mode == "DEPLOY") exitWith {
    _params params ["_sourceObject", "_player"];

    if (isNull _sourceObject) exitWith {};

    private _pos = getPosATL _sourceObject;
    private _dir = getDir _sourceObject;
    private _type = _sourceObject getVariable ["KPIN_FOB_Type", "TRUCK"]; // TRUCK or BOX

    // 1. Get the FOB building/composition from the preset
    private _fobClass = missionNamespace getVariable ["KPIN_Preset_FOB_Building", "Land_Cargo_HQ_V1_F"];
    
    // 2. Cleanup source
    deleteVehicle _sourceObject;

    // 3. Spawn the FOB
    private _fob = createVehicle [_fobClass, _pos, [], 0, "NONE"];
    _fob setDir _dir;
    _fob setVariable ["KPIN_isFOB", true, true];
    _fob setVariable ["KPIN_FOB_OriginType", _type, true];

    // 4. Update Global Persistence
    private _fobPositions = missionNamespace getVariable ["KPIN_FOB_Positions", []];
    _fobPositions pushBack [_pos, _type]; // Store position and what it was (Truck/Box)
    missionNamespace setVariable ["KPIN_FOB_Positions", _fobPositions, true];

    // 5. Add Marker
    private _m = createMarker [format ["fob_marker_%1", floor(random 10000)], _pos];
    _m setMarkerType "b_hq";
    _m setMarkerText format ["FOB %1", count _fobPositions];
    _m setMarkerColor "ColorBlue";

    // Save state
    ["SAVE"] call KPIN_fnc_saveManager;

    diag_log format ["[KPIN FOB]: FOB deployed at %1 from a %2.", _pos, _type];
    
    ["KPIN_Notify", ["FOB Established", "Forward Operating Base is now operational."]] call CBA_fnc_globalEvent;
};

// --- MODE: REPACK ---
// Converts a static FOB back into a Truck or Box
if (_mode == "REPACK") exitWith {
    _params params ["_fobObject"];

    if (isNull _fobObject) exitWith {};

    private _pos = getPosATL _fobObject;
    private _dir = getDir _fobObject;
    private _type = _fobObject getVariable ["KPIN_FOB_OriginType", "TRUCK"];

    // 1. Get the correct classname from the preset based on the origin type
    private _repackClass = "";
    if (_type == "TRUCK") then {
        _repackClass = missionNamespace getVariable ["KPIN_Preset_FOB_Truck", "B_Truck_01_box_F"];
    } else {
        _repackClass = missionNamespace getVariable ["KPIN_Preset_FOB_Box", "B_Slingload_01_Cargo_F"];
    };

    // 2. Cleanup FOB
    deleteVehicle _fobObject;

    // 3. Spawn the original container
    private _container = createVehicle [_repackClass, _pos, [], 0, "NONE"];
    _container setDir _dir;
    _container setVariable ["KPIN_FOB_Type", _type, true];

    // 4. Remove from Global Persistence
    private _fobPositions = missionNamespace getVariable ["KPIN_FOB_Positions", []];
    // Filter out this specific position (using a small distance check for safety)
    _fobPositions = _fobPositions select { (_x select 0) distance _pos > 5 };
    missionNamespace setVariable ["KPIN_FOB_Positions", _fobPositions, true];

    // 5. Update Markers (Simplified: Refresh all FOB markers)
    { deleteMarker _x; } forEach (allMapMarkers select { _x find "fob_marker_" == 0 });
    {
        private _m = createMarker [format ["fob_marker_%1", _forEachIndex], _x select 0];
        _m setMarkerType "b_hq";
        _m setMarkerText format ["FOB %1", _forEachIndex + 1];
        _m setMarkerColor "ColorBlue";
    } forEach _fobPositions;

    // Save state
    ["SAVE"] call KPIN_fnc_saveManager;

    diag_log format ["[KPIN FOB]: FOB at %1 repacked into %2.", _pos, _type];
};
