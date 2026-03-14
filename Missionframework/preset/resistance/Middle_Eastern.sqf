/*
    Author: Theane / ChatGPT
    Function: Preset - Middle_Eastern
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for Middle Eastern.
*/

MWF_RES_Preset = createHashMapFromArray [
    ["Infantry_T1", [
        "LOP_AM_Infantry_Rifleman",          // Rifleman
        "LOP_AM_Infantry_Rifleman_2",        // Rifleman (AKM)
        "LOP_AM_Infantry_Corpsman"           // Medic
    ]],
    ["Infantry_T2", [
        "LOP_AM_Infantry_GL",                // Grenadier
        "LOP_AM_Infantry_AR",                // Autorifleman
        "LOP_AM_Infantry_TL"                 // Team Leader
    ]],
    ["Infantry_T3", [
        "LOP_AM_Infantry_AT",                // AT Specialist
        "LOP_AM_Infantry_MG",                // Heavy Gunner
        "LOP_AM_Infantry_SL"                 // Squad Leader
    ]],
    ["Infantry_T4", [
        "LOP_AM_Infantry_Marksman",          // Marksman
        "LOP_AM_Infantry_Engineer",          // Engineer
        "CUP_I_TK_GUE_Soldier_AA"            // AA Specialist
    ]],
    ["Infantry_T5", [
        "CUP_I_TK_GUE_Sniper",               // Sniper
        "LOP_AM_Infantry_Officer",           // Officer
        "CUP_I_TK_GUE_Commander"             // Commander
    ]],

    ["Vehicles_T1", ["LOP_AM_UAZ", "CUP_I_Hilux_unarmed_TK"]],
    ["Vehicles_T2", ["LOP_AM_UAZ_DshKM", "CUP_I_Hilux_DSHKM_TK"]],
    ["Vehicles_T3", ["CUP_I_Hilux_BMP1_TK", "CUP_I_BRDM2_TK_GUE"]],
    ["Vehicles_T4", ["CUP_I_T55_TK_GUE", "CUP_I_Hilux_zu23_TK"]],
    ["Vehicles_T5", ["CUP_I_T72_TK_GUE", "CUP_O_Mi8_VIV_TK"]],

    ["Leader", "LOP_AM_Infantry_SL"],
    ["Pilot", "LOP_AM_Infantry_Pilot"]
];
