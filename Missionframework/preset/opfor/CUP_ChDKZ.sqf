/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ChDKZ
    Project: Military War Framework

    Description:
    Defines the opfor preset configuration for CUP ChDKZ.
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
        "CUP_O_INS_Soldier_AA",              // AA Specialist
        "CUP_O_INS_Soldier_Exp"              // Explosives Expert
    ]],
    ["Infantry_T5", [
        "CUP_O_INS_Soldier_Engineer",        // Engineer
        "CUP_O_INS_Story_Lopotev",           // High Command (Lopotev)
        "CUP_O_INS_Officer"                  // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_UAZ_Open_CHDKZ",              // UAZ (Open)
        "CUP_O_Ural_CHDKZ"                   // Ural Transport
    ]],
    ["Vehicles_T2", [
        "CUP_O_UAZ_MG_CHDKZ",                // UAZ (DShKM)
        "CUP_O_BTR60_CHDKZ"                  // BTR-60PB
    ]],
    ["Vehicles_T3", [
        "CUP_O_BRDM2_CHDKZ",                 // BRDM-2
        "CUP_O_BMP2_CHDKZ"                   // BMP-2
    ]],
    ["Vehicles_T4", [
        "CUP_O_T55_CHDKZ",                   // T-55
        "CUP_O_Ural_ZU23_CHDKZ"              // Ural (ZU-23)
    ]],
    ["Vehicles_T5", [
        "CUP_O_T72_CHDKZ",                   // T-72
        "CUP_O_Mi8_CHDKZ",                   // Mi-8MT
        "CUP_O_Su25_Dyn_RU"                  // Su-25 Frogfoot
    ]],

    ["Leader", "CUP_O_INS_Commander"],
    ["Pilot", "CUP_O_INS_Pilot"]
];
