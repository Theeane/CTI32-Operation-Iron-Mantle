/*
    Unified entry into build mode.
    All curator creation/cleanup now lives inside MWF_fnc_openBaseArchitect.
*/
if (!hasInterface) exitWith { false };

params [["_terminal", objNull, [objNull]]];

["CLOSE"] call MWF_fnc_dataHub;
closeDialog 0;
[_terminal] spawn MWF_fnc_openBaseArchitect;
true
