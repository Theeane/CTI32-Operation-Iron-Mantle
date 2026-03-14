/*
    Author: Theane / ChatGPT
    Function: Preset - RHS_AFRF
    Project: Military War Framework

    Description:
    Defines the opfor preset configuration for RHS AFRF.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "rhs_msv_emr_rifleman",              // Rifleman
        "rhs_msv_emr_LAT",                   // Rifleman (LAT)
        "rhs_msv_emr_medic"                  // Medic
    ]],
    ["Infantry_T2", [
        "rhs_msv_emr_grenadier",             // Grenadier
        "rhs_msv_emr_arifleman",             // Autorifleman
        "rhs_msv_emr_sergeant"               // Sergeant
    ]],
    ["Infantry_T3", [
        "rhs_msv_emr_at",                    // AT Specialist
        "rhs_msv_emr_machinegunner",         // Heavy Gunner
        "rhs_msv_emr_officer"                // Officer
    ]],
    ["Infantry_T4", [
        "rhs_msv_emr_marksman",              // Marksman
        "rhs_msv_emr_aa",                    // AA Specialist
        "rhs_msv_emr_engineer"               // Engineer
    ]],
    ["Infantry_T5", [
        "rhs_msv_emr_recon_rifleman",        // Recon Rifleman
        "rhs_msv_emr_recon_marksman",        // Recon Marksman
        "rhs_msv_emr_recon_at"               // Recon AT
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "rhs_uaz_open_MSV_01",               // UAZ (Open)
        "RHS_Ural_Open_MSV_01"               // Ural Transport
    ]],
    ["Vehicles_T2", [
        "rhs_tigr_sts_msv",                  // Tigr-M (STS)
        "rhs_btr80_msv"                      // BTR-80
    ]],
    ["Vehicles_T3", [
        "rhs_bmp2d_msv",                     // BMP-2D
        "rhs_btr80a_msv"                     // BTR-80A
    ]],
    ["Vehicles_T4", [
        "rhs_t72ba_tv",                      // T-72BA
        "rhs_zsu234_aa"                      // Shilka (AA)
    ]],
    ["Vehicles_T5", [
        "rhs_t90a_tv",                       // T-90A
        "RHS_Ka52_vvsc",                     // Ka-52 Alligator
        "RHS_Su25SM_vvsc"                    // Su-25SM Frogfoot
    ]],

    // --- Special Classes ---
    ["Leader", "rhs_msv_emr_officer"],
    ["Pilot", "rhs_pilot_combat_heli"]
];
