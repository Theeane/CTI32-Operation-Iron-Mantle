/*
    Author: Theane / ChatGPT
    Function: Preset - Custom 1 (Safe Fallback)
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for Resistance Custom 1 safe fallback.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
    ["Infantry_T1", [
        "I_soldier_F",                      // Rifleman (Light)
        "I_Soldier_LAT_F",                  // Rifleman (AT)
        "I_medic_F"                         // Medic
    ]],
    ["Infantry_T2", [
        "I_Soldier_GL_F",                   // Grenadier
        "I_Soldier_AR_F",                   // Autorifleman
        "I_Soldier_TL_F"                    // Team Leader
    ]],
    ["Infantry_T3", [
        "I_Soldier_SL_F",                   // Squad Leader
        "I_Soldier_M_F",                    // Marksman
        "I_engineer_F"                      // Engineer
    ]],
    ["Infantry_T4", [
        "I_Soldier_AA_F",                   // AA Specialist
        "I_Soldier_AT_F",                   // AT Specialist
        "I_support_MG_F"                    // HMG Assistant
    ]],
    ["Infantry_T5", [
        "I_ghillie_ard_F",                  // Sniper (Arid)
        "I_ghillie_lsh_F",                  // Sniper (Lush)
        "I_Soldier_exp_F"                   // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "I_Truck_02_transport_F", 
        "I_MRAP_03_F"                       // Strider (Unarmed)
    ]],
    ["Vehicles_T2", [
        "I_MRAP_03_hmg_F",                  // Strider (HMG)
        "I_MRAP_03_gmg_F"                   // Strider (GMG)
    ]],
    ["Vehicles_T3", [
        "I_LT_01_scout_F",                  // Nyx (Radar)
        "I_LT_01_cannon_F"                  // Nyx (Autocannon)
    ]],
    ["Vehicles_T4", [
        "I_APC_Wheeled_03_cannon_F",        // Gorgon
        "I_APC_tracked_03_cannon_F"         // Mora
    ]],
    ["Vehicles_T5", [
        "I_MBT_03_cannon_F",                // Kuma (MBT)
        "I_Heli_light_03_dynamicLoadout_F", // WY-55 Hellcat (Armed)
        "I_Plane_Fighter_03_dynamicLoadout_F" // A-143 Buzzard (CAS)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "I_Officer_F"],
    ["Pilot",  "I_helipilot_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: Custom 1.sqf (RESISTANCE) Loaded.";
