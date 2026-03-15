/*
    Author: Theane / ChatGPT
    Function: Preset - LDF_Resistance
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for LDF Resistance.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Forest Warfare Standard) ---
    ["Infantry_T1", [
        "I_E_Soldier_F",                    // Rifleman
        "I_E_Soldier_LAT_F",                // Rifleman (AT)
        "I_E_Medic_F"                       // Medic
    ]],
    ["Infantry_T2", [
        "I_E_Soldier_GL_F",                 // Grenadier
        "I_E_Soldier_AR_F",                 // Autorifleman
        "I_E_Soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "I_E_Soldier_SL_F",                 // Squad Leader
        "I_E_Soldier_M_F",                  // Marksman
        "I_E_Engineer_F"                    // Engineer
    ]],
    ["Infantry_T4", [
        "I_E_Soldier_AA_F",                 // AA Specialist
        "I_E_Soldier_AT_F",                 // AT Specialist
        "I_E_support_MG_F"                  // HMG Assistant
    ]],
    ["Infantry_T5", [
        "I_E_ghillie_ard_F",                // Sniper (Arid)
        "I_E_ghillie_lsh_F",                // Sniper (Lush)
        "I_E_Soldier_exp_F"                 // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "I_E_Truck_02_transport_F", 
        "I_E_MRAP_03_F"                     // Strider (Unarmed)
    ]],
    ["Vehicles_T2", [
        "I_E_MRAP_03_hmg_F",                // Strider (HMG)
        "I_E_MRAP_03_gmg_F"                 // Strider (GMG)
    ]],
    ["Vehicles_T3", [
        "I_E_LT_01_scout_F",                // Nyx (Radar)
        "I_E_LT_01_cannon_F"                // Nyx (Autocannon)
    ]],
    ["Vehicles_T4", [
        "I_E_APC_Wheeled_03_cannon_F",      // Gorgon
        "I_E_APC_tracked_03_cannon_F"       // Mora
    ]],
    ["Vehicles_T5", [
        "I_E_MBT_03_cannon_F",              // Kuma (MBT)
        "I_E_Heli_light_03_dynamicLoadout_F", // WY-55 Hellcat (Armed)
        "I_E_Plane_Fighter_03_dynamicLoadout_F" // A-143 Buzzard (CAS)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "I_E_Officer_F"],
    ["Pilot",  "I_E_helipilot_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: LDF_Resistance.sqf (RESISTANCE) Loaded.";
