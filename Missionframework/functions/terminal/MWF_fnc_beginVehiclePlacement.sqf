/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_beginVehiclePlacement
    Project: Military War Framework

    Description:
    Starts local ghost placement for a purchased vehicle entry.
*/

if (!hasInterface) exitWith { false };

params [
    ["_entry", [], [[]]],
    ["_terminal", objNull, [objNull]]
];

if ((count _entry) < 4) exitWith { false };

[] call MWF_fnc_cleanupVehiclePlacement;

_entry params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_displayName", "", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (_className isEqualTo "") exitWith { false };

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { false };

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
_profile params [
    ["_vehicleType", "LAND", [""]],
    ["_surfaceRule", "LAND", [""]],
    ["_previewDistance", 8, [0]],
    ["_previewHeight", 0, [0]]
];

private _ghost = _className createVehicleLocal [0, 0, 0];
if (isNull _ghost) exitWith { false };

_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setAlpha 0.55;
_ghost disableCollisionWith player;

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
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_SourceTerminal", _terminal];
missionNamespace setVariable ["MWF_VehiclePlacement_Confirmed", false];
missionNamespace setVariable ["MWF_VehiclePlacement_Cancelled", false];

private _rotateAction = player addAction [
    "Rotate (45°)",
    {
        private _dir = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0];
        missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", _dir + 45];
    },
    nil, 98, false, true, "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _raiseAction = player addAction [
    "Raise",
    {
        private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];
        missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", _offset + 0.5];
    },
    nil, 97, false, true, "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _lowerAction = player addAction [
    "Lower",
    {
        private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];
        missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", _offset - 0.5];
    },
    nil, 96, false, true, "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _confirmAction = player addAction [
    "Confirm Placement",
    { missionNamespace setVariable ["MWF_VehiclePlacement_Confirmed", true]; },
    nil, 100, false, true, "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _cancelAction = player addAction [
    "Cancel",
    { missionNamespace setVariable ["MWF_VehiclePlacement_Cancelled", true]; },
    nil, 99, false, true, "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _rotateAction];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _raiseAction];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _lowerAction];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];

[ ["VEHICLE PLACEMENT", format ["Ghost build active for %1.", _displayName]], "info" ] call MWF_fnc_showNotification;

while {
    missionNamespace getVariable ["MWF_VehiclePlacement_Active", false] &&
    !(missionNamespace getVariable ["MWF_VehiclePlacement_Confirmed", false]) &&
    !(missionNamespace getVariable ["MWF_VehiclePlacement_Cancelled", false]) &&
    alive player
} do {
    private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0];
    private _heightOffset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];

    private _targetPos = positionCameraToWorld [0, _previewDistance max 6, 0];
    private _finalPosATL = ASLToATL (AGLToASL _targetPos);
    _finalPosATL set [2, (_finalPosATL select 2) + _previewHeight + _heightOffset];

    _ghost setPosATL _finalPosATL;
    _ghost setDir (getDir player + _rotation);

    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", ATLToASL _finalPosATL];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir _ghost];
    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", true];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement preview active."];

    uiSleep 0.01;
};

private _confirmed = missionNamespace getVariable ["MWF_VehiclePlacement_Confirmed", false];
private _cancelled = missionNamespace getVariable ["MWF_VehiclePlacement_Cancelled", false];
private _isValid = missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false];
private _lastReason = missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."];

if (_confirmed && _isValid) then {
    [] call MWF_fnc_confirmVehiclePlacement;
} else {
    [] call MWF_fnc_cleanupVehiclePlacement;
    if (_confirmed && !_isValid) then {
        systemChat _lastReason;
    } else {
        hint "Vehicle placement cancelled.";
    };
};

true
