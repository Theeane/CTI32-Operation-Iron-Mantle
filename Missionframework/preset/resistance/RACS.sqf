/* PRESET: RACS (Royal Army Corps of Sahrani)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "LOP_RACS_Infantry_Rifleman",        // Rifleman
        "LOP_RACS_Infantry_Rifleman_2",      // Rifleman (M16)
        "LOP_RACS_Infantry_Corpsman"         // Medic
    ]],
    ["Infantry_T2", [
        "LOP_RACS_Infantry_GL",              // Grenadier
        "LOP_RACS_Infantry_AR",              // Autorifleman
        "LOP_RACS_Infantry_TL"               // Team Leader
    ]],
    ["Infantry_T3", [
        "LOP_RACS_Infantry_AT",              // AT Specialist (MAAWS)
        "LOP_RACS_Infantry_MG",              // Heavy Gunner
        "LOP_RACS_Infantry_SL"               // Squad Leader
    ]],
    ["Infantry_T4", [
        "LOP_RACS_Infantry_Marksman",        // Marksman
        "LOP_RACS_Infantry_AA",              // AA Specialist
        "LOP_RACS_Infantry_Engineer"         // Engineer
    ]],
    ["Infantry_T5", [
        "LOP_RACS_Infantry_Officer",         // Officer
        "LOP_RACS_Infantry_SL",              // Commander
        "LOP_RACS_Infantry_Marksman"         // Sharpshooter
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "LOP_RACS_UAZ",                      // UAZ
        "LOP_RACS_Ural"                      // Ural Transport
    ]],
    ["Vehicles_T2", [
        "LOP_RACS_Offroad_M2",               // Offroad (M2)
        "LOP_RACS_Landrover_M2"              // Land Rover (M2)
    ]],
    ["Vehicles_T3", [
        "LOP_RACS_M113_W",                   // M113A3
        "LOP_RACS_M113_W_MK19"               // M113A3 (Mk19)
    ]],
    ["Vehicles_T4", [
        "LOP_RACS_M60A3",                    // M60A3 Patton
        "CUP_I_ZSU23_AAF"                    // ZSU-23-4 (AAF/RACS)
    ]],
    ["Vehicles_T5", [
        "LOP_RACS_M1A1_W",                   // M1A1 Abrams
        "LOP_RACS_MH60L_DAP"                 // MH-60L DAP (Attack)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "LOP_RACS_Infantry_SL"],
    ["Pilot", "LOP_RACS_Infantry_Pilot"]
];
