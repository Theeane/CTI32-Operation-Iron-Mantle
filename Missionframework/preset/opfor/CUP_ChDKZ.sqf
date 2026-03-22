/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ChDKZ
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for CUP ChDKZ using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_O_INS_Soldier",                // Rifleman (Lite)
        "CUP_O_INS_Soldier_AK74",           // Rifleman
        "CUP_O_INS_Medic"                   // Medic
    ]],
    ["Infantry_T2", [
        "CUP_O_INS_Soldier_GL",              // Grenadier
        "CUP_O_INS_Soldier_AR",              // Autorifleman
        "CUP_O_INS_Officer"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_O_INS_Soldier_AT",              // AT Specialist
        "CUP_O_INS_Soldier_MG",              // Heavy Gunner
        "CUP_O_INS_Commander"               // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_O_INS_Sniper",                  // Sniper
        "CUP_O_INS_Soldier_AA",              // Anti-Air Specialist
        "CUP_O_INS_Soldier_Engineer"         // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_O_INS_Sharpshooter",            // Sharpshooter
        "CUP_O_INS_HeavyUnit_01",            // Heavy Unit (Elite)
        "CUP_O_INS_Officer"                  // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_INS_Truck_02_transport"       // Light Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "CUP_O_INS_MRAP_02_hmg"              // MRAP (Heavy Machine Gun)
    ]],
    ["Vehicles_T3", [
        "CUP_O_INS_APC_Wheeled_02_rcws_v2",   // APC
        "CUP_O_INS_APC_Tracked_02_cannon"     // APC (BTR-K Kamysh)
    ]],
    ["Vehicles_T4", [
        "CUP_O_INS_MBT_02_cannon",            // Main Battle Tank
        "CUP_O_INS_APC_Tracked_02_AA"         // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "CUP_O_INS_MBT_04_cannon",            // Main Battle Tank (T-140 Angara)
        "CUP_O_INS_Heli_Attack_02_dynamicLoadout"  // Mi-48 Kajman Attack Helicopter
    ]],
    ["Leader", "CUP_O_INS_Officer"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: CUP_ChDKZ.sqf (OPFOR) Loaded.";
