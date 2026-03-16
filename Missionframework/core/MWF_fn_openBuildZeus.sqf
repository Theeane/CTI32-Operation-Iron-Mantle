/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBuildZeus
    Project: Military War Framework

    Description:
    Legacy wrapper that now forwards into the unified Base Architect flow.
*/

if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];
[_terminal] call MWF_fnc_openBaseArchitect;
