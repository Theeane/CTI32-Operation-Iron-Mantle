/*
    Author: Theane / ChatGPT
    Function: Preset - Contact
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for Contact using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "O_R_Soldier_unarmed_F",            // Rifleman (Unarmed)
        "O_R_medic_F",                      // Medic
        "O_R_Soldier_LAT_F"                 // Rifleman (LAT)
    ]],
    ["Infantry_T2", [
        "O_R_Soldier_GL_F",                 // Grenadier
        "O_R_Soldier_AR_F",                 // Autorifleman
        "O_R_soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "O_R_JTAC_F",                       // JTAC
        "O_R_soldier_exp_F",                // Explosives Specialist
        "O_R_soldier_SL_F"                  // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_R_marksman_F",                   // Marksman
        "O_R_soldier_M_F",                  // Heavy Gunner
        "O_R_soldier_AA_F"                  // Anti-Air Specialist
    ]],
    ["Infantry_T5", [
        "O_R_Sharpshooter_F",               // Sniper
        "O_R_Special_Forces_F",             // Special Forces (Heavy)
        "O_R_Officer_F"                     // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "O_R_Truck_02_transport_F"          // Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "O_R_MRAP_02_hmg_F"                 // MRAP HMG
    ]],
    ["Vehicles_T3", [
        "O_R_APC_Wheeled_02_rcws_v2_F",     // APC
        "O_R_APC_Tracked_02_cannon_F"       // BTR-K Kamysh
    ]],
    ["Vehicles_T4", [
        "O_R_MBT_02_cannon_F",              // T-100 Varsuk
        "O_R_APC_Tracked_02_AA_F"           // Tigris (AA)
    ]],
    ["Vehicles_T5", [
        "O_R_MBT_04_cannon_F",              // T-140 Angara
        "O_R_Heli_Attack_02_dynamicLoadout_F" // Mi-48 Kajman
    ]],
    ["Leader", "O_R_Officer_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: Contact.sqf (OPFOR) Loaded.";