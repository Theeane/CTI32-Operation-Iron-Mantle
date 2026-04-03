/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_validateGhostPlacement
    Project: Military War Framework

    Description:
    Unified KP-inspired ghost validation used by both vehicle placement and
    physical base-upgrade placement. Invalid placement should only change
    preview state, never kill the placement session.

    Returns:
    [isValid, reason]
*/

params [
    ["_mode", "vehicle", [""]],
    ["_className", "", [""]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_context", createHashMap, [createHashMap]]
];

if (_className isEqualTo "") exitWith { [false, "Placement data missing."] };

private _posATL = ASLToATL _posASL;
private _isWater = surfaceIsWater [_posATL # 0, _posATL # 1];
private _modeUpper = toUpper _mode;

if (_modeUpper isEqualTo "VEHICLE") then {
    private _profile = _context getOrDefault ["profile", []];
    if (_profile isEqualTo []) exitWith { [false, "Vehicle placement profile missing."] };
    _profile params [
        ["_vehicleType", "LAND", [""]],
        ["_surfaceRule", "LAND", [""]],
        ["_previewDistance", 8, [0]],
        ["_previewHeight", 0, [0]],
        ["_diameter", 4, [0]],
        ["_safetyRadius", 3, [0]]
    ];

    if (_surfaceRule isEqualTo "WATER" && {!_isWater}) exitWith { [false, "Watercraft must be placed on water."] };
    if (_surfaceRule isEqualTo "LAND" && {_isWater}) exitWith { [false, "This vehicle must be placed on land."] };

    private _ghost = _context getOrDefault ["ghost", objNull];
    private _near = nearestObjects [_posATL, ["LandVehicle", "Ship", "Air", "Building", "House", "CAManBase"], (_safetyRadius max 3) + 8, true];
    private _blockingObject = objNull;
    {
        if (!isNull _x && {_x != _ghost} && {_x != player}) then {
            private _otherRadius = if (_x isKindOf "CAManBase") then {
                0.9
            } else {
                private _otherDiameter = sizeOf (typeOf _x);
                if (_otherDiameter <= 0) then { _otherDiameter = 2; };
                ((_otherDiameter * 0.35) max 1.2)
            };
            private _minClearance = ((_safetyRadius * 0.45) max 2.1) + (_otherRadius * 0.55);
            if ((_x distance2D _posATL) < _minClearance) exitWith { _blockingObject = _x; };
        };
    } forEach _near;

    if (!isNull _blockingObject) exitWith {
        private _label = if (_blockingObject isKindOf "CAManBase") then { "nearby unit" } else { getText (configFile >> "CfgVehicles" >> typeOf _blockingObject >> "displayName") };
        if (_label isEqualTo "") then { _label = typeOf _blockingObject; };
        [false, format ["Placement blocked by %1.", _label]]
    };

    [true, "Placement valid."]
} else {
    if (_isWater) exitWith { [false, "This structure must be placed on land."] };

    private _ghost = _context getOrDefault ["ghost", objNull];
    private _diameter = sizeOf _className;
    if (_diameter <= 0) then { _diameter = 6; };
    private _safetyRadius = ((_diameter * 0.45) max 2.5) min 10;
    private _near = nearestObjects [_posATL, ["Building", "House", "LandVehicle", "Air", "Ship", "CAManBase"], _safetyRadius + 6, true];
    private _blocking = objNull;
    {
        if (!isNull _x && {_x != player} && {_x != _ghost}) then {
            private _otherRadius = if (_x isKindOf "CAManBase") then {
                0.9
            } else {
                private _otherDiameter = sizeOf (typeOf _x);
                if (_otherDiameter <= 0) then { _otherDiameter = 2; };
                ((_otherDiameter * 0.35) max 1.2)
            };
            private _minClearance = ((_safetyRadius * 0.5) max 2.0) + (_otherRadius * 0.5);
            if ((_x distance2D _posATL) < _minClearance) exitWith { _blocking = _x; };
        };
    } forEach _near;

    if (!isNull _blocking) exitWith {
        private _label = if (_blocking isKindOf "CAManBase") then { "nearby unit" } else { getText (configFile >> "CfgVehicles" >> typeOf _blocking >> "displayName") };
        if (_label isEqualTo "") then { _label = typeOf _blocking; };
        [false, format ["Placement blocked by %1.", _label]]
    };

    [true, "Placement valid."]
};
