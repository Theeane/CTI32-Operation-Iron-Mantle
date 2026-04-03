/*
    KP-style vehicle ghost build session for MWF.
    Ghost exists only locally. Real vehicle is purchased and spawned only after Place.
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
private _previewDistance = _profile param [2, 8];
private _previewHeight = _profile param [3, 0.2];
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

build_confirmed = 1;
build_invalid = 0;
build_rotation = 0;
build_elevation = 0;
missionNamespace setVariable ["MWF_VehicleBuild_Active", true];
missionNamespace setVariable ["MWF_VehicleBuild_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehicleBuild_Profile", _profile];
missionNamespace setVariable ["MWF_VehicleBuild_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehicleBuild_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehicleBuild_LastReason", "Placement not yet validated."];

player forceWalk true;

private _idRotate = player addAction [
    "<t color='#B0FF00'>Rotate</t>",
    { call compile preprocessFileLineNumbers "functions\\terminal\\MWF_fnc_vehicleBuildRotate.sqf"; },
    nil, -750, false, false, "",
    "!isNil 'build_confirmed' && {build_confirmed == 1}"
];
private _idRaise = player addAction [
    "<t color='#B0FF00'>Raise</t>",
    { call compile preprocessFileLineNumbers "functions\\terminal\\MWF_fnc_vehicleBuildRaise.sqf"; },
    nil, -765, false, false, "",
    "!isNil 'build_confirmed' && {build_confirmed == 1}"
];
private _idLower = player addAction [
    "<t color='#B0FF00'>Lower</t>",
    { call compile preprocessFileLineNumbers "functions\\terminal\\MWF_fnc_vehicleBuildLower.sqf"; },
    nil, -766, false, false, "",
    "!isNil 'build_confirmed' && {build_confirmed == 1}"
];
private _idPlace = player addAction [
    "<t color='#B0FF00'>Place</t>",
    { call compile preprocessFileLineNumbers "functions\\terminal\\MWF_fnc_vehicleBuildPlace.sqf"; },
    nil, -775, false, true, "",
    "!isNil 'build_confirmed' && {build_confirmed == 1} && {!isNil 'build_invalid'} && {build_invalid == 0}"
];
private _idCancel = player addAction [
    "<t color='#B0FF00'>Cancel</t>",
    { call compile preprocessFileLineNumbers "functions\\terminal\\MWF_fnc_vehicleBuildCancel.sqf"; },
    nil, -725, false, true, "",
    "!isNil 'build_confirmed' && {build_confirmed == 1}"
];
missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", [_idRotate, _idRaise, _idLower, _idPlace, _idCancel]];

[["VEHICLE MENU", format ["Ghost build active for %1.", _displayName]], "info"] call MWF_fnc_showNotification;

while { !isNil "build_confirmed" && {build_confirmed == 1} && {alive player} } do {
    private _trueDir = 90 - (getDir player);
    private _basePos = if (_vehicleType isEqualTo "WATER") then { getPos player } else { getPosATL player };
    private _truePos = [
        (_basePos select 0) + (_previewDistance * (cos _trueDir)),
        (_basePos select 1) + (_previewDistance * (sin _trueDir)),
        0
    ];
    private _actualDir = (getDir player) + (if (isNil "build_rotation") then { 0 } else { build_rotation });
    while { _actualDir > 360 } do { _actualDir = _actualDir - 360; };
    while { _actualDir < 0 } do { _actualDir = _actualDir + 360; };

    private _finalPosATL = [_truePos select 0, _truePos select 1, (_truePos select 2) + _previewHeight + (if (isNil "build_elevation") then { 0 } else { build_elevation })];
    private _validation = [
        _className,
        ATLToASL _finalPosATL,
        _actualDir,
        _profile,
        _ghost,
        _sourceTerminal
    ] call MWF_fnc_validateVehicleBuildPlacement;

    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];
    missionNamespace setVariable ["MWF_VehicleBuild_LastReason", _reason];

    if (_isValid) then {
        _ghost setDir _actualDir;
        if (_vehicleType isEqualTo "WATER") then {
            _ghost setPosASL (ATLToASL _finalPosATL);
            _ghost setVectorUp [0,0,1];
        } else {
            _ghost setPosATL _finalPosATL;
            _ghost setVectorUp (surfaceNormal position _ghost);
        };
        missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", getPosASL _ghost];
        missionNamespace setVariable ["MWF_VehicleBuild_LastDir", _actualDir];
        for "_i" from 0 to 12 do {
            _ghost setObjectTexture [_i, "#(rgb,8,8,3)color(0,1,0,0.8)"];
        };
        _ghost setAlpha 0.8;
        build_invalid = 0;
    } else {
        _ghost setPosATL _ghostSpot;
        for "_i" from 0 to 12 do {
            _ghost setObjectTexture [_i, "#(rgb,8,8,3)color(1,0,0,0.55)"];
        };
        _ghost setAlpha 0.55;
        build_invalid = 1;
    };

    uiSleep 0.05;
};

private _confirmedState = if (isNil "build_confirmed") then { 0 } else { build_confirmed };
private _invalid = if (isNil "build_invalid") then { 1 } else { build_invalid };
private _lastPosASL = missionNamespace getVariable ["MWF_VehicleBuild_LastPosASL", getPosASL player];
private _lastDir = missionNamespace getVariable ["MWF_VehicleBuild_LastDir", getDir player];
private _lastReason = missionNamespace getVariable ["MWF_VehicleBuild_LastReason", "Placement invalid."];

[] call MWF_fnc_cleanupVehiclePlacement;

if (!alive player || {_confirmedState == 3}) exitWith {
    [["VEHICLE MENU", "Ghost build cancelled."], "warning"] call MWF_fnc_showNotification;
    false
};

if (_confirmedState == 2 && {_invalid == 0}) then {
    [
        _className,
        _cost,
        _minTier,
        _lastPosASL,
        _lastDir,
        _surfaceRule,
        _requiredUnlock,
        _isTier5,
        owner player
    ] remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    true
} else {
    [["VEHICLE MENU", _lastReason], "warning"] call MWF_fnc_showNotification;
    false
};
