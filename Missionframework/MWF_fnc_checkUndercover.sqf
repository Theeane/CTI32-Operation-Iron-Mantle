/*
    Legacy compatibility wrapper. Routes old undercover calls to the active central implementation.
*/

params [["_player", objNull, [objNull]]];

if (isNil "MWF_fnc_checkUndercover") exitWith { false };

[_player] call MWF_fnc_checkUndercover
