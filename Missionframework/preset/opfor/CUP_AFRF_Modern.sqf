/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_AFRF_Modern
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CUP AFRF Modern using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_O_RU_Soldier_M_EMR",            // Rifleman
        "CUP_O_RU_Soldier_Saiga_M_EMR",      // Rifleman (Lite)
        "CUP_O_RU_Medic_M_EMR"               // Medic
    ]],
    ["Infantry_T2", [
        "CUP_O_RU_Soldier_GL_M_EMR",         // Grenadier
        "CUP_O_RU_Soldier_AR_M_EMR",         // Autorifleman
        "CUP_O_RU_Soldier_TL_M_EMR"          // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_O_RU_Soldier_AT_M_EMR",         // AT Specialist
        "CUP_O_RU_Soldier_MG_M_EMR",         // Heavy Gunner
        "CUP_O_RU_Soldier_SL_M_EMR"          // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_O_RU_Soldier_Marksman_M_EMR",   // Marksman
        "CUP_O_RU_Soldier_AA_M_EMR",         // Anti-Air Specialist
        "CUP_O_RU_Soldier_Engineer_M_EMR"    // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_O_RU_Sharpshooter_M_EMR",       // Sniper
        "CUP_O_RU_HeavyUnit_01_M_EMR",       // Heavy Unit (Elite)
        "CUP_O_RU_Officer_M_EMR"             // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_RU_Truck_02_transport_M_EMR"   // Light Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "CUP_O_RU_MRAP_02_hmg_M_EMR"          // MRAP (Heavy Machine Gun)
    ]],
    ["Vehicles_T3", [
        "CUP_O_RU_APC_Wheeled_02_rcws_v2_M_EMR",   // APC (Marid)
        "CUP_O_RU_APC_Tracked_02_cannon_M_EMR"      // APC (BTR-K Kamysh)
    ]],
    ["Vehicles_T4", [
        "CUP_O_RU_MBT_02_cannon_M_EMR",       // T-100 Varsuk
        "CUP_O_RU_APC_Tracked_02_AA_M_EMR"    // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "CUP_O_RU_MBT_04_cannon_M_EMR",       // T-140 Angara
        "CUP_O_RU_Heli_Attack_02_dynamicLoadout_M_EMR"  // Mi-48 Kajman
    ]],
    ["Leader", "CUP_O_RU_Officer_M_EMR"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CUP_AFRF_Modern.sqf (OPFOR) Loaded.";
