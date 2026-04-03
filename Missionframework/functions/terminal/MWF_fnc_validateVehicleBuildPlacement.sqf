/*
    Author: OpenAI
    Function: MWF_fnc_validateVehicleBuildPlacement
    Project: Military War Framework

    Description:
    KP-style vehicle placement validation.
*/

params [
    ["_className", "", [""]],
    ["_posASL", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_profile", [], [[]]],
    ["_ghost", objNull, [objNull]],
    ["_sourceTerminal", objNull, [objNull]]
];

if (_className isEqualTo "") exitWith { [false, "Placement data missing."] };

private _posATL = ASLToATL _posASL;
private _vehicleType = _profile param [0, "LAND"];
private _surfaceRule = _profile param [1, "LAND"];
private _diameter = _profile param [4, 4];
private _safetyRadius = _profile param [5, 3];
private _searchRadius = (_diameter max 4) + 2;
private _isWater = surfaceIsWater [_posATL select 0, _posATL select 1];

if (_surfaceRule isEqualTo "WATER" && {!_isWater}) exitWith { [false, "Boats must be placed in water."] };
if (_surfaceRule isEqualTo "LAND" && {_isWater}) exitWith { [false, "This vehicle must be placed on land."] };

private _near = nearestObjects [_posATL, ["AllVehicles", "Static", "House", "Building"], _searchRadius, true];
private _blocking = [];
{
    if (
        !isNull _x &&
        {_x != _ghost} &&
        {_x != player} &&
        {_x != _sourceTerminal} &&
        {!(_x isKindOf "CAManBase")} &&
        {!(_x isKindOf "Animal")} &&
        {!(_x isKindOf "Logic")} &&
        {!(_x isKindOf "Land_HelipadEmpty_F")} &&
        {!(_x getVariable ["MWF_GhostPreview", false])}
    ) then {
        private _otherRadius = 1.25;
        private _otherSize = sizeOf (typeOf _x);
        if (_otherSize > 0) then {
            _otherRadius = (_otherSize * 0.35) max 1.25;
        };
        if ((_x distance2D _posATL) < ((_safetyRadius * 0.75) + (_otherRadius * 0.75))) then {
            _blocking pushBack _x;
        };
    };
} forEach _near;

if ((count _blocking) > 0) exitWith {
    private _name = getText (configFile >> "CfgVehicles" >> typeOf (_blocking select 0) >> "displayName");
    if (_name isEqualTo "") then { _name = typeOf (_blocking select 0); };
    [false, format ["Placement blocked by %1.", _name]]
};

[true, "Placement valid."]
