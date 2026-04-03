/*
    Simple KP-style validator used only by the new vehicle preview core.
*/

params [
    ["_className", "", [""]],
    ["_posASL", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_profile", [], [[]]],
    ["_ghost", objNull, [objNull]],
    ["_sourceTerminal", objNull, [objNull]]
];

if (_className isEqualTo "") exitWith { [false, "Vehicle class missing."] };

_profile params [
    ["_vehicleType", "LAND", [""]],
    ["_surfaceRule", "LAND", [""]],
    ["_previewDistance", 8, [0]],
    ["_previewHeight", 0.2, [0]],
    ["_diameter", 4, [0]],
    ["_safetyRadius", 3, [0]],
    ["_bbox", [2, 4, 2], [[]]]
];

private _posATL = ASLToATL _posASL;
private _isWater = surfaceIsWater [_posATL select 0, _posATL select 1];
if ((_surfaceRule isEqualTo "WATER") && {!_isWater}) exitWith { [false, "Watercraft must be placed on water."] };
if ((_surfaceRule isEqualTo "LAND") && {_isWater}) exitWith { [false, "This vehicle must be placed on land."] };

private _dist = 0.6 * (sizeOf _className);
if (_dist < 4) then { _dist = 4; };
_dist = _dist + 1;

private _near = (_posATL nearObjects ["AllVehicles", _dist]);
_near = _near + (_posATL nearObjects ["Static", _dist]);
_near = _near + (_posATL nearObjects ["Thing", _dist]);
_near = _near + (_posATL nearObjects ["Building", _dist]);

private _blocking = objNull;
{
    if (!isNull _x && {_x != _ghost} && {_x != player} && {_x != _sourceTerminal}) then {
        if !(_x isKindOf "CAManBase") then {
            _blocking = _x;
        };
    };
    if (!isNull _blocking) exitWith {};
} forEach _near;

if (!isNull _blocking) exitWith {
    private _label = getText (configFile >> "CfgVehicles" >> typeOf _blocking >> "displayName");
    if (_label isEqualTo "") then { _label = typeOf _blocking; };
    [false, format ["Placement blocked by %1.", _label]]
};

[true, "Placement valid."]
