/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBuyMenu
    Project: Military War Framework

    Description:
    Command Network entry point.
    The legacy buy menu is retired in favor of the unified Data Hub / Base Upgrades flow.
*/

if (!hasInterface) exitWith {false};

params [
    ["_terminal", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

missionNamespace setVariable ["MWF_CommandTerminal_Object", _terminal];
missionNamespace setVariable ["MWF_CommandTerminal_User", _caller];

["OPEN"] call MWF_fnc_dataHub;
["SET_MODE", "UPGRADES"] call MWF_fnc_dataHub;

diag_log "[MWF] Command Network opened via unified Data Hub.";
true
