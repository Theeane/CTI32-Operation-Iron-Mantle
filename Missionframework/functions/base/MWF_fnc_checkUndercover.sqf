/*
    Legacy compatibility wrapper. Routes base-path undercover calls to the active central implementation.
*/

params [["_unit", objNull, [objNull]]];

if (isNil "MWF_fnc_checkUndercover") exitWith { false };

[_unit] call MWF_fnc_checkUndercover
