/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_startBuildPlacement
    Project: Military War Framework

    Description:
    Handles client-side ghost placement for physical base upgrades.
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]],
    ["_upgradeId", "", [""]]
];

if (_className isEqualTo "") exitWith { false };
if (!hasInterface) exitWith { false };

[] call MWF_fnc_cleanupBuildPlacement;

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_supplies < _price) exitWith {
    [format ["Insufficient Supplies: %1 needed.", _price]] call BIS_fnc_showSubtitle;
    false
};

private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setVehicleLock "LOCKED";
_ghost setAlpha 0.45;
_ghost disableCollisionWith player;

missionNamespace setVariable ["MWF_BuildPlacement_Active", true];
missionNamespace setVariable ["MWF_BuildPlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_BuildPlacement_Class", _className];
missionNamespace setVariable ["MWF_BuildPlacement_Cost", _price];
missionNamespace setVariable ["MWF_BuildPlacement_UpgradeId", _upgradeId];
missionNamespace setVariable ["MWF_BuildPlacement_Rotation", getDir player];
missionNamespace setVariable ["MWF_BuildPlacement_IsValid", false];
missionNamespace setVariable ["MWF_BuildPlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", getPosATL player];
missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
missionNamespace setVariable ["MWF_BuildPlacement_Cancelled", false];
missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", false];

private _confirmAction = player addAction [
    format ["<t color='#00FF66'>Confirm Construction (%1 Supplies)</t>", _price],
    { missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", true]; },
    nil,
    100,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"
];

private _cancelAction = player addAction [
    "<t color='#FF5555'>Cancel Construction</t>",
    { missionNamespace setVariable ["MWF_BuildPlacement_Cancelled", true]; },
    nil,
    99,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"
];

missionNamespace setVariable ["MWF_BuildPlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_BuildPlacement_CancelAction", _cancelAction];

[
    ["BASE UPGRADE", "Ghost placement active. Confirm or cancel from the action menu."],
    "info"
] call MWF_fnc_showNotification;

while {
    missionNamespace getVariable ["MWF_BuildPlacement_Active", false] &&
    alive player &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false]) &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Cancelled", false]) &&
    !(missionNamespace getVariable ["MWF_BuildPlacement_Interrupted", false])
} do {
    private _rotation = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", getDir player];
    if (inputAction "TurnLeft" > 0) then { _rotation = _rotation - 1.5; };
    if (inputAction "TurnRight" > 0) then { _rotation = _rotation + 1.5; };
    missionNamespace setVariable ["MWF_BuildPlacement_Rotation", _rotation];

    private _posATL = player modelToWorld [0, 8, 0];
    _ghost setVectorUp surfaceNormal _posATL;
    _ghost setPosATL _posATL;
    _ghost setDir _rotation;

    private _result = [_className, _posATL, _rotation, _ghost] call MWF_fnc_validateBuildPlacement;
    missionNamespace setVariable ["MWF_BuildPlacement_IsValid", _result param [0, false]];
    missionNamespace setVariable ["MWF_BuildPlacement_LastReason", _result param [1, "Placement invalid."]];
    missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", _posATL];

    _ghost setAlpha ([0.65, 0.25] select !(_result param [0, false]));
    uiSleep 0.02;
};

private _confirmed = missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false];
private _cancelled = missionNamespace getVariable ["MWF_BuildPlacement_Cancelled", false];
private _interrupted = missionNamespace getVariable ["MWF_BuildPlacement_Interrupted", false];
private _isValid = missionNamespace getVariable ["MWF_BuildPlacement_IsValid", false];
private _finalPosATL = + (missionNamespace getVariable ["MWF_BuildPlacement_LastPosATL", getPosATL player]);
private _finalDir = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", getDir player];
private _reason = missionNamespace getVariable ["MWF_BuildPlacement_LastReason", "Placement invalid."];

[] call MWF_fnc_cleanupBuildPlacement;

if (_interrupted) exitWith {
    [["BASE UPGRADE", "Build placement interrupted by damage."], "warning"] call MWF_fnc_showNotification;
    false
};

if (_cancelled || {!alive player}) exitWith {
    [["BASE UPGRADE", "Construction cancelled."], "info"] call MWF_fnc_showNotification;
    false
};

if (!_confirmed) exitWith { false };
if (!_isValid) exitWith {
    systemChat _reason;
    false
};

[_className, _finalPosATL, _finalDir, _price, _upgradeId] remoteExec ["MWF_fnc_finalizeBuild", 2];
[["BASE UPGRADE", "Construction request sent to server."], "success"] call MWF_fnc_showNotification;
true
