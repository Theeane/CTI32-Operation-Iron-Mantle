/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_beginVehiclePlacement
    Project: Military War Framework

    Description:
    Starts local vehicle ghost placement from the vehicle menu.
    This startup path is intentionally minimal so actions appear immediately and
    the camera-driven update loop can take over without risky pre-setup work.
*/

if (!hasInterface) exitWith { false };

params [
    ["_entry", [], [[]]],
    ["_terminal", objNull, [objNull]]
];

if (_entry isEqualTo [] || {(count _entry) < 4}) exitWith {
    systemChat "Vehicle placement failed: invalid selected vehicle entry.";
    false
};

[] call MWF_fnc_cleanupVehiclePlacement;

_entry params [
    ["_className", "", [""]],
    ["_displayName", "", [""]],
    ["_cost", 0, [0]],
    ["_category", "", [""]],
    ["_unlockType", "", [""]],
    ["_unlockValue", 0, [0]],
    ["_minTier", 1, [0]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (_className isEqualTo "") exitWith { systemChat "Vehicle placement failed: empty classname."; false };
private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { systemChat format ["Vehicle placement failed: unknown class %1.", _className]; false };
if (_displayName isEqualTo "") then {
    _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
};

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
if (_profile isEqualTo [] || {(count _profile) < 4}) then {
    _profile = ["LAND", "LAND", 5, 0.25];
};
_profile params ["_vehicleType", "_surfaceRule", "_previewDistance", "_previewHeight"];

private _ghost = _className createVehicleLocal [0, 0, 0];
if (isNull _ghost) exitWith {
    systemChat format ["Vehicle placement failed: could not create local ghost for %1.", _displayName];
    false
};

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", _profile];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", round ((getDir player) / 45) * 45];
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement preview active."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];

private _rotateAction = player addAction ["Rotate (45°)", {
    private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0];
    missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", _rotation + 45];
}, [], 103, false, false, "", "true"];
private _raiseAction = player addAction ["Raise", {
    private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];
    missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (_offset + 0.5) min 5];
}, [], 102, false, false, "", "true"];
private _lowerAction = player addAction ["Lower", {
    private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];
    missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (_offset - 0.5) max -2];
}, [], 101, false, false, "", "true"];
private _confirmAction = player addAction [format ["<t color='#00FF66'>Confirm Placement: %1 (%2 Supplies)</t>", _displayName, _cost], {
    [] call MWF_fnc_confirmVehiclePlacement;
}, [], 100, false, false, "", "true"];
private _cancelAction = player addAction ["<t color='#FF5555'>Cancel</t>", {
    [] call MWF_fnc_cancelVehiclePlacement;
}, [], 99, false, false, "", "true"];

missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _rotateAction];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _raiseAction];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _lowerAction];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];

_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setAlpha 0.55;
_ghost disableCollisionWith player;

private _initialPosASL = AGLToASL (positionCameraToWorld [0, _previewDistance, 0]);
if (_surfaceRule isEqualTo "WATER") then {
    _initialPosASL set [2, ((_initialPosASL select 2) max 0.5) + (_previewHeight max 0.5)];
    _ghost setVectorUp [0, 0, 1];
    _ghost setPosASL _initialPosASL;
} else {
    private _initialPosATL = ASLToATL _initialPosASL;
    private _groundATL = +_initialPosATL;
    _groundATL set [2, 0];
    _initialPosATL set [2, (_previewHeight max 0.05)];
    _ghost setVectorUp surfaceNormal _groundATL;
    _ghost setPosATL _initialPosATL;
    _initialPosASL = AGLToASL _initialPosATL;
};
_ghost setDir (missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", getDir player]);
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _initialPosASL];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", getDir player]];

[] spawn MWF_fnc_updateVehicleGhost;

[["VEHICLE PLACEMENT", format ["Ghost build active for %1. Use the action menu to rotate, raise/lower, confirm, or cancel.", _displayName]], "info"] call MWF_fnc_showNotification;
true
