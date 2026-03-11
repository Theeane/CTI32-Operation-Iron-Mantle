/* Author: Theeane
    Description: 
    Central configuration for Zone Tiers. 
    Defines income, intel bonuses, and enemy scaling.
*/

GVAR_Zone_Tier_Settings = createHashMapFromArray [
    // Tier | [Supplies Income, Intel Bonus, Enemy Count Multiplier]
    [1, [25, 1, 0.5]],  // Tiny Outpost / Village
    [2, [50, 2, 0.8]],  // Small Town
    [3, [100, 5, 1.2]], // Strategic City
    [4, [250, 10, 1.8]],// Military Base / Airport
    [5, [600, 25, 2.5]] // Capital / Fortress
];

// Global capture settings
GVAR_Zone_CaptureRange = 150; 
GVAR_Zone_CaptureTime  = 60; // Seconds to hold a zone after it's cleared

diag_log "[Iron Mantle] Zone Settings loaded.";
