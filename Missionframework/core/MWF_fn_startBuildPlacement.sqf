/*
    Author: Theane / ChatGPT
    Function: MWF_fn_startBuildPlacement
    Project: Military War Framework

    Description:
    Handles client-side build placement with ghost preview and confirmation.
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]]
];

if (_className isEqualTo "") exitWith {};
if (!hasInterface) exitWith {};

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith {
    systemChat format ["Build failed: unknown class %1.", _className];
};

private _displayName = getText (_cfg >> "displayName");
if (_displayName isEqualTo "") then { _displayName = _className; };

// 1. Create the Ghost locally
private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost setAlpha 0.6;
_ghost setVehicleLock "LOCKED";

// Disable collision with the player so it doesn't catapult you
_ghost disableCollisionWith player;

private _confirmed = false;
private _aborted = false;
private _rotation = 0;

// 2. Add the scroll menu actions (Confirm/Cancel)
private _actionConfirm = player addAction ["<t color='#00ff00'>Confirm Placement</t>", { _confirmed = true; }, [], 100, false, false, "", "true"];
private _actionCancel = player addAction ["<t color='#ff0000'>Cancel Construction</t>", { _aborted = true; }, [], 99, false, false, "", "true"];

hint format ["PLACEMENT MODE ACTIVE
%1
Use Q/E to rotate the object.", _displayName];

// 3. Movement Loop
while {!_confirmed && !_aborted && alive player} do {
    // Rotation input (using Q and E keys)
    if (inputAction "User1" > 0) then { _rotation = _rotation + 2; }; // Q
    if (inputAction "User2" > 0) then { _rotation = _rotation - 2; }; // E

    // Position the ghost 10 meters in front of the player
    private _pos = player modelToWorld [0, 10, 0];
    _ghost setPosATL _pos;
    _ghost setDir (getDir player + _rotation);

    uiSleep 0.01;
};

// 4. Cleanup Actions
player removeAction _actionConfirm;
player removeAction _actionCancel;
deleteVehicle _ghost;

// 5. Finalize
if (_confirmed) then {
    private _finalPos = player modelToWorld [0, 10, 0];
    private _finalDir = getDir player + _rotation;

    // Call server to validate, charge, and spawn the real object
    [_className, _finalPos, _finalDir, _price, player] remoteExec ["MWF_fnc_finalizeBuild", 2];

    hint format ["Build request submitted: %1", _displayName];
    diag_log format ["[MWF Build] Player submitted placement of %1 at %2 (client hint cost %3).", _className, _finalPos, _price];
} else {
    hint "Construction Aborted.";
    diag_log format ["[MWF Build] Player aborted placement of %1.", _className];
};
