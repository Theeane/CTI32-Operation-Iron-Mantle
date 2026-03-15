/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ChernoCivs
    Project: Military War Framework

    Description:
    Defines the civilians preset configuration for CUP ChernoCivs.
*/

// --- Civilian Units ---
MWF_CIV_Units = [
    "CUP_C_C_Assistant_01",             // Assistant
    "CUP_C_C_Citizen_01",               // Citizen 01
    "CUP_C_C_Citizen_04",               // Citizen 04
    "CUP_C_C_Doctor_01",                // Doctor
    "C_journalist_F",                   // Journalist
    "CUP_C_C_Functionary_01",           // Functionary 01
    "CUP_C_C_Worker_05",                // Worker 05
    "CUP_C_C_Priest_01",                // Priest
    "CUP_C_C_Profiteer_01",             // Profiteer 01
    "CUP_C_C_Rocker_01"                 // Rocker 01
];

// --- Civilian Vehicles ---
MWF_CIV_Vehicles = [
    "CUP_C_Skoda_White_CIV",             // Skoda (White)
    "CUP_C_Datsun_Plain",                // Datsun
    "CUP_C_Golf4_white_Civ",             // Golf IV
    "CUP_C_Octavia_CIV",                 // Octavia
    "CUP_C_Ural_Civ_01",                 // Ural Truck
    "CUP_C_Lada_Green_Civ"               // Lada (Green)
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_CIV_Units";
publicVariable "MWF_CIV_Vehicles";

diag_log "[MWF] Preset: CUP_ChernoCivs Loaded.";