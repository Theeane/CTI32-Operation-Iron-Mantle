/*
    Author: Theane
    Description: Client-side initialization.
*/

if (!hasInterface) exitWith {};

// 1. Register CBA Settings (Position, Opacity)
[] call AGS_fnc_initUI;

// 2. Setup the "Hold Action" on the HQ Terminal
// Note: Ensure you have an object named 'AGS_HQ_Terminal' in the editor!
if (!isNil "AGS_HQ_Terminal") then {
    [AGS_HQ_Terminal] call AGS_fnc_setupInteractions;
};

diag_log "AGS Framework: Client-side initialization complete.";
