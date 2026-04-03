/*
    Author: Theane / ChatGPT
    Function: MWF_fn_startBuildPlacement
    Project: Military War Framework

    Description:
    Handles client-side build placement with ghost preview, validation and confirmation.
    Uses the same scroll-action language as vehicle ghost placement.
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]]
];

if (_className isEqualTo "") exitWith {};
if (!hasInterface) exitWith {};

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { systemChat format ["Build failed: unknown class %1.", _className]; };

[] call MWF_fnc_cleanupBuildPlacement;

private _displayName = getText (_cfg >> "displayName");
if (_displayName isEqualTo "") then { _displayName = _className; };

private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost setAlpha 0.55;
_ghost setVehicleLock "LOCKED";
_ghost disableCollisionWith player;

missionNamespace setVariable ["MWF_BuildPlacement_Active", true];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "BUILD_PLACEMENT"];
missionNamespace setVariable ["MWF_BuildPlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_BuildPlacement_Class", _className];
missionNamespace setVariable ["MWF_BuildPlacement_Cost", _price];
missionNamespace setVariable ["MWF_BuildPlacement_Rotation", 0];
missionNamespace setVariable ["MWF_BuildPlacement_HeightOffset", 0];
missionNamespace setVariable ["MWF_BuildPlacement_IsValid", false];
missionNamespace setVariable ["MWF_BuildPlacement_LastReason", "Use scroll menu to rotate/raise/lower, then build or cancel."];
missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", getPosATL player];
missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", false];
missionNamespace setVariable ["MWF_BuildPlacement_Cancelled", false];
missionNamespace setVariable ["MWF_BuildPlacement_Interrupted", false];

private _actionRotate = player addAction ["Rotate (45°)", { missionNamespace setVariable ["MWF_BuildPlacement_Rotation", (missionNamespace getVariable ["MWF_BuildPlacement_Rotation", 0]) + 45]; }, [], 98, false, false, "", "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"];
private _actionRaise = player addAction ["Raise", { missionNamespace setVariable ["MWF_BuildPlacement_HeightOffset", (missionNamespace getVariable ["MWF_BuildPlacement_HeightOffset", 0]) + 0.2]; }, [], 97, false, false, "", "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"];
private _actionLower = player addAction ["Lower", { missionNamespace setVariable ["MWF_BuildPlacement_HeightOffset", (missionNamespace getVariable ["MWF_BuildPlacement_HeightOffset", 0]) - 0.2]; }, [], 96, false, false, "", "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"];
private _actionConfirm = player addAction ["Build", { missionNamespace setVariable ["MWF_BuildPlacement_Confirmed", true]; }, [], 100, false, false, "", "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"];
private _actionCancel = player addAction ["Cancel Build", { missionNamespace setVariable ["MWF_BuildPlacement_Cancelled", true]; }, [], 99, false, false, "", "missionNamespace getVariable ['MWF_BuildPlacement_Active', false]"];
missionNamespace setVariable ["MWF_BuildPlacement_RotateAction", _actionRotate];
missionNamespace setVariable ["MWF_BuildPlacement_RaiseAction", _actionRaise];
missionNamespace setVariable ["MWF_BuildPlacement_LowerAction", _actionLower];
missionNamespace setVariable ["MWF_BuildPlacement_ConfirmAction", _actionConfirm];
missionNamespace setVariable ["MWF_BuildPlacement_CancelAction", _actionCancel];

hint format ["PLACEMENT MODE ACTIVE
%1
Use scroll actions to rotate, raise/lower, build or cancel.", _displayName];

while { missionNamespace getVariable ["MWF_BuildPlacement_Active", false] && !(missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false]) && !(missionNamespace getVariable ["MWF_BuildPlacement_Cancelled", false]) && alive player } do {
    private _rotation = missionNamespace getVariable ["MWF_BuildPlacement_Rotation", 0];
    private _heightOffset = missionNamespace getVariable ["MWF_BuildPlacement_HeightOffset", 0];
    private _pos = player modelToWorld [0, 10, 0];
    _pos set [2, (_pos param [2, 0]) + _heightOffset];
    _ghost setPosATL _pos;
    _ghost setDir (getDir player + _rotation);
    missionNamespace setVariable ["MWF_BuildPlacement_LastPosATL", _pos];

    private _validation = [_className, _pos, getDir player + _rotation, _ghost] call MWF_fnc_validateBuildPlacement;
    missionNamespace setVariable ["MWF_BuildPlacement_IsValid", _validation param [0, false]];
    missionNamespace setVariable ["MWF_BuildPlacement_LastReason", _validation param [1, "Placement invalid."]];
    _ghost setAlpha (if ((_validation param [0, false])) then {0.35} else {0.65});

    uiSleep 0.01;
};

private _confirmed = missionNamespace getVariable ["MWF_BuildPlacement_Confirmed", false];
private _isValid = missionNamespace getVariable ["MWF_BuildPlacement_IsValid", false];
private _finalPos = +(missionNamespace getVariable ["MWF_BuildPlacement_LastPosATL", getPosATL player]);
private _finalDir = getDir player + (missionNamespace getVariable ["MWF_BuildPlacement_Rotation", 0]);
private _lastReason = missionNamespace getVariable ["MWF_BuildPlacement_LastReason", "Placement invalid."];

[] call MWF_fnc_cleanupBuildPlacement;

if (_confirmed && _isValid) then {
    [_className, _finalPos, _finalDir, _price, player] remoteExec ["MWF_fnc_finalizeBuild", 2];
    hint format ["Build request submitted: %1", _displayName];
} else {
    if (_confirmed && !_isValid) then { systemChat _lastReason; } else { hint "Construction Aborted."; };
};
