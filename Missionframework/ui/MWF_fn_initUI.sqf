/*
    Author: Theane / ChatGPT
    Function: MWF_fn_initUI
    Project: Military War Framework

    Description:
    Handles UI logic for init UI.
    Strict migration from original fn_initUI.sqf.
*/

if (!hasInterface) exitWith {};

// Wait for CBA to be ready before adding settings
if (isNil "CBA_fnc_addSetting") exitWith {
    diag_log "[MWF] UI Error: CBA not found. UI Settings could not be initialized.";
};

// --- HUD POSITION SETTING ---
[
    "MWF_UI_Position", // Variable name used in scripts
    "LIST",            // Type: Dropdown list
    ["HUD Position", "Choose where the Resource Bar and Undercover Eye are displayed."], // Description
    "AGS Framework",   // Category in CBA menu
    [
        [0, 1, 2],     // Internal values
        ["Center Right (KP Style)", "Center Left", "Hidden"], // Display names
        0              // Default value (0 = Center Right)
    ],
    nil,               // Global? No, this is a local client setting
    { 
        // CODE TO RUN ON CHANGE
        // Updated to use the new MWF_fnc_ prefix
        [] spawn MWF_fnc_updateResourceUI; 
    }
] call CBA_fnc_addSetting;

// --- HUD OPACITY SETTING ---
[
    "MWF_UI_Opacity", 
    "SLIDER", 
    ["HUD Opacity", "Adjust the transparency of the background."], 
    "AGS Framework", 
    [0.1, 1, 0.5, 1], // Min, Max, Default, Decimals
    nil, 
    { [] spawn MWF_fnc_updateResourceUI; }
] call CBA_fnc_addSetting;

diag_log "[MWF] UI: Client settings registered successfully.";
