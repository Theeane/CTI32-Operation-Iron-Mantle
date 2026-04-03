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

private _surfaceRule = if (_className isKindOf "Ship") then { "WATER" } else { "LAND" };
private _ghostMarkerPos = if ((getMarkerColor "ghost_spot") != "") then { markerPos "ghost_spot" } else { markerPos "respawn_west" };
private _ghostSpot = _ghostMarkerPos findEmptyPosition [0, 100, _className];
if (_ghostSpot isEqualTo []) then { _ghostSpot = _ghostMarkerPos vectorAdd [0, 0, 1000]; };

private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith { false };

_ghost allowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulationGlobal false;
_ghost disableCollisionWith player;
_ghost setVariable ["MWF_IsVehiclePreview", true];
clearWeaponCargo _ghost;
clearMagazineCargo _ghost;
clearItemCargo _ghost;
clearBackpackCargo _ghost;
for "_i" from 0 to 12 do {
    _ghost setObjectTexture [_i, '#(rgb,8,8,3)color(0,1,0,0.8)'];
};

private _dist = 0.6 * (sizeOf _className);
if (_dist < 3.5) then { _dist = 3.5; };
_dist = _dist + 1;

build_confirmed = 1;
build_invalid = 0;
if (isNil "build_rotation") then { build_rotation = 0; } else { build_rotation = 0; };
if (isNil "build_elevation") then { build_elevation = 0; } else { build_elevation = 0; };

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehiclePlacement_SurfaceRule", _surfaceRule];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];

private _idactcancel = player addAction ["<t color='#B0FF00'>Cancel Placement</t>", { [] call MWF_fnc_vehicleBuildCancel; }, "", -725, false, true, "", "build_confirmed == 1"];
private _idactrotate = player addAction ["<t color='#B0FF00'>Rotate</t>", { [] call MWF_fnc_vehicleBuildRotate; }, "", -750, false, false, "", "build_confirmed == 1"];
private _idactraise  = player addAction ["<t color='#B0FF00'>Raise</t>", { [] call MWF_fnc_vehicleBuildRaise; }, "", -765, false, false, "", "build_confirmed == 1"];
private _idactlower  = player addAction ["<t color='#B0FF00'>Lower</t>", { [] call MWF_fnc_vehicleBuildLower; }, "", -766, false, false, "", "build_confirmed == 1"];
private _idactplace  = player addAction ["<t color='#B0FF00'>Place Vehicle</t>", { [] call MWF_fnc_vehicleBuildPlace; }, "", -775, false, true, "", "build_invalid == 0 && build_confirmed == 1"];

missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _idactcancel];
missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _idactrotate];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _idactraise];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _idactlower];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _idactplace];

while { build_confirmed == 1 && alive player } do {
    private _truedir = 90 - (getDir player);
    private _truepos = if (_surfaceRule isEqualTo "WATER") then {
        [((getPosATL player) select 0) + (_dist * (cos _truedir)), ((getPosATL player) select 1) + (_dist * (sin _truedir)), ((getPosATL player) select 2)]
    } else {
        [((getPos player) select 0) + (_dist * (cos _truedir)), ((getPos player) select 1) + (_dist * (sin _truedir)), 0]
    };

    private _actualdir = (getDir player) + build_rotation;
    while { _actualdir > 360 } do { _actualdir = _actualdir - 360; };
    while { _actualdir < 0 } do { _actualdir = _actualdir + 360; };
    _ghost setDir _actualdir;

    _truepos = [_truepos select 0, _truepos select 1, (_truepos select 2) + build_elevation];

    private _validation = [_className, _truepos, _dist, _ghost, _sourceTerminal] call MWF_fnc_validateVehicleBuildPlacement;
    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];

    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];
    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];

    if (_isValid) then {
        if (_surfaceRule isEqualTo "WATER") then {
            _ghost setPosASL (ATLToASL _truepos);
            _ghost setVectorUp [0, 0, 1];
            missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", ATLToASL _truepos];
        } else {
            _ghost setPos _truepos;
            _ghost setVectorUp (surfaceNormal position _ghost);
            missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL _ghost];
        };
        missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _actualdir];
        if (build_invalid == 1) then {
            for "_i" from 0 to 12 do { _ghost setObjectTexture [_i, '#(rgb,8,8,3)color(0,1,0,0.8)']; };
        };
        build_invalid = 0;
    } else {
        if (build_invalid == 0) then {
            for "_i" from 0 to 12 do { _ghost setObjectTexture [_i, '#(rgb,8,8,3)color(1,0,0,0.6)']; };
        };
        _ghost setPos _ghostSpot;
        build_invalid = 1;
    };

    uiSleep 0.05;
};

private _finalState = build_confirmed;
private _finalValid = (build_invalid == 0) && (missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false]);
private _finalPosASL = missionNamespace getVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
private _finalDir = missionNamespace getVariable ["MWF_VehiclePlacement_LastDir", getDir player];
private _finalReason = missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."];

[] call MWF_fnc_cleanupVehiclePlacement;

if (_finalState == 2 && _finalValid) exitWith {
    [_className, _cost, _minTier, _finalPosASL, _finalDir, _surfaceRule, _requiredUnlock, _isTier5] remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    true
};

if (_finalState == 2 && !_finalValid) exitWith {
    systemChat _finalReason;
    false
};

false
