/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_startVehicleBuildSession
    Project: Military War Framework

    Description:
    New KP-style vehicle placement core for purchased vehicles.
    This completely bypasses the old MWF vehicle ghost core.
*/

if (!hasInterface) exitWith { false };
if (vehicle player != player) exitWith {
    hint "Exit your vehicle before placing a vehicle.";
    false
};

params [
    ["_entry", [], [[]]],
    ["_sourceTerminal", objNull, [objNull]]
];

if ((count _entry) < 4) exitWith { false };

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
if (_displayName isEqualTo "") then {
    _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
};

[] call MWF_fnc_cleanupVehiclePlacement;

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
_profile params [
    ["_vehicleType", "LAND", [""]],
    ["_surfaceRule", "LAND", [""]],
    ["_previewDistance", 8, [0]],
    ["_previewHeight", 0.2, [0]],
    ["_diameter", 4, [0]],
    ["_safetyRadius", 3, [0]],
    ["_bbox", [2, 4, 2], [[]]]
];

private _ghostSpot = (markerPos "respawn_west") vectorAdd [0, 0, 1000];
private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith { false };

_ghost allowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulation false;
_ghost disableCollisionWith player;
_ghost setVariable ["MWF_IsVehiclePreview", true];

clearWeaponCargo _ghost;
clearMagazineCargo _ghost;
clearItemCargo _ghost;
clearBackpackCargo _ghost;

private _paintGhost = {
    params ["_obj", "_valid"];
    if (isNull _obj) exitWith {};

    private _texture = if (_valid) then {
        "#(rgb,8,8,3)color(0,1,0,0.60)"
    } else {
        "#(rgb,8,8,3)color(1,0,0,0.45)"
    };

    _obj setAlpha (if (_valid) then { 0.65 } else { 0.45 });
    for "_i" from 0 to 12 do {
        _obj setObjectTexture [_i, _texture];
    };
};

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", _profile];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehiclePlacement_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_PlaceRequested", false];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelRequested", false];

missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];

player forceWalk true;

private _condition = "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]";
private _rotateAction = player addAction [
    "Rotate (90°)",
    { [] call MWF_fnc_vehicleBuildRotate; },
    nil,
    -750,
    false,
    true,
    "",
    _condition
];
private _raiseAction = player addAction [
    "Raise",
    { [] call MWF_fnc_vehicleBuildRaise; },
    nil,
    -760,
    false,
    true,
    "",
    _condition
];
private _lowerAction = player addAction [
    "Lower",
    { [] call MWF_fnc_vehicleBuildLower; },
    nil,
    -761,
    false,
    true,
    "",
    _condition
];
private _confirmAction = player addAction [
    "Place Vehicle",
    { [] call MWF_fnc_vehicleBuildPlace; },
    nil,
    -770,
    false,
    true,
    "",
    "(missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]) && (missionNamespace getVariable ['MWF_VehiclePlacement_IsValid', false])"
];
private _cancelAction = player addAction [
    "Cancel Placement",
    { [] call MWF_fnc_vehicleBuildCancel; },
    nil,
    -740,
    false,
    true,
    "",
    _condition
];

missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _rotateAction];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _raiseAction];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _lowerAction];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];

[["VEHICLE PLACEMENT", format ["Ghost preview active for %1.", _displayName]], "info"] call MWF_fnc_showNotification;

[_ghost, true] call _paintGhost;

while {
    missionNamespace getVariable ["MWF_VehiclePlacement_Active", false] &&
    !(missionNamespace getVariable ["MWF_VehiclePlacement_PlaceRequested", false]) &&
    !(missionNamespace getVariable ["MWF_VehiclePlacement_CancelRequested", false]) &&
    alive player
} do {
    private _ghostNow = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
    if (isNull _ghostNow) exitWith {
        missionNamespace setVariable ["MWF_VehiclePlacement_CancelRequested", true];
    };

    private _rotationNow = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0];
    private _heightOffsetNow = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];

    private _playerPosATL = getPosATL player;
    private _playerDir = getDir player;
    private _basePosATL = [
        (_playerPosATL # 0) + (_previewDistance * sin _playerDir),
        (_playerPosATL # 1) + (_previewDistance * cos _playerDir),
        _playerPosATL # 2
    ];
    _basePosATL set [2, (_basePosATL # 2) + _previewHeight + _heightOffsetNow];

    private _ghostDir = _playerDir + _rotationNow;
    _ghostNow setDir _ghostDir;

    if (_surfaceRule isEqualTo "WATER") then {
        private _waterPosASL = ATLToASL _basePosATL;
        _ghostNow setPosASL _waterPosASL;
        _ghostNow setVectorUp [0, 0, 1];
        missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _waterPosASL];
    } else {
        _ghostNow setPosATL _basePosATL;
        _ghostNow setVectorUp (surfaceNormal _basePosATL);
        missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", ATLToASL _basePosATL];
    };

    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _ghostDir];

    private _validation = [_className, missionNamespace getVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player], _ghostDir, _profile, _ghostNow, _sourceTerminal] call MWF_fnc_validateVehicleBuildPlacement;
    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];

    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];

    [_ghostNow, _isValid] call _paintGhost;

    uiSleep 0.05;
};

private _placeRequested = missionNamespace getVariable ["MWF_VehiclePlacement_PlaceRequested", false];
private _cancelRequested = missionNamespace getVariable ["MWF_VehiclePlacement_CancelRequested", false];
private _isValid = missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false];
private _reason = missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."];
private _posASL = missionNamespace getVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
private _dir = missionNamespace getVariable ["MWF_VehiclePlacement_LastDir", getDir player];

[] call MWF_fnc_cleanupVehiclePlacement;

if (_placeRequested && _isValid) exitWith {
    [_className, _cost, _minTier, _posASL, _dir, _surfaceRule, _requiredUnlock, _isTier5] remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    [["VEHICLE PLACEMENT", format ["Placement sent for %1.", _displayName]], "info"] call MWF_fnc_showNotification;
    true
};

if (_placeRequested && !_isValid) exitWith {
    [["VEHICLE PLACEMENT", _reason], "warning"] call MWF_fnc_showNotification;
    false
};

if (_cancelRequested) then {
    [["VEHICLE PLACEMENT", "Placement cancelled."], "warning"] call MWF_fnc_showNotification;
};

false
