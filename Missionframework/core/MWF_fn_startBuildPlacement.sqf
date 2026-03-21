/*
    Author: Theane / ChatGPT
    Function: MWF_fn_startBuildPlacement
    Project: Military War Framework

    Description:
    Handles client-side build placement with ghost preview and confirmation.
    Physical base-upgrade structures use the same interrupt-safe local placement
    state model as vehicle ghost placement so damage can cleanly cancel them.
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

[] call MWF_fnc_cleanupVehiclePlacement;
missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
missionNamespace setVariable ["MWF_BuildPlacement_Aborted", false];
missionNamespace setVariable ["MWF_BuildPlacement_Rotation", 0];
missionNamespace setVariable ["MWF_BuildPlacement_Class", _className];
missionNamespace setVariable ["MWF_BuildPlacement_Price", _price];
missionNamespace setVariable ["MWF_BuildPlacement_Name", _displayName];

private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setAlpha 0.6;
_ghost setVehicleLock "LOCKED";
_ghost disableCollisionWith player;

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "BUILD_PLACEMENT"];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _price];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", true];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement active."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];

private _confirmAction = player addAction [
    format ["<t color='#00FF66'>Confirm Build: %1 (%2 Supplies)</t>", _displayName, _price],
    {
        missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", true];
    },
    nil,
    100,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _cancelAction = player addAction [
    "<t color='#FF5555'>Cancel Construction</t>",
    {
        missionNamespace setVariable ["MWF_BuildPlacement_Aborted", true];
    },
    nil,
    99,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];

[
    ["BUILD PLACEMENT", format ["Ghost build active for %1. Confirm or cancel from the action menu. Use Q/E to rotate.", _displayName]],
    "info"
] call MWF_fnc_showNotification;

while {
    (missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false]) &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Aborted", false]) &&
    alive player
} do {
    private _rotation = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", 0];
    if (inputAction "User1" > 0) then { _rotation = _rotation + 2; };
    if (inputAction "User2" > 0) then { _rotation = _rotation - 2; };
    missionNamespace setVariable ["MWF_BuildPlacement_Rotation", _rotation];

    private _pos = player modelToWorld [0, 10, 0];
    _ghost setPosATL _pos;
    _ghost setDir (getDir player + _rotation);

    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL _ghost];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir _ghost];

    uiSleep 0.01;
};

private _confirmed = missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false];
private _aborted = missionNamespace getVariable ["MWF_BuildPlacement_Aborted", false];
private _rotation = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", 0];
private _interrupted = !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) && {!_confirmed} && {!_aborted};

[] call MWF_fnc_cleanupVehiclePlacement;

if (_confirmed) then {
    private _finalPos = player modelToWorld [0, 10, 0];
    private _finalDir = getDir player + _rotation;

    [_className, _finalPos, _finalDir, _price, player] remoteExec ["MWF_fnc_finalizeBuild", 2];

    hint format ["Build request submitted: %1", _displayName];
    diag_log format ["[MWF Build] Player submitted placement of %1 at %2 (client hint cost %3).", _className, _finalPos, _price];
} else {
    if (_aborted) then {
        hint "Construction aborted.";
        diag_log format ["[MWF Build] Player aborted placement of %1.", _className];
    } else {
        if (_interrupted) then {
            diag_log format ["[MWF Build] Player placement of %1 was interrupted.", _className];
        } else {
            diag_log format ["[MWF Build] Placement loop for %1 ended without confirmation.", _className];
        };
    };
};
