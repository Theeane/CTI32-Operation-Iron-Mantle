/*
    Author: Theane (AGS Project)
    Description: Spawns the physical objects after placement is confirmed.
    Language: English
*/

if (!isServer) exitWith {};
params ["_pos", "_dir"];

private _compositionData = [
    ["Land_Cargo_HQ_V1_F", [0, 0, 0], 0],
    ["Land_HBarrier_5_F", [7, 7, 0], 45],
    ["Land_HBarrier_5_F", [-7, 7, 0], 315],
    ["Land_BagBunker_Small_F", [0, -10, 0], 180]
];

{
    _x params ["_type", "_offset", "_dirOffset"];
    private _rotatedOffset = [_offset, -_dir] call BIS_fnc_rotateVector2D;
    private _finalPos = _pos vectorAdd _rotatedOffset;

    private _obj = createVehicle [_type, _finalPos, [], 0, "CAN_COLLIDE"];
    _obj setDir (_dir + _dirOffset);
    _obj setPosATL _finalPos;
    
    // If it's the HQ building, add the interaction to log back in/build
    if (_type == "Land_Cargo_HQ_V1_F") then {
        [_obj] remoteExec ["AGS_fnc_setupInteractions", 0, true];
    };
    
} forEach _compositionData;

// Update the global FOB list
private _fobs = missionNamespace getVariable ["AGS_active_fobs", []];
_fobs pushBack _pos;
missionNamespace setVariable ["AGS_active_fobs", _fobs, true];

// Move to next mission stage (Supply Run)
[2] spawn AGS_fnc_generateInitialMission;
