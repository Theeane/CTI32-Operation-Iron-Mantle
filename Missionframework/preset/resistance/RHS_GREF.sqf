/*
    Author: Theane / ChatGPT
    Function: Preset - RHS_GREF
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for RHS GREF.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
    ["Infantry_T1", [
        "rhsgref_ins_g_rifleman",            // Rifleman
        "rhsgref_ins_g_rifleman_akm",        // Rifleman (AKM)
        "rhsgref_ins_g_medic"                // Medic
    ]],
    ["Infantry_T2", [
        "rhsgref_ins_g_grenadier",           // Grenadier
        "rhsgref_ins_g_autorifleman",        // Autorifleman
        "rhsgref_ins_g_teamleader"           // Team Leader
    ]],
    ["Infantry_T3", [
        "rhsgref_ins_g_squadleader",         // Squad Leader
        "rhsgref_ins_g_marksman",            // Marksman
        "rhsgref_ins_g_engineer"             // Engineer
    ]],
    ["Infantry_T4", [
        "rhsgref_ins_g_aa",                  // AA Specialist
        "rhsgref_ins_g_at",                  // AT Specialist
        "rhsgref_ins_g_mg"                   // HMG Assistant
    ]],
    ["Infantry_T5", [
        "rhsgref_ins_g_sniper",              // Sniper
        "rhsgref_ins_g_explosive"            // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "rhsgref_ins_g_truck", 
        "rhsgref_ins_g_mrap"                 // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "rhsgref_ins_g_mrap_hmg",            // MRAP (HMG)
        "rhsgref_ins_g_mrap_gmg"             // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "rhsgref_ins_g_vehicle_radar",       // Radar Vehicle
        "rhsgref_ins_g_vehicle_cannon"      // Cannon Vehicle
    ]],
    ["Vehicles_T4", [
        "rhsgref_ins_g_armor",               // Gorgon (Tracked)
        "rhsgref_ins_g_tracked_apc"          // Mora
    ]],
    ["Vehicles_T5", [
        "rhsgref_ins_g_mbt",                 // Main Battle Tank
        "rhsgref_ins_g_armed_heli",          // Armed Helicopter
        "rhsgref_ins_g_fighter_aircraft"     // Fighter Aircraft
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "rhsgref_ins_g_officer"],
    ["Pilot",  "rhsgref_ins_g_helipilot"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: RHS_GREF.sqf (RESISTANCE) Loaded.";
