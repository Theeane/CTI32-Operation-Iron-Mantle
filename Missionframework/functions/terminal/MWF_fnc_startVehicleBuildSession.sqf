/*
    KP-style vehicle placement core for MWF.
    This is intentionally self-contained and does not rely on the old hybrid ghost path.
*/

if (!hasInterface) exitWith { false };
if !(canSuspend) exitWith {
    _this spawn MWF_fnc_startVehicleBuildSession;
    true
};

params [
    ["_entry", [], [[]]],
    ["_sourceTerminal", objNull, [objNull]]
];

if (vehicle player != player) exitWith {
    ["Exit your vehicle before placing a vehicle."] call BIS_fnc_showSubtitle;
    false
};

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
if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith { false };
if (_displayName isEqualTo "") then {
    _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
};

[] call MWF_fnc_cleanupVehiclePlacement;
uiSleep 0.05;

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

private _ghostSpot = [0,0,0];
private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith { false };

_ghost allowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulation false;
_ghost disableCollisionWith player;
clearWeaponCargo _ghost;
clearMagazineCargo _ghost;
clearItemCargo _ghost;
clearBackpackCargo _ghost;

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
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_PlaceRequested", false];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelRequested", false];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];

private _dist = 0.6 * (sizeOf _className);
if (_vehicleType isEqualTo "WATER") then {
    if (_dist < 16) then { _dist = 16; };
} else {
    if (_vehicleType isEqualTo "AIR") then {
        if (_dist < 12) then { _dist = 12; };
    } else {
        if (_dist < 4) then { _dist = 4; };
    };
};
_dist = _dist + 1;

private _paintGhost = {
    params ["_obj", "_valid"];
    if (isNull _obj) exitWith {};
    private _color = if (_valid) then { '#(rgb,8,8,3)color(0,1,0,0.60)' } else { '#(rgb,8,8,3)color(1,0,0,0.45)' };
    _obj setAlpha (if (_valid) then {0.65} else {0.45});
    for '_i' from 0 to 12 do {
        _obj setObjectTextureGlobal [_i, _color];
    };
};
[_ghost, true] call _paintGhost;

player forceWalk true;
private _condition = "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]";
private _actions = [];
_actions pushBack (player addAction ["<t color='#B0FF00'>Rotate</t>", { [] call MWF_fnc_vehicleBuildRotate; }, nil, -750, false, false, "", _condition]);
_actions pushBack (player addAction ["<t color='#B0FF00'>Raise</t>", { [] call MWF_fnc_vehicleBuildRaise; }, nil, -760, false, false, "", _condition]);
_actions pushBack (player addAction ["<t color='#B0FF00'>Lower</t>", { [] call MWF_fnc_vehicleBuildLower; }, nil, -761, false, false, "", _condition]);
_actions pushBack (player addAction ["<t color='#B0FF00'>Place Vehicle</t>", { [] call MWF_fnc_vehicleBuildPlace; }, nil, -770, false, true, "", "(missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]) && (missionNamespace getVariable ['MWF_VehiclePlacement_IsValid', false])"]);
_actions pushBack (player addAction ["<t color='#B0FF00'>Cancel Placement</t>", { [] call MWF_fnc_vehicleBuildCancel; }, nil, -740, false, false, "", _condition]);
missionNamespace setVariable ["MWF_VehiclePlacement_ActionIds", _actions];

[format ["MWF Vehicle Preview: %1", _displayName]] call BIS_fnc_showSubtitle;

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
    private _elevationNow = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];

    private _truedir = 90 - (getDir player);
    private _truePos = [((getPos player) select 0) + (_dist * (cos _truedir)), ((getPos player) select 1) + (_dist * (sin _truedir)), 0];
    private _actualDir = (getDir player) + _rotationNow;

    while {_actualDir > 360} do { _actualDir = _actualDir - 360; };
    while {_actualDir < 0} do { _actualDir = _actualDir + 360; };

    private _finalATL = [_truePos select 0, _truePos select 1, (_truePos select 2) + _previewHeight + _elevationNow];
    private _finalASL = ATLToASL _finalATL;

    _ghostNow setDir _actualDir;
    if (_surfaceRule isEqualTo "WATER") then {
        _ghostNow setPosASL _finalASL;
        _ghostNow setVectorUp [0,0,1];
    } else {
        _ghostNow setPosATL _finalATL;
        _ghostNow setVectorUp (surfaceNormal _finalATL);
    };

    private _validation = [_className, if (_surfaceRule isEqualTo "WATER") then {_finalASL} else {ATLToASL _finalATL}, _actualDir, _profile, _ghostNow, _sourceTerminal] call MWF_fnc_validateVehicleBuildPlacement;
    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];

    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", if (_surfaceRule isEqualTo "WATER") then {_finalASL} else {ATLToASL _finalATL}];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _actualDir];

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
