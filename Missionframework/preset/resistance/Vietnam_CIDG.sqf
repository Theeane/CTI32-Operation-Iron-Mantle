/*
    Author: Theane / ChatGPT
    Function: Preset - Vietnam_CIDG
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for Vietnam CIDG.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
    ["Infantry_T1", [
        "uns_men_CIDG_S1",                   // Rifleman (M1 Carbine)
        "uns_men_CIDG_S2",                   // Rifleman (M2 Carbine)
        "uns_men_CIDG_MED"                   // Medic
    ]],
    ["Infantry_T2", [
        "uns_men_CIDG_GL",                   // Grenadier
        "uns_men_CIDG_AR",                   // Autorifleman
        "uns_men_CIDG_TL"                    // Team Leader
    ]],
    ["Infantry_T3", [
        "uns_men_CIDG_SL",                   // Squad Leader
        "uns_men_CIDG_M",                    // Marksman
        "uns_men_CIDG_ENG"                   // Engineer
    ]],
    ["Infantry_T4", [
        "uns_men_CIDG_AA",                   // AA Specialist
        "uns_men_CIDG_AT",                   // AT Specialist
        "uns_men_CIDG_MG"                    // HMG Assistant
    ]],
    ["Infantry_T5", [
        "uns_men_CIDG_SNIPER",                // Sniper
        "uns_men_CIDG_EXP"                   // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "uns_veh_CIDG_Truck", 
        "uns_veh_CIDG_MRAP"                  // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "uns_veh_CIDG_MRAP_HMG",             // MRAP (HMG)
        "uns_veh_CIDG_MRAP_GMG"              // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "uns_veh_CIDG_Vehicle_Radar",        // Radar Vehicle
        "uns_veh_CIDG_Vehicle_Cannon"        // Cannon Vehicle
    ]],
    ["Vehicles_T4", [
        "uns_veh_CIDG_Armor",                // Gorgon (Tracked)
        "uns_veh_CIDG_Tracked_APC"           // Mora
    ]],
    ["Vehicles_T5", [
        "uns_veh_CIDG_MBT",                  // Main Battle Tank
        "uns_veh_CIDG_Armed_Helicopter",     // Armed Helicopter
        "uns_veh_CIDG_Fighter_Aircraft"      // Fighter Aircraft
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "uns_men_CIDG_Officer"],
    ["Pilot",  "uns_men_CIDG_Pilot"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: Vietnam_CIDG.sqf (RESISTANCE) Loaded.";
