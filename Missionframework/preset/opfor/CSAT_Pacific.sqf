/*
    Author: Theane / ChatGPT
    Function: Preset - CSAT_Pacific
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CSAT Pacific using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "O_T_Soldier_F",                    // Rifleman
        "O_T_Soldier_LAT_F",                // Rifleman (LAT)
        "O_T_Medic_F"                       // Medic
    ]],
    ["Infantry_T2", [
        "O_T_Soldier_GL_F",                 // Grenadier
        "O_T_Soldier_AR_F",                 // Autorifleman
        "O_T_Soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "O_T_Soldier_AT_F",                 // AT Specialist
        "O_T_Soldier_MG_F",                 // Heavy Gunner
        "O_T_Soldier_SL_F"                  // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_T_Marksman_F",                   // Marksman
        "O_T_Soldier_AA_F",                 // AA Specialist
        "O_T_Engineer_F"                    // Engineer
    ]],
    ["Infantry_T5", [
        "O_T_Sharpshooter_F",               // Sniper
        "O_T_HeavyUnit_01_F",               // Urban Entity (Heavy)
        "O_T_Officer_F"                     // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "O_T_Truck_02_transport_F",           // Transport Vehicle
        "O_T_LSV_02_unarmed_F"                // Light Vehicle (Unarmed)
    ]],
    ["Vehicles_T2", [
        "O_T_LSV_02_armed_F",                 // Armed Light Vehicle
        "O_T_MRAP_02_hmg_F"                   // MRAP (HMG)
    ]],
    ["Vehicles_T3", [
        "O_T_APC_Wheeled_02_rcws_v2_F",       // APC (Marid)
        "O_T_APC_Tracked_02_cannon_F"         // APC (BTR-K Kamysh)
    ]],
    ["Vehicles_T4", [
        "O_T_MBT_02_cannon_F",                // Main Battle Tank (T-100 Varsuk)
        "O_T_APC_Tracked_02_AA_F"             // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "O_T_MBT_04_cannon_F",                // Main Battle Tank (T-140 Angara)
        "O_T_Heli_Attack_02_dynamicLoadout_F" // Mi-48 Kajman Attack Helicopter
    ]],
    ["Leader", "O_T_Officer_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CSAT_Pacific.sqf (OPFOR) Loaded.";
