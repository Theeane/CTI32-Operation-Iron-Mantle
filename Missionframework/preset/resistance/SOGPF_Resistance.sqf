/*
    Author: Theane / Gemini
    Function: Preset - SOGPF_Resistance (Independent)
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for SOGPF using authentic Independent (vn_i_) classes.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Independent / Local Forces) ---
    ["Infantry_T1", [
        "vn_i_men_vc_05",                  // Rifleman (Type 56)
        "vn_i_men_vc_01",                  // Medic
        "vn_i_men_vc_14"                   // Scout
    ]],
    ["Infantry_T2", [
        "vn_i_men_vc_07",                  // Grenadier
        "vn_i_men_vc_11",                  // Light MG (RPK)
        "vn_i_men_vc_17"                   // Team Leader
    ]],
    ["Infantry_T3", [
        "vn_i_men_vc_06",                  // Squad Leader
        "vn_i_men_vc_13",                  // Marksman
        "vn_i_men_vc_09"                   // Engineer
    ]],
    ["Infantry_T4", [
        "vn_i_men_vc_12",                  // AT Specialist (B41)
        "vn_i_men_vc_10",                  // Machine Gunner (PK)
        "vn_i_men_vc_18"                   // Cell Leader
    ]],
    ["Infantry_T5", [
        "vn_i_men_vc_local_20",            // Elite Local Fighter
        "vn_i_men_vc_local_27",            // Elite Marksman
        "vn_i_men_vc_01"                   // Officer
    ]],

    // --- VEHICLE POOLS (Independent / Captured) ---
    ["Vehicles_T1", [
        "vn_i_wheeled_m151_01",            // M151 Jeep (Unarmed)
        "vn_i_wheeled_z157_01"             // Z-157 Transport
    ]],
    ["Vehicles_T2", [
        "vn_i_wheeled_m151_mg_01",         // M151 (M60)
        "vn_i_wheeled_btr40_mg_01"         // BTR-40 (MG)
    ]],
    ["Vehicles_T3", [
        "vn_i_wheeled_z157_mg_01",         // Z-157 (DShK)
        "vn_i_armor_type63"                // Type 63 (Light Tank)
    ]],
    ["Vehicles_T4", [
        "vn_i_armor_m41_01",               // M41 Walker Bulldog (Captured)
        "vn_i_wheeled_btr40_mg_03"         // BTR-40 (Anti-Air)
    ]],
    ["Vehicles_T5", [
        "vn_i_armor_t54b",                 // T-54B (Main Battle Tank)
        "vn_i_air_mi2_01"                  // Mi-2 (Transport/Armed)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "vn_i_men_vc_01"],
    ["Pilot",  "vn_i_men_air_01"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: SOGPF_Resistance.sqf (Independent) Loaded.";
