/*
    Author: Theeane / Gemini
    Function: MWF_fn_openBuyMenu
    Project: Military War Framework

    Description:
    Entry point for the Command Network.
    This function bridges the physical terminal interaction to the unified Data Hub UI, defaulting to the zones overview.
*/

if (!hasInterface) exitWith { false };

params [
    ["_terminal", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _terminal || isNull _caller) exitWith {
    diag_log "[MWF] Error: openBuyMenu called with null terminal or caller.";
    false
};

// Set global references so the Data Hub knows which terminal is being accessed
missionNamespace setVariable ["MWF_CommandTerminal_Object", _terminal];
missionNamespace setVariable ["MWF_CommandTerminal_User", _caller];

// Open the Data Hub UI and default to the zones overview
["OPEN", "ZONES"] call MWF_fnc_dataHub;

diag_log format ["[MWF] Command Network: UI opened by %1 at terminal %2.", name _caller, _terminal];

true