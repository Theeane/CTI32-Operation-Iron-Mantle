if (!hasInterface) exitWith { false };
if (vehicle player != player) exitWith {
    hint "Exit your vehicle before building.";
    false
};

params [
    ["_entry", [], [[]]],
    ["_sourceTerminal", objNull, [objNull]]
];
if ((count _entry) < 4) exitWith { false };

[] call MWF_fnc_cleanupVehicleBuildSession;

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

private _vehicleType = "LAND";
private _surfaceRule = "LAND";
if (_className isKindOf ["Ship", configFile >> "CfgVehicles"]) then {
    _vehicleType = "WATER";
    _surfaceRule = "WATER";
} else {
    if (_className isKindOf ["Air", configFile >> "CfgVehicles"]) then {
        _vehicleType = "AIR";
    };
};

private _size = sizeOf _className;
if (_size <= 0) then {
    _size = switch (_vehicleType) do {
        case "WATER": { 12 };
        case "AIR": { 10 };
        default { 6 };
    };
};

private _dist = 0.6 * _size;
if (_dist < 3.5) then { _dist = 3.5; };
_dist = _dist + 1;
if (_vehicleType isEqualTo "WATER") then { _dist = _dist + 8; };
if (_vehicleType isEqualTo "AIR") then { _dist = _dist + 3; };

build_confirmed = 1;
build_invalid = 0;
if (isNil "build_rotation") then { build_rotation = 0; } else { build_rotation = 0; };
if (isNil "build_elevation") then { build_elevation = 0; } else { build_elevation = 0; };

missionNamespace setVariable ["MWF_VehicleBuild_Active", true];
missionNamespace setVariable ["MWF_VehicleBuild_Entry", +_entry];
missionNamespace setVariable ["MWF_VehicleBuild_Class", _className];
missionNamespace setVariable ["MWF_VehicleBuild_Cost", _cost];
missionNamespace setVariable ["MWF_VehicleBuild_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehicleBuild_DisplayName", _displayName];
missionNamespace setVariable ["MWF_VehicleBuild_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehicleBuild_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehicleBuild_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_VehicleBuild_Type", _vehicleType];
missionNamespace setVariable ["MWF_VehicleBuild_SurfaceRule", _surfaceRule];
missionNamespace setVariable ["MWF_VehicleBuild_PreviewDistance", _dist];
missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehicleBuild_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehicleBuild_LastReason", "Placement invalid."];
missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", []];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];

private _ghostSpot = (markerPos "respawn_west") vectorAdd [0,0,1000];
private _vehicle = _className createVehicleLocal _ghostSpot;
if (isNull _vehicle) exitWith {
    [] call MWF_fnc_cleanupVehicleBuildSession;
    false
};

clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;
_vehicle allowDamage false;
_vehicle setVehicleLock "LOCKED";
_vehicle enableSimulation false;
_vehicle setVariable ["MWF_isGhostPreview", true];
_vehicle disableCollisionWith player;
missionNamespace setVariable ["MWF_VehicleBuild_Ghost", _vehicle];
player forceWalk true;

private _idCancel = player addAction [
    "<t color='#B0FF00'>Cancel</t>",
    "functions\terminal\MWF_fnc_vehicleBuildCancel.sqf",
    "", -725, false, true, "", "build_confirmed == 1"
];
private _idRotate = player addAction [
    "<t color='#B0FF00'>Rotate</t>",
    "functions\terminal\MWF_fnc_vehicleBuildRotate.sqf",
    "", -750, false, false, "", "build_confirmed == 1"
];
private _idRaise = player addAction [
    "<t color='#B0FF00'>Raise</t>",
    "functions\terminal\MWF_fnc_vehicleBuildRaise.sqf",
    "", -765, false, false, "", "build_confirmed == 1"
];
private _idLower = player addAction [
    "<t color='#B0FF00'>Lower</t>",
    "functions\terminal\MWF_fnc_vehicleBuildLower.sqf",
    "", -766, false, false, "", "build_confirmed == 1"
];
private _idPlace = player addAction [
    "<t color='#B0FF00'>Place</t>",
    "functions\terminal\MWF_fnc_vehicleBuildPlace.sqf",
    "", -775, false, true, "", "build_invalid == 0 && build_confirmed == 1"
];
missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", [_idCancel, _idRotate, _idRaise, _idLower, _idPlace]];

private _colorGhost = {
    params ["_ghostObj", "_valid"];
    if (isNull _ghostObj) exitWith {};
    private _tex = if (_valid) then { '#(rgb,8,8,3)color(0,1,0,0.80)' } else { '#(rgb,8,8,3)color(1,0,0,0.65)' };
    for '_i' from 0 to 12 do {
        _ghostObj setObjectTexture [_i, _tex];
    };
};
[_vehicle, true] call _colorGhost;

while {build_confirmed == 1 && alive player} do {
    private _truedir = 90 - (getDir player);
    private _truepos = [
        ((getPos player) select 0) + (_dist * (cos _truedir)),
        ((getPos player) select 1) + (_dist * (sin _truedir)),
        0
    ];
    private _actualdir = (getDir player) + build_rotation;
    while {_actualdir > 360} do { _actualdir = _actualdir - 360; };
    while {_actualdir < 0} do { _actualdir = _actualdir + 360; };

    _vehicle setDir _actualdir;

    private _finalPos = [_truepos select 0, _truepos select 1, (_truepos select 2) + build_elevation];
    private _validation = [_className, _finalPos, _actualdir, _vehicle, _sourceTerminal, _vehicleType] call MWF_fnc_validateVehicleBuildPlacement;
    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];

    if (_isValid) then {
        if (_vehicleType isEqualTo "WATER") then {
            _vehicle setPosASL (AGLToASL _finalPos);
            _vehicle setVectorUp [0,0,1];
        } else {
            _vehicle setPos _finalPos;
            if (_vehicleType isEqualTo "AIR") then {
                _vehicle setVectorUp [0,0,1];
            } else {
                _vehicle setVectorUp surfaceNormal position _vehicle;
            };
        };
        build_invalid = 0;
        missionNamespace setVariable ["MWF_VehicleBuild_LastPosASL", getPosASL _vehicle];
        missionNamespace setVariable ["MWF_VehicleBuild_LastDir", getDir _vehicle];
        [_vehicle, true] call _colorGhost;
    } else {
        _vehicle setPos _ghostSpot;
        build_invalid = 1;
        [_vehicle, false] call _colorGhost;
    };

    missionNamespace setVariable ["MWF_VehicleBuild_LastReason", _reason];
    uiSleep 0.01;
};

private _finalPosASL = missionNamespace getVariable ["MWF_VehicleBuild_LastPosASL", getPosASL _vehicle];
private _finalDir = missionNamespace getVariable ["MWF_VehicleBuild_LastDir", getDir _vehicle];
private _finalReason = missionNamespace getVariable ["MWF_VehicleBuild_LastReason", "Placement invalid."];
private _confirmedState = build_confirmed;

[] call MWF_fnc_cleanupVehicleBuildSession;

if (_confirmedState == 2) then {
    [
        _className,
        _cost,
        _minTier,
        _finalPosASL,
        _finalDir,
        _surfaceRule,
        _requiredUnlock,
        _isTier5
    ] remoteExec ["MWF_fnc_serverPurchasePlacedVehicle", 2];
} else {
    systemChat "Vehicle placement cancelled.";
};

true
