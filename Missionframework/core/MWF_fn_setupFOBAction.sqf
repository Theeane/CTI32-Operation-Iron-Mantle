/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupFOBAction
    Project: Military War Framework

    Description:
    Legacy compatibility wrapper. Older call sites still invoke setupFOBAction for FOB
    containers, but the active deployment pipeline now lives in MWF_fnc_initFOB.
*/

params [["_container", objNull, [objNull]]];

if (isNull _container) exitWith {};
[_container] call MWF_fnc_initFOB;
