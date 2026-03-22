/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_AFRF_EMR
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CUP AFRF EMR using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_O_RU_Soldier_EMR",             // Rifleman
        "CUP_O_RU_Soldier_Saiga_EMR",       // Rifleman (Lite)
        "CUP_O_RU_Medic_EMR"                // Medic
    ]],
    ["Infantry_T2", [
        "CUP_O_RU_Soldier_GL_EMR",          // Grenadier
        "CUP_O_RU_Soldier_AR_EMR",          // Autorifleman
        "CUP_O_RU_Soldier_TL_EMR"           // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_O_RU_Soldier_AT_EMR",          // AT Specialist
        "CUP_O_RU_Soldier_MG_EMR",          // Heavy Gunner
        "CUP_O_RU_Soldier_SL_EMR"           // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_O_RU_Soldier_Marksman_EMR",    // Marksman
        "CUP_O_RU_Soldier_AA_EMR",          // Anti-Air Specialist
        "CUP_O_RU_Soldier_Engineer_EMR"     // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_O_RU_Sharpshooter_EMR",        // Sharpshooter
        "CUP_O_RU_HeavyUnit_01_EMR",        // Heavy Unit (Elite)
        "CUP_O_RU_Officer_EMR"              // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_RU_Truck_02_transport_EMR"   // Light Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "CUP_O_RU_MRAP_02_hmg_EMR"          // MRAP (Heavy Machine Gun)
    ]],
    ["Vehicles_T3", [
        "CUP_O_RU_APC_Wheeled_02_rcws_v2_EMR",   // Infantry Fighting Vehicle
        "CUP_O_RU_APC_Tracked_02_cannon_EMR"      // BTR-K Kamysh
    ]],
    ["Vehicles_T4", [
        "CUP_O_RU_MBT_02_cannon_EMR",       // T-100 Varsuk
        "CUP_O_RU_APC_Tracked_02_AA_EMR"    // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "CUP_O_RU_MBT_04_cannon_EMR",       // T-140 Angara
        "CUP_O_RU_Heli_Attack_02_dynamicLoadout_EMR"  // Mi-48 Kajman
    ]],
    ["Leader", "CUP_O_RU_Officer_EMR"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CUP_AFRF_EMR.sqf (OPFOR) Loaded.";
