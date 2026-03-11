/* PRESET: CUP AFRF (EMR Standard)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_O_RU_Soldier_EMR",              // Rifleman
        "CUP_O_RU_Soldier_Saiga_EMR",        // Rifleman (Lite)
        "CUP_O_RU_Medic_EMR"                 // Medic
    ]],
    ["Infantry_T2", [
        "CUP_O_RU_Soldier_GL_EMR",           // Grenadier
        "CUP_O_RU_Soldier_AR_EMR",           // Autorifleman
        "CUP_O_RU_Soldier_TL_EMR"            // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_O_RU_Soldier_AT_EMR",           // AT Specialist
        "CUP_O_RU_Soldier_MG_EMR",           // Heavy Gunner
        "CUP_O_RU_Soldier_SL_EMR"            // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_O_RU_Soldier_Marksman_EMR",     // Marksman
        "CUP_O_RU_Soldier_AA_EMR",           // AA Specialist
        "CUP_O_RU_Engineer_EMR"              // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_O_RU_Sniper_EMR",               // Sniper
        "CUP_O_RU_Soldier_HAT_EMR",          // Heavy AT
        "CUP_O_RU_Officer_EMR"               // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_O_UAZ_Open_RU",                 // UAZ (Open)
        "CUP_O_Ural_RU"                      // Ural Transport
    ]],
    ["Vehicles_T2", [
        "CUP_O_GAZ_Vodnik_PK_RU",            // Vodnik (PKM)
        "CUP_O_BTR80_GREEN_RU"               // BTR-80 (Green)
    ]],
    ["Vehicles_T3", [
        "CUP_O_BMP2_RU",                     // BMP-2
        "CUP_O_BTR90_RU"                     // BTR-90
    ]],
    ["Vehicles_T4", [
        "CUP_O_T72_RU",                      // T-72
        "CUP_O_2S6M_RU"                      // Tunguska (AA)
    ]],
    ["Vehicles_T5", [
        "CUP_O_T90_RU",                      // T-90
        "CUP_O_Mi24_P_Dynamic_RU",           // Mi-24P Hind
        "CUP_O_Su25_Dyn_RU"                  // Su-25 Frogfoot
    ]],

    // --- Special Classes ---
    ["Leader", "CUP_O_RU_Officer_EMR"],
    ["Pilot", "CUP_O_RU_Pilot"]
];
