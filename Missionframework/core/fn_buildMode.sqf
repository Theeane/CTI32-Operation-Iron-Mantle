/*
    Author: Theane (AGS Project)
    Description: Handles the ghost-preview and placement of construction objects.
    Language: English
*/

params ["_className", "_price"];

// 1. Check if the player has enough supplies
private _currentSupplies = missionNamespace getVariable ["AGS_res_supplies", 0];
if (_currentSupplies < _price) exitWith { 
    hint parseText "<t color='#ff0000'>Not enough Supplies!</t>"; 
};

// 2. Create the "Ghost" object (local to the player)
private _ghost = _className createVehicleLocal [0,0,0];
_ghost setAllowDamage false;
_ghost setAlpha 0.6; // Make it semi-transparent

private _confirmed = false;
private _abort = false;

hint "Use [LMB] to Place, [RMB] to Cancel, [Q/E] to Rotate.";

// 3. Placement Loop
while {!_confirmed && !_abort && alive player} do {
    private _pos = player modelToWorld [0, 5, 0]; // Place 5m in front of player
    _ghost setPos _pos;
    _ghost setDir (getDir player);

    // Check for placement confirmation (Example using action keys)
    if (inputAction "DefaultAction" > 0) then { _confirmed = true; }; // Left Click
    if (inputAction "ReloadMagazine" > 0) then { _abort = true; };   // Right Click (Map to your preference)
    
    uiSleep 0.01;
};

// 4. Finalize Placement
deleteVehicle _ghost;

if (_confirmed) then {
    // Deduct cost
    [(_price * -1), "SUPPLIES"] call AGS_fnc_addResource;
    
    // Spawn the real object (Global)
    private _finalPos = player modelToWorld [0, 5, 0];
    private _realObject = _className createVehicle _finalPos;
    
    // Add the "Unpack FOB" action if it's the FOB Container
    if (_className == "B_Slingload_01_Cargo_F") then {
        [_realObject] remoteExec ["AGS_fnc_setupFOBAction", 0, true];
    };

    hint "Object Deployed.";
} else {
    hint "Construction Aborted.";
};
