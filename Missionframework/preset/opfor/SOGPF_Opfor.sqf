/*
    Author: Theane / ChatGPT / Gemini
    Function: Preset - SOGPF (OPFOR Vietnam)
    Project: Military War Framework
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers (NVA - North Vietnamese Army) ---
    ["Infantry_T1", [
        "vn_o_men_nva_05",                  // Rifleman (Type 56)
        "vn_o_men_nva_01",                  // Medic
        "vn_o_men_nva_14"                   // Scout
    ]],
    ["Infantry_T2", [
        "vn_o_men_nva_07",                  // Grenadier (M79)
        "vn_o_men_nva_11",                  // Light MG (RPK)
        "vn_o_men_nva_01"                   // Team Leader
    ]],
    ["Infantry_T3", [
        "vn_o_men_nva_12",                  // AT Specialist (B41/RPG7)
        "vn_o_men_nva_10",                  // Machine Gunner (PK)
        "vn_o_men_nva_01"                   // Squad Leader
    ]],
    ["Infantry_T4", [
        "vn_o_men_nva_13",                  // Marksman (SVD)
        "vn_o_men_nva_43",                  // AA Specialist (Strela)
        "vn_o_men_nva_09"                   // Engineer
    ]],
    ["Infantry_T5", [
        "vn_o_men_nva_65",                  // Dak Cong (Spec Ops)
        "vn_o_men_nva_64",                  // Dak Cong SL
        "vn_o_men_nva_01"                   // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "vn_o_wheeled_z157_01",             // Z-157 Transport
        "vn_o_wheeled_btr40_01"             // BTR-40 (Unarmed)
    ]],
    ["Vehicles_T2", [
        "vn_o_wheeled_btr40_mg_01",          // BTR-40 (MG)
        "vn_o_wheeled_z157_mg_01"           // Z-157 (MG)
    ]],
    ["Vehicles_T3", [
        "vn_o_wheeled_btr40_mg_03",          // BTR-40 (AA/Heavy)
        "vn_o_armor_type63"                 // Type 63 (Light Tank)
    ]],
    ["Vehicles_T4", [
        "vn_o_armor_t54b",                  // T-54B (Main Battle Tank)
        "vn_o_wheeled_z157_mg_02"           // Z-157 (Anti-Air)
    ]],
    ["Vehicles_T5", [
        "vn_o_armor_ot34_01",               // Flame Tank / Advanced MBT
        "vn_o_air_mi2_04_05"                // Mi-2 (Attack Variant)
    ]],
    ["Leader", "vn_o_men_nva_01"]
];

publicVariable "MWF_OPFOR_Preset";
diag_log "[MWF] Preset: SOGPF.sqf (OPFOR Vietnam) Loaded.";