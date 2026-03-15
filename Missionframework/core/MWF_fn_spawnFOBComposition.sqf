/*
    Author: Theane / ChatGPT
    Function: MWF_fn_spawnFOBComposition
    Project: Military War Framework

    Description:
    Handles FOB composition spawning for the core framework layer.
*/

if (!isServer) exitWith {};

params [
    ["_pos", [0, 0, 0], [[]], 3],
    ["_dir", 0, [0]]
];

// Define FOB base layout: [Classname, Offset [x,y,z], Direction Offset]
private _compositionData = [
    ["Land_Cargo_HQ_V1_F", [0, 0, 0], 0],           // The Main HQ Building
    ["Land_HBarrier_5_F", [7, 7, 0], 45],           // Defensive Wall
    ["Land_HBarrier_5_F", [-7, 7, 0], 315],         // Defensive Wall
    ["Land_BagBunker_Small_F", [0, -10, 0], 180],   // Guard Post
    ["Land_PortableLight_Single_F", [5, -5, 0], 0]  // Base Lighting
];

{
    _x params ["_type", "_offset", "_dirOffset"];
    
    // Calculate global position based on rotation
    private _rotatedOffset = [_offset, -_dir] call BIS_fnc_rotateVector2D;
    private _finalPos = _pos vectorAdd _rotatedOffset;

    private _obj = createVehicle [_type, _finalPos, [], 0, "CAN_COLLIDE"];
    _obj setDir (_dir + _dirOffset);
    _obj setPosATL _finalPos;
    
    // CRITICAL: If this is the HQ building, initialize the FOB Terminal actions
    if (_type == "Land_Cargo_HQ_V1_F") then {
        [_obj] remoteExec ["MWF_fnc_setupFOBInteractions", 0, true];
    };
    
} forEach _compositionData;

// Register the new FOB position globally
private _fobs = missionNamespace getVariable ["MWF_active_fobs", []];
_fobs pushBack _pos;
missionNamespace setVariable ["MWF_active_fobs", _fobs, true];

// Progress to the next Mission Stage (Supply Run)
[2] remoteExec ["MWF_fnc_generateInitialMission", 2];

["STRATEGIC: FOB Established. Logistics network is now active."] remoteExec ["systemChat", 0];

diag_log format ["[MWF FOB] FOB composition spawned at %1 with direction %2. Total active FOBs: %3.", _pos, _dir, count (missionNamespace getVariable ["MWF_active_fobs", []])];