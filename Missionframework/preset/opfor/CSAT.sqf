/*
    Author: Theane / ChatGPT
    Function: Preset - CSAT (OPFOR)
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CSAT using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "O_Soldier_F",                      // Rifleman
        "O_Soldier_LAT_F",                  // Rifleman (LAT)
        "O_Medic_F"                         // Medic
    ]],
    ["Infantry_T2", [
        "O_Soldier_GL_F",                   // Grenadier
        "O_Soldier_AR_F",                   // Autorifleman
        "O_Soldier_TL_F"                    // Team Leader
    ]],
    ["Infantry_T3", [
        "O_Soldier_AT_F",                   // AT Specialist
        "O_Soldier_MG_F",                   // Heavy Gunner
        "O_Soldier_SL_F"                    // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_marksman_F",                     // Marksman
        "O_Soldier_AA_F",                   // AA Specialist
        "O_engineer_F"                      // Engineer
    ]],
    ["Infantry_T5", [
        "O_Sharpshooter_F",                 // Sharpshooter
        "O_HeavyUnit_01_F",                 // Urban Entity (Heavy)
        "O_Officer_F"                       // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "O_Truck_02_transport_F",           // Zamak Transport
        "O_LSV_02_unarmed_F"                // Qilin (Unarmed)
    ]],
    ["Vehicles_T2", [
        "O_LSV_02_armed_F",                 // Qilin (Minigun)
        "O_MRAP_02_hmg_F"                   // Ifrit (HMG)
    ]],
    ["Vehicles_T3", [
        "O_APC_Wheeled_02_rcws_v2_F",       // Marid
        "O_APC_Tracked_02_cannon_F"         // BTR-K Kamysh
    ]],
    ["Vehicles_T4", [
        "O_MBT_02_cannon_F",                // T-100 Varsuk
        "O_APC_Tracked_02_AA_F"             // Tigris (AA)
    ]],
    ["Vehicles_T5", [
        "O_MBT_04_cannon_F",                // T-140 Angara
        "O_Heli_Attack_02_dynamicLoadout_F" // Mi-48 Kajman
    ]],
    ["Leader", "O_Officer_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CSAT.sqf (OPFOR) Loaded.";