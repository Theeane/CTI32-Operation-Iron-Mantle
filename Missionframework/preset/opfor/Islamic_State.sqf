/* PRESET: Islamic State (Project OPFOR)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    ["Infantry_T1", [
        "LOP_SYR_Infantry_Rifleman_2",       // Rifleman (AKM)
        "LOP_SYR_Infantry_Rifleman",         // Rifleman (AK-74)
        "LOP_SYR_Infantry_TL"                // Team Leader
    ]],
    ["Infantry_T2", [
        "LOP_SYR_Infantry_Grenadier",        // Grenadier
        "LOP_SYR_Infantry_MG",               // Machinegunner
        "LOP_SYR_Infantry_SL"                // Squad Leader
    ]],
    ["Infantry_T3", [
        "LOP_SYR_Infantry_AT",               // AT Specialist
        "LOP_SYR_Infantry_Marksman",         // Marksman
        "LOP_SYR_Infantry_Officer"           // Officer
    ]],
    ["Infantry_T4", [
        "LOP_ISTS_OPF_Infantry_Marksman",    // Elite Marksman
        "LOP_ISTS_OPF_Infantry_AT",          // Elite AT
        "LOP_ISTS_OPF_Infantry_Engineer"      // Engineer
    ]],
    ["Infantry_T5", [
        "LOP_ISTS_OPF_Infantry_SL",          // Elite Leader
        "LOP_ISTS_OPF_Infantry_TL",          // Elite Team Leader
        "LOP_SYR_Infantry_SL"                // High Command
    ]],

    ["Vehicles_T1", [
        "LOP_ISTS_OPF_Landrover",            // Land Rover
        "isc_is_gaz66_o"                     // Gaz-66
    ]],
    ["Vehicles_T2", [
        "LOP_ISTS_OPF_Landrover_M2",         // Land Rover (M2)
        "LOP_ISTS_OPF_Offroad_M2"            // Offroad (M2)
    ]],
    ["Vehicles_T3", [
        "LOP_ISTS_OPF_BTR60",                // BTR-60
        "LOP_ISTS_OPF_BMP1"                  // BMP-1
    ]],
    ["Vehicles_T4", [
        "LOP_ISTS_OPF_BMP2",                 // BMP-2
        "isc_is_Ural_zu23_o"                 // Ural (ZU-23)
    ]],
    ["Vehicles_T5", [
        "CUP_O_T55_TK",                      // T-55 (Looted)
        "CUP_O_Mi8_VIV_TK",                  // Mi-8
        "CUP_O_Su25_Dyn_TKA"                 // Su-25
    ]],

    ["Leader", "LOP_SYR_Infantry_SL"],
    ["Pilot", "LOP_SYR_Infantry_Pilot"]
];
