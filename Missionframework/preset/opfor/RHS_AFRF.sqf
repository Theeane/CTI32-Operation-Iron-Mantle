/*
    Author: Theane / ChatGPT
    Function: Preset - RHS_AFRF
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for RHS AFRF using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "RHS_O_Soldier",                      // Rifleman
        "RHS_O_Soldier_Medic",                 // Medic
        "RHS_O_Soldier_LAT"                    // Rifleman (LAT)
    ]],
    ["Infantry_T2", [
        "RHS_O_Soldier_GL",                    // Grenadier
        "RHS_O_Soldier_AR",                    // Autorifleman
        "RHS_O_Soldier_TL"                     // Team Leader
    ]],
    ["Infantry_T3", [
        "RHS_O_Soldier_AT",                    // AT Specialist
        "RHS_O_Soldier_MG",                    // Heavy Gunner
        "RHS_O_Soldier_SL"                     // Squad Leader
    ]],
    ["Infantry_T4", [
        "RHS_O_Marksman",                      // Marksman
        "RHS_O_Soldier_AA",                    // AA Specialist
        "RHS_O_Engineer"                       // Engineer
    ]],
    ["Infantry_T5", [
        "RHS_O_Sharpshooter",                  // Sharpshooter
        "RHS_O_Officer"                        // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "RHS_O_Ural_4320",                     // Light Transport Vehicle
        "RHS_O_LSV_M2",                        // Light Support Vehicle
    ]],
    ["Vehicles_T2", [
        "RHS_O_MRAP_M1151",                    // MRAP (Heavy Machine Gun)
        "RHS_O_LAV25",                         // Light Armored Vehicle
    ]],
    ["Vehicles_T3", [
        "RHS_O_BMP2",                          // Infantry Fighting Vehicle (IFV)
        "RHS_O_T80U"                           // Main Battle Tank
    ]],
    ["Vehicles_T4", [
        "RHS_O_MBT_T90",                       // Main Battle Tank (T-90)
        "RHS_O_BTR80A"                         // APC (BTR-80A)
    ]],
    ["Vehicles_T5", [
        "RHS_O_MBT_T80BVM",                    // Heavy Main Battle Tank (T-80BVM)
        "RHS_O_Mi24V"                          // Attack Helicopter (Mi-24V)
    ]],
    ["Leader", "RHS_O_Officer"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: RHS_AFRF.sqf (OPFOR) Loaded.";