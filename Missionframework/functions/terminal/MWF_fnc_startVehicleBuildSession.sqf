/*
    Author: OpenAI
    Function: MWF_fnc_startVehicleBuildSession
    Project: Military War Framework

    Description:
    Literal KP-style local ghost build loop for vehicle purchase.
    No real vehicle is spawned until Place is confirmed.
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
    [["VEHICLE MENU", "Exit your vehicle before purchasing."], "warning"] call MWF_fnc_showNotification;
    false
};

if ((count _entry) < 4) exitWith {
    [["VEHICLE MENU", "Vehicle entry data missing."], "error"] call MWF_fnc_showNotification;
    false
};

[] call MWF_fnc_cleanupVehiclePlacement;
uiSleep 0.05;

_entry params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_displayName", "", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (_className isEqualTo "") exitWith { false };
if (_displayName isEqualTo "") then {
    _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
};

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
private _vehicleType = _profile param [0, "LAND"];
private _surfaceRule = _profile param [1, "LAND"];
private _ghostSpot = markerPos "ghost_spot";
if (_ghostSpot isEqualTo [0,0,0]) then {
    _ghostSpot = (getMarkerPos "respawn_west") vectorAdd [0,0,1000];
};

private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith {
    [["VEHICLE MENU", format ["Failed to create ghost for %1.", _displayName]], "error"] call MWF_fnc_showNotification;
    false
};

_ghost allowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulation false;
_ghost setVariable ["MWF_GhostPreview", true];
clearWeaponCargoGlobal _ghost;
clearMagazineCargoGlobal _ghost;
clearItemCargoGlobal _ghost;
clearBackpackCargoGlobal _ghost;
_ghost disableCollisionWith player;
if (!isNull _sourceTerminal) then { _ghost disableCollisionWith _sourceTerminal; };
for "_i" from 0 to 12 do {
    _ghost setObjectTexture [_i, "#(rgb,8,8,3)color(0,1,0,0.8)"];
};

private _dist = 0.6 * (sizeOf _className);
if (_dist < 3.5) then { _dist = 3.5; };
_dist = _dist + 1;
if (_vehicleType isEqualTo "AIR") then { _dist = _dist max 7; };
if (_vehicleType isEqualTo "WATER") then { _dist = _dist max 10; };

missionNamespace setVariable ["MWF_VehicleBuild_Active", true];
missionNamespace setVariable ["MWF_VehicleBuild_Confirmed", 1];
missionNamespace setVariable ["MWF_VehicleBuild_Cancelled", false];
missionNamespace setVariable ["MWF_VehicleBuild_Invalid", 0];
missionNamespace setVariable ["MWF_VehicleBuild_Class", _className];
missionNamespace setVariable ["MWF_VehicleBuild_Cost", _cost];
missionNamespace setVariable ["MWF_VehicleBuild_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehicleBuild_DisplayName", _displayName];
missionNamespace setVariable ["MWF_VehicleBuild_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehicleBuild_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehicleBuild_Profile", _profile];
missionNamespace setVariable ["MWF_VehicleBuild_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_VehicleBuild_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehicleBuild_Rotation", 0];
missionNamespace setVariable ["MWF_VehicleBuild_Elevation", 0];
missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehicleBuild_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehicleBuild_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];

player forceWalk true;

private _idRotate = player addAction [
    "<t color='#B0FF00'>Rotate</t>",
    { [] call MWF_fnc_vehicleBuildRotate; },
    nil, -750, false, false, "",
    "missionNamespace getVariable ['MWF_VehicleBuild_Active', false]"
];
private _idRaise = player addAction [
    "<t color='#B0FF00'>Raise</t>",
    { [] call MWF_fnc_vehicleBuildRaise; },
    nil, -765, false, false, "",
    "missionNamespace getVariable ['MWF_VehicleBuild_Active', false]"
];
private _idLower = player addAction [
    "<t color='#B0FF00'>Lower</t>",
    { [] call MWF_fnc_vehicleBuildLower; },
    nil, -766, false, false, "",
    "missionNamespace getVariable ['MWF_VehicleBuild_Active', false]"
];
private _idPlace = player addAction [
    "<t color='#B0FF00'>Place</t>",
    { [] call MWF_fnc_vehicleBuildPlace; },
    nil, -775, false, true, "",
    "(missionNamespace getVariable ['MWF_VehicleBuild_Active', false]) && ((missionNamespace getVariable ['MWF_VehicleBuild_Invalid', 1]) isEqualTo 0)"
];
private _idCancel = player addAction [
    "<t color='#B0FF00'>Cancel</t>",
    { [] call MWF_fnc_vehicleBuildCancel; },
    nil, -725, false, true, "",
    "missionNamespace getVariable ['MWF_VehicleBuild_Active', false]"
];
missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", [_idRotate, _idRaise, _idLower, _idPlace, _idCancel]];

[["VEHICLE MENU", format ["Ghost build active for %1.", _displayName]], "info"] call MWF_fnc_showNotification;

while {
    (missionNamespace getVariable ["MWF_VehicleBuild_Active", false]) &&
    ((missionNamespace getVariable ["MWF_VehicleBuild_Confirmed", 1]) isEqualTo 1) &&
    !(missionNamespace getVariable ["MWF_VehicleBuild_Cancelled", false]) &&
    alive player
} do {
    private _buildRotation = missionNamespace getVariable ["MWF_VehicleBuild_Rotation", 0];
    private _buildElevation = missionNamespace getVariable ["MWF_VehicleBuild_Elevation", 0];
    private _truedir = 90 - (getDir player);
    private _truepos = [
        ((getPos player) select 0) + (_dist * (cos _truedir)),
        ((getPos player) select 1) + (_dist * (sin _truedir)),
        0
    ];
    private _actualdir = (getDir player) + _buildRotation;
    while {_actualdir > 360} do { _actualdir = _actualdir - 360; };
    while {_actualdir < 0} do { _actualdir = _actualdir + 360; };

    private _finalPos = [_truepos select 0, _truepos select 1, (_truepos select 2) + _buildElevation];
    _ghost setDir _actualdir;

    private _validation = [
        _className,
        ATLToASL _finalPos,
        _actualdir,
        _profile,
        _ghost,
        _sourceTerminal
    ] call MWF_fnc_validateVehicleBuildPlacement;

    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];
    missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", ATLToASL _finalPos];
    missionNamespace setVariable ["MWF_VehicleBuild_LastDir", _actualdir];
    missionNamespace setVariable ["MWF_VehicleBuild_LastReason", _reason];

    if (_isValid) then {
        if (_vehicleType isEqualTo "WATER") then {
            _ghost setPosASL (ATLToASL _finalPos);
            _ghost setVectorUp [0,0,1];
        } else {
            _ghost setPosATL _finalPos;
            _ghost setVectorUp (surfaceNormal position _ghost);
        };
        for "_i" from 0 to 12 do {
            _ghost setObjectTexture [_i, "#(rgb,8,8,3)color(0,1,0,0.8)"];
        };
        _ghost setAlpha 0.8;
        missionNamespace setVariable ["MWF_VehicleBuild_Invalid", 0];
    } else {
        _ghost setPosATL _ghostSpot;
        for "_i" from 0 to 12 do {
            _ghost setObjectTexture [_i, "#(rgb,8,8,3)color(1,0,0,0.55)"];
        };
        _ghost setAlpha 0.55;
        missionNamespace setVariable ["MWF_VehicleBuild_Invalid", 1];
    };

    uiSleep 0.05;
};

private _confirmedState = missionNamespace getVariable ["MWF_VehicleBuild_Confirmed", 1];
private _cancelled = missionNamespace getVariable ["MWF_VehicleBuild_Cancelled", false];
private _lastPosASL = missionNamespace getVariable ["MWF_VehicleBuild_LastPosASL", getPosASL player];
private _lastDir = missionNamespace getVariable ["MWF_VehicleBuild_LastDir", getDir player];
private _lastReason = missionNamespace getVariable ["MWF_VehicleBuild_LastReason", "Placement invalid."];
private _invalid = missionNamespace getVariable ["MWF_VehicleBuild_Invalid", 1];

[] call MWF_fnc_cleanupVehiclePlacement;

if (_cancelled || {!alive player}) exitWith {
    [["VEHICLE MENU", "Ghost build cancelled."], "warning"] call MWF_fnc_showNotification;
    false
};

if (_confirmedState isEqualTo 2 && {_invalid isEqualTo 0}) then {
    [
        _className,
        _cost,
        _minTier,
        _lastPosASL,
        _lastDir,
        _surfaceRule,
        _requiredUnlock,
        _isTier5,
        clientOwner
    ] remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    true
} else {
    [["VEHICLE MENU", _lastReason], "warning"] call MWF_fnc_showNotification;
    false
};
