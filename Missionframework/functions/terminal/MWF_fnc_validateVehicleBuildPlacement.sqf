/*
    KP-style simple placement validation for vehicle ghost build.
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
private _surfaceRule = toUpper (_profile param [1, "LAND"]);
private _diameter = _profile param [4, 4];
private _dist = (0.6 * _diameter) max 3.5;
private _isWater = surfaceIsWater _posATL;

if (_surfaceRule isEqualTo "WATER" && {!_isWater}) exitWith { [false, "Boats must be placed in water."] };
if (_surfaceRule isEqualTo "LAND" && {_isWater}) exitWith { [false, "This vehicle must be placed on land."] };

private _nearObjects = nearestObjects [_posATL, ["AllVehicles", "Static", "House", "Building"], _dist, true];
private _blocking = [];
{
    private _type = typeOf _x;
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
        _blocking pushBack _x;
    };
} forEach _nearObjects;

if ((count _blocking) > 0) exitWith {
    private _name = getText (configFile >> "CfgVehicles" >> typeOf (_blocking select 0) >> "displayName");
    if (_name isEqualTo "") then { _name = typeOf (_blocking select 0); };
    [false, format ["Placement blocked by %1.", _name]]
};

[true, "Placement valid."]
