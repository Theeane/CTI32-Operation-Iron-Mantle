/* PRESET: Takistan Army (LOP)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    ["Infantry_T1", [
        "LOP_TKA_Infantry_Rifleman",         // Rifleman (Lite)
        "LOP_TKA_Infantry_Rifleman_2",       // Rifleman
        "LOP_TKA_Infantry_Corpsman"          // Medic
    ]],
    ["Infantry_T2", [
        "LOP_TKA_Infantry_GL",               // Grenadier
        "LOP_TKA_Infantry_MG",               // Autorifleman
        "LOP_TKA_Infantry_TL"                // Team Leader
    ]],
    ["Infantry_T3", [
        "LOP_TKA_Infantry_AT",               // AT Specialist
        "LOP_TKA_Infantry_MG",               // Heavy Gunner
        "LOP_TKA_Infantry_SL"                // Squad Leader
    ]],
    ["Infantry_T4", [
        "LOP_TKA_Infantry_Marksman",         // Marksman
        "LOP_TKA_Infantry_AA",               // AA Specialist
        "LOP_TKA_Infantry_Engineer"          // Engineer
    ]],
    ["Infantry_T5", [
        "LOP_TKA_Infantry_Marksman",         // Sniper
        "LOP_TKA_Infantry_Officer",          // Officer
        "LOP_TKA_Infantry_SL"                // Commander
    ]],

    ["Vehicles_T1", [
        "LOP_TKA_UAZ",                       // UAZ-3151
        "LOP_TKA_Ural"                       // Ural Transport
    ]],
    ["Vehicles_T2", [
        "LOP_TKA_UAZ_AGS",                   // UAZ (AGS-30)
        "LOP_TKA_BTR60"                      // BTR-60
    ]],
    ["Vehicles_T3", [
        "LOP_TKA_BMP1",                      // BMP-1
        "LOP_TKA_BTR70"                      // BTR-70
    ]],
    ["Vehicles_T4", [
        "LOP_TKA_T55",                       // T-55
        "LOP_TKA_ZSU234"                     // ZSU-23-4
    ]],
    ["Vehicles_T5", [
        "LOP_TKA_T72BB",                     // T-72
        "LOP_TKA_Mi24V_AT",                  // Mi-24V
        "CUP_O_Su25_Dyn_TKA"                 // Su-25
    ]],

    ["Leader", "LOP_TKA_Infantry_Officer"],
    ["Pilot", "LOP_TKA_Infantry_SL"]
];
