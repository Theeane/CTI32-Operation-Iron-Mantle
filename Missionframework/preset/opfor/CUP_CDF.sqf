/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_CDF
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CUP CDF using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_B_CDF_Militia_FST",             // Militia
        "CUP_B_CDF_Soldier_FST",             // Rifleman
        "CUP_B_CDF_Medic_FST"                // Medic
    ]],
    ["Infantry_T2", [
        "CUP_B_CDF_Soldier_GL_FST",          // Grenadier
        "CUP_B_CDF_Soldier_AR_FST",          // Autorifleman
        "CUP_B_CDF_Soldier_TL_FST"           // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_B_CDF_Soldier_RPG18_FST",       // AT Specialist
        "CUP_B_CDF_Soldier_MG_FST",          // Heavy Gunner
        "CUP_B_CDF_Officer_FST"              // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_B_CDF_Soldier_Marksman_FST",    // Marksman
        "CUP_B_CDF_Soldier_AA_FST",          // AA Specialist
        "CUP_B_CDF_Soldier_Engineer_FST"     // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_B_CDF_Sharpshooter_FST",        // Sniper
        "CUP_B_CDF_HeavyUnit_01_FST",        // Heavy Unit (Elite)
        "CUP_B_CDF_Officer_FST"              // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_B_CDF_Truck_02_transport_FST"   // Light Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "CUP_B_CDF_MRAP_02_hmg_FST"          // MRAP (Heavy Machine Gun)
    ]],
    ["Vehicles_T3", [
        "CUP_B_CDF_APC_Wheeled_02_rcws_v2_FST",   // APC
        "CUP_B_CDF_APC_Tracked_02_cannon_FST"      // APC (BTR-K Kamysh)
    ]],
    ["Vehicles_T4", [
        "CUP_B_CDF_MBT_02_cannon_FST",       // Main Battle Tank
        "CUP_B_CDF_APC_Tracked_02_AA_FST"    // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "CUP_B_CDF_MBT_04_cannon_FST",       // Main Battle Tank (T-140 Angara)
        "CUP_B_CDF_Heli_Attack_02_dynamicLoadout_FST" // Attack Helicopter (Mi-48 Kajman)
    ]],
    ["Leader", "CUP_B_CDF_Officer_FST"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CUP_CDF.sqf (OPFOR) Loaded.";