/* Vehicle hard-cut wrapper: vehicles no longer use the old generic ghost placement core. */
if (!hasInterface) exitWith { false };
if !(canSuspend) exitWith { _this spawn MWF_fnc_startGhostPlacement; true };

params [
    ["_mode", "vehicle", [""]],
    ["_payload", [], [[]]],
    ["_sourceTerminal", objNull, [objNull]]
];

if ((toUpper _mode) isEqualTo "VEHICLE") exitWith {
    [_payload, _sourceTerminal] spawn MWF_fnc_startVehicleBuildSession;
    true
};

/* Keep old build path untouched for non-vehicle use. */
_this call compile preprocessFileLineNumbers "functions\terminal\MWF_fnc_startGhostPlacement_legacy_build_only.sqf"
