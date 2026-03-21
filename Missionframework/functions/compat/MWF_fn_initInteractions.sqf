params [["_object", objNull, [objNull]]];
if (isNull _object) exitWith {};

if (_object isKindOf "CAManBase") exitWith {
    [_object] call MWF_fnc_initActions;
};

[_object] call MWF_fnc_setupInteractions;
