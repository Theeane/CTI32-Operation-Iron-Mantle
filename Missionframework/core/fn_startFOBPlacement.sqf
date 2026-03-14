/*
    Author: Theane / ChatGPT
    Function: fn_startFOBPlacement
    Project: Military War Framework

    Description:
    Handles start f o b placement for the core framework layer.
*/

params ["_pos"];

// 1. Define the composition offsets (Same as your fn_spawnFOBComposition)
private _compositionData = [
    ["Land_Cargo_HQ_V1_F", [0, 0, 0], 0],
    ["Land_HBarrier_5_F", [7, 7, 0], 45],
    ["Land_HBarrier_5_F", [-7, 7, 0], 315],
    ["Land_BagBunker_Small_F", [0, -10, 0], 180]
];

// 2. Create local ghosts
private _ghosts = [];
{
    _x params ["_type", "_offset", "_dirOffset"];
    private _g = _type createVehicleLocal [0,0,0];
    _g setAllowDamage false;
    _g setAlpha 0.5; // Transparent ghost look
    _ghosts pushBack [_g, _offset, _dirOffset];
} forEach _compositionData;

private _confirmed = false;
private _abort = false;
private _currentDir = 0;

hint parseText "<t color='#00ff00'>FOB PLACEMENT MODE</t><br/>[LMB/Space]: Place<br/>[RMB/Esc]: Cancel<br/>[Q/E]: Rotate";

// 3. Movement Loop
while {!_confirmed && !_abort && alive player} do {
    // Get position in front of player
    private _centerPos = screenToWorld [0.5, 0.5]; // Or player modelToWorld [0, 15, 0]
    
    // Rotate using Q/E
    if (inputAction "User1" > 0) then { _currentDir = _currentDir + 2; }; // Q
    if (inputAction "User2" > 0) then { _currentDir = _currentDir - 2; }; // E

    // Update ghost positions
    {
        _x params ["_obj", "_offset", "_dirOffset"];
        private _rotatedOffset = [_offset, -_currentDir] call BIS_fnc_rotateVector2D;
        private _finalPos = _centerPos vectorAdd _rotatedOffset;
        
        _obj setPosATL _finalPos;
        _obj setDir (_currentDir + _dirOffset);
    } forEach _ghosts;

    // Check for placement
    if (inputAction "DefaultAction" > 0) then { _confirmed = true; };
    if (inputAction "ReloadMagazine" > 0) then { _abort = true; };

    uiSleep 0.01;
};

// 4. Cleanup and Finalize
{ (_x select 0) deleteVehicle (_x select 0); } forEach _ghosts;

if (_confirmed) then {
    private _finalCenter = screenToWorld [0.5, 0.5];
    
    // Spawn real objects on the server
    [_finalCenter, _currentDir] remoteExec ["MWF_fnc_spawnFOBComposition", 2];
    
    // Unlock Build Mode Globally
    missionNamespace setVariable ["MWF_system_active", true, true];
    
    hint "FOB Established!";
} else {
    hint "Placement Aborted. Container returned.";
    // Logic to spawn the container back if aborted
};
