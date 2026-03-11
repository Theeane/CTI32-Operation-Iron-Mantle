/* PRESET: CUP NAPA (National Party)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "CUP_I_GUE_Soldier_AKS74",           // Rifleman
        "CUP_I_GUE_Soldier_AK74",           // Rifleman (AK74)
        "CUP_I_GUE_Medic"                   // Medic
    ]],
    ["Infantry_T2", [
        "CUP_I_GUE_Soldier_GL",              // Grenadier
        "CUP_I_GUE_Soldier_AR",              // Autorifleman
        "CUP_I_GUE_Officer"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "CUP_I_GUE_Soldier_AT",              // AT Specialist
        "CUP_I_GUE_Soldier_MG",              // Heavy Gunner
        "CUP_I_GUE_Commander"               // Squad Leader
    ]],
    ["Infantry_T4", [
        "CUP_I_GUE_Sniper",                  // Sniper
        "CUP_I_GUE_Soldier_AA",              // AA Specialist
        "CUP_I_GUE_Engineer"                // Engineer
    ]],
    ["Infantry_T5", [
        "CUP_I_GUE_Saboteur",                // Saboteur
        "CUP_I_GUE_Soldier_Scout",           // Scout
        "CUP_I_GUE_Commander"               // High Command
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "CUP_I_Datsun_PK_Random",            // Datsun (PKM)
        "CUP_I_Ural_Empty_NAPA"              // Ural Transport
    ]],
    ["Vehicles_T2", [
        "CUP_I_BRDM2_NAPA",                  // BRDM-2
        "CUP_I_UAZ_MG_NAPA"                  // UAZ (DShKM)
    ]],
    ["Vehicles_T3", [
        "CUP_I_BMP_HQ_NAPA",                 // BMP-1 (HQ)
        "CUP_I_MTLB_pk_NAPA"                 // MT-LB LV
    ]],
    ["Vehicles_T4", [
        "CUP_I_BMP2_NAPA",                   // BMP-2
        "CUP_I_T72_NAPA"                     // T-72
    ]],
    ["Vehicles_T5", [
        "CUP_I_T72_NAPA",                     // T-72
        "CUP_I_Mi8_MT_GUE"                   // Mi-8MT (Armed)
    ]],

    ["Leader", "CUP_I_GUE_Commander"],
    ["Pilot", "CUP_I_GUE_Pilot"]
];
