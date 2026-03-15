/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_NAPA
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for CUP NAPA.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
    ["Infantry_T1", [
        "CUP_I_GUE_Soldier_AKS74",           // Rifleman
        "CUP_I_GUE_Soldier_AK74",            // Rifleman (AK74)
        "CUP_I_GUE_Medic"                    // Medic
    ]],
    ["Infantry_T2", [
        "CUP_I_GUE_Soldier_GL",              // Grenadier
        "CUP_I_GUE_Soldier_AR",              // Autorifleman
        "CUP_I_GUE_Soldier_TL"               // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_I_GUE_Soldier_SL",              // Squad Leader
        "CUP_I_GUE_Soldier_M",               // Marksman
        "CUP_I_GUE_Engineer"                 // Engineer
    ]],
    ["Infantry_T4", [
        "CUP_I_GUE_Soldier_AA",              // AA Specialist
        "CUP_I_GUE_Soldier_AT",              // AT Specialist
        "CUP_I_GUE_Support_MG"               // HMG Assistant
    ]],
    ["Infantry_T5", [
        "CUP_I_GUE_Soldier_Sniper",          // Sniper
        "CUP_I_GUE_Soldier_Explosive"        // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "CUP_I_GUE_Truck", 
        "CUP_I_GUE_MRAP"                      // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "CUP_I_GUE_MRAP_HMG",                 // MRAP (HMG)
        "CUP_I_GUE_MRAP_GMG"                  // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "CUP_I_GUE_Vehicle_Radar",            // Radar Vehicle
        "CUP_I_GUE_Vehicle_Cannon"            // Cannon Vehicle
    ]],
    ["Vehicles_T4", [
        "CUP_I_GUE_Armored_Vehicle",          // Gorgon (Tracked)
        "CUP_I_GUE_Tracked_APC"               // Mora
    ]],
    ["Vehicles_T5", [
        "CUP_I_GUE_MBT",                      // Main Battle Tank
        "CUP_I_GUE_Armed_Heli",               // Armed Helicopter
        "CUP_I_GUE_Fighter_Aircraft"          // Fighter Aircraft
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "CUP_I_GUE_Officer"],
    ["Pilot",  "CUP_I_GUE_HelicopterPilot"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: CUP_NAPA.sqf (RESISTANCE) Loaded.";
