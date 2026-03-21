/*
    Author: Theane / ChatGPT
    Function: MWF_fn_startBuildPlacement
    Project: Military War Framework

    Description:
    Handles client-side build placement with ghost preview and confirmation.
    Uses missionNamespace state so damage-interrupt cleanup can safely abort the flow.
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]]
];

if (_className isEqualTo "") exitWith { false };
if (!hasInterface) exitWith { false };

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith {
    systemChat format ["Build failed: unknown class %1.", _className];
    false
};

private _displayName = getText (_cfg >> "displayName");
if (_displayName isEqualTo "") then { _displayName = _className; };

private _cleanup = {
    private _ghostLocal = missionNamespace getVariable ["MWF_BuildPlacement_Ghost", objNull];
    if (!isNull _ghostLocal) then {
        deleteVehicle _ghostLocal;
    };

    private _confirmActionLocal = missionNamespace getVariable ["MWF_BuildPlacement_ConfirmAction", -1];
    if (_confirmActionLocal >= 0) then {
        player removeAction _confirmActionLocal;
    };

    private _cancelActionLocal = missionNamespace getVariable ["MWF_BuildPlacement_CancelAction", -1];
    if (_cancelActionLocal >= 0) then {
        player removeAction _cancelActionLocal;
    };

    missionNamespace setVariable ["MWF_BuildPlacement_Active", false];
    missionNamespace setVariable ["MWF_BuildPlacement_Ghost", objNull];
    missionNamespace setVariable ["MWF_BuildPlacement_Class", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_Price", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_DisplayName", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_Rotation", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_LastDir", nil];
    missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
    missionNamespace setVariable ["MWF_BuildPlacement_Aborted", false];
    missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", false];
    missionNamespace setVariable ["MWF_BuildPlacement_InterruptReason", ""]; 
    missionNamespace setVariable ["MWF_BuildPlacement_ConfirmAction", -1];
    missionNamespace setVariable ["MWF_BuildPlacement_CancelAction", -1];
    if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "BUILD_PLACEMENT") then {
        missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
    };
    true
};

call _cleanup;

private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setAlpha 0.6;
_ghost setVehicleLock "LOCKED";
_ghost disableCollisionWith player;

missionNamespace setVariable ["MWF_BuildPlacement_Active", true];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "BUILD_PLACEMENT"];
missionNamespace setVariable ["MWF_BuildPlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_BuildPlacement_Class", _className];
missionNamespace setVariable ["MWF_BuildPlacement_Price", _price];
missionNamespace setVariable ["MWF_BuildPlacement_DisplayName", _displayName];
missionNamespace setVariable ["MWF_BuildPlacement_Rotation", getDir player];
missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", player modelToWorld [0, 10, 0]];
missionNamespace setVariable ["MWF_BuildPlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
missionNamespace setVariable ["MWF_BuildPlacement_Aborted", false];
missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", false];
missionNamespace setVariable ["MWF_BuildPlacement_InterruptReason", ""];

private _actionConfirm = player addAction [
    format ["<t color='#00ff00'>Confirm Placement: %1</t>", _displayName],
    { missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", true]; },
    nil,
    100,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"
];

private _actionCancel = player addAction [
    "<t color='#ff0000'>Cancel Construction</t>",
    {
        missionNamespace setVariable ["MWF_BuildPlacement_Aborted", true];
        if ((missionNamespace getVariable ["MWF_BuildPlacement_InterruptReason", ""]) isEqualTo "") then {
            missionNamespace setVariable ["MWF_BuildPlacement_InterruptReason", "Construction aborted."];
        };
    },
    nil,
    99,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"
];

missionNamespace setVariable ["MWF_BuildPlacement_ConfirmAction", _actionConfirm];
missionNamespace setVariable ["MWF_BuildPlacement_CancelAction", _actionCancel];

hint format ["PLACEMENT MODE ACTIVE
%1
Use Q/E or turn keys to rotate the object.", _displayName];

while {
    missionNamespace getVariable ["MWF_BuildPlacement_Active", false] &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false]) &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Aborted", false]) &&
    alive player
} do {
    private _rotation = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", getDir player];
    if ((inputAction "User1" > 0) || {(inputAction "TurnLeft" > 0)}) then { _rotation = _rotation - 2; };
    if ((inputAction "User2" > 0) || {(inputAction "TurnRight" > 0)}) then { _rotation = _rotation + 2; };
    missionNamespace setVariable ["MWF_BuildPlacement_Rotation", _rotation];

    private _pos = player modelToWorld [0, 10, 0];
    _ghost setPosATL _pos;
    _ghost setDir _rotation;

    missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", _pos];
    missionNamespace setVariable ["MWF_BuildPlacement_LastDir", _rotation];

    uiSleep 0.02;
};

private _confirmed = missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false];
private _aborted = missionNamespace getVariable ["MWF_BuildPlacement_Aborted", false] || {!alive player};
private _interruptReason = missionNamespace getVariable ["MWF_BuildPlacement_InterruptReason", "Construction aborted."];
private _finalPos = + (missionNamespace getVariable ["MWF_BuildPlacement_LastPosATL", player modelToWorld [0, 10, 0]]);
private _finalDir = missionNamespace getVariable ["MWF_BuildPlacement_LastDir", getDir player];

call _cleanup;

if (_confirmed && !_aborted && alive player) then {
    [_className, _finalPos, _finalDir, _price, player] remoteExec ["MWF_fnc_finalizeBuild", 2];
    hint format ["Build request submitted: %1", _displayName];
    diag_log format ["[MWF Build] Player submitted placement of %1 at %2 (client hint cost %3).", _className, _finalPos, _price];
} else {
    hint _interruptReason;
    diag_log format ["[MWF Build] Player aborted placement of %1. Reason: %2", _className, _interruptReason];
};

true
