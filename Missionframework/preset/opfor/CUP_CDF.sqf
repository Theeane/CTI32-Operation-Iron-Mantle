/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_CDF
    Project: Military War Framework

    Description:
    Defines the opfor preset configuration for CUP CDF.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
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
        "CUP_B_CDF_Engineer_FST"             // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_B_CDF_Soldier_SN_FST",          // Sniper
        "CUP_B_CDF_Commander_FST",           // Commander
        "CUP_B_CDF_Officer_FST"              // Officer
    ]],

    ["Vehicles_T1", [
        "CUP_B_UAZ_Open_CDF",                // UAZ
        "CUP_B_Ural_CDF"                     // Ural
    ]],
    ["Vehicles_T2", [
        "CUP_B_UA_MG_CDF",                   // UAZ (DSHKM)
        "CUP_B_BTR60_CDF"                    // BTR-60
    ]],
    ["Vehicles_T3", [
        "CUP_B_BMP2_CDF",                    // BMP-2
        "CUP_B_BTR80A_CDF"                   // BTR-80A
    ]],
    ["Vehicles_T4", [
        "CUP_B_T72_CDF",                     // T-72
        "CUP_B_ZSU23_CDF"                    // Shilka
    ]],
    ["Vehicles_T5", [
        "CUP_B_T72_CDF",                     // T-72 (Modernized)
        "CUP_B_Mi24_D_Dynamic_CDF",          // Mi-24D Hind
        "CUP_B_Su25_Dyn_CDF"                 // Su-25
    ]],

    ["Leader", "CUP_B_CDF_Commander_FST"],
    ["Pilot", "CUP_B_CDF_Pilot_FST"]
];
