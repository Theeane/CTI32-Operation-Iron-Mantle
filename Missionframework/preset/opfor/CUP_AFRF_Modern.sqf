/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_AFRF_Modern
    Project: Military War Framework

    Description:
    Defines the opfor preset configuration for CUP AFRF Modern.
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
        "CUP_O_RU_Soldier_AA_M_EMR",         // AA Specialist
        "CUP_O_RU_Engineer_M_EMR"            // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_O_RU_Sniper_M_EMR",             // Sniper
        "CUP_O_RU_Soldier_HAT_M_EMR",        // Heavy AT
        "CUP_O_RU_Officer_M_EMR"             // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_UAZ_Open_RU",                 // UAZ (Open)
        "CUP_O_Ural_RU"                      // Ural Transport
    ]],
    ["Vehicles_T2", [
        "CUP_O_GAZ_Vodnik_PK_RU",            // Vodnik (PKM)
        "CUP_O_BTR80_CAMO_RU"                // BTR-80
    ]],
    ["Vehicles_T3", [
        "CUP_O_BMP2_RU",                     // BMP-2
        "CUP_O_BTR80A_CAMO_RU"               // BTR-80A
    ]],
    ["Vehicles_T4", [
        "CUP_O_T72_RU",                      // T-72
        "CUP_O_2S6M_RU"                      // Tunguska (AA)
    ]],
    ["Vehicles_T5", [
        "CUP_O_T90_RU",                      // T-90
        "CUP_O_Mi24_V_Dynamic_RU",           // Mi-24V Hind
        "CUP_O_Su25_Dyn_RU"                  // Su-25 Frogfoot
    ]],

    ["Leader", "CUP_O_RU_Officer_M_EMR"],
    ["Pilot", "CUP_O_RU_Pilot"]
];
