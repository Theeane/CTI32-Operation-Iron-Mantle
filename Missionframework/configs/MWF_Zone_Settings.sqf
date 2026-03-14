/*
    Author: Theane / ChatGPT
    Function: MWF_Zone_Settings
    Project: Military War Framework

    Description:
    Defines zone configuration values used by the framework.
*/

MWF_Zone_Tier_Settings = createHashMapFromArray [
    // Tier | [Supplies Income, Intel Bonus, Enemy Count Multiplier]
    [1, [25, 1, 0.5]],  // Tiny Outpost / Village
    [2, [50, 2, 0.8]],  // Small Town
    [3, [100, 5, 1.2]], // Strategic City
    [4, [250, 10, 1.8]],// Military Base / Airport
    [5, [600, 25, 2.5]] // Capital / Fortress
];

// Global capture settings
MWF_Zone_CaptureRange = 150; 
MWF_Zone_CaptureTime  = 60; // Seconds to hold a zone after it's cleared

diag_log "[Iron Mantle] Zone Settings loaded.";
