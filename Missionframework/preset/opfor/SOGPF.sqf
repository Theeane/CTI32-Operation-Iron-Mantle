/*
    Author: Theane / ChatGPT
    Function: Preset - SOGPF (OPFOR Vietnam)
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for SOGPF (Vietnam War mod) using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "vn_men_soldier_rifle",             // Rifleman (M16)
        "vn_men_soldier_medic",             // Medic
        "vn_men_soldier_lat"                // Rifleman (LAT)
    ]],
    ["Infantry_T2", [
        "vn_men_soldier_grenadier",         // Grenadier
        "vn_men_soldier_lmg",               // Light Machine Gunner
        "vn_men_soldier_teamleader"         // Team Leader
    ]],
    ["Infantry_T3", [
        "vn_men_soldier_at",                // AT Specialist (M72 LAW)
        "vn_men_soldier_mg",                // Heavy Gunner
        "vn_men_soldier_squadleader"        // Squad Leader
    ]],
    ["Infantry_T4", [
        "vn_men_marksman",                  // Marksman
        "vn_men_soldier_aa",                // AA Specialist
        "vn_men_soldier_engineer"           // Engineer
    ]],
    ["Infantry_T5", [
        "vn_men_sharpshooter",              // Sharpshooter
        "vn_men_officer"                    // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "vn_vhc_jeep",                      // Light Transport Vehicle
        "vn_vhc_truck"                      // Light Transport Truck
    ]],
    ["Vehicles_T2", [
        "vn_vhc_mrap",                      // MRAP (Heavy Machine Gun)
        "vn_vhc_lsv"                        // Light Support Vehicle
    ]],
    ["Vehicles_T3", [
        "vn_vhc_apc",                       // APC (Infantry Fighting Vehicle)
        "vn_vhc_btr60"                      // BTR-60 (IFV)
    ]],
    ["Vehicles_T4", [
        "vn_vhc_mbt",                       // Main Battle Tank (T-72)
        "vn_vhc_tigris"                     // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "vn_vhc_mbt_advanced",              // T-90 (Elite Tank)
        "vn_vhc_heli_attack"                // Mi-24V (Attack Helicopter)
    ]]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: SOGPF.sqf (OPFOR Vietnam) Loaded.";
