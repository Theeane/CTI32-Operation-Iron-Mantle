params [
    ["_mode", "vehicle", [""]],
    ["_className", "", [""]],
    ["_posASL", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_context", createHashMap, [createHashMap]]
];

if ((toUpper _mode) isEqualTo "VEHICLE") exitWith {
    [
        _className,
        _posASL,
        _dir,
        (_context getOrDefault ["profile", []]),
        (_context getOrDefault ["ghost", objNull]),
        (_context getOrDefault ["terminal", objNull])
    ] call MWF_fnc_validateVehicleBuildPlacement
};

_this call compile preprocessFileLineNumbers "functions\terminal\MWF_fnc_validateGhostPlacement_legacy_build_only.sqf"
