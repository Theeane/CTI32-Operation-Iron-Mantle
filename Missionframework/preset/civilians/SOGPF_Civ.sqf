/*
    Author: Theeane / Gemini
    Function: Preset - SOGPF_Civ
    Project: Military War Framework

    Description:
    Defines the civilians preset configuration for SOG Prairie Fire (SOGPF).
*/

// --- Civilian Units (SOGPF Civilian Classes) ---
MWF_CIV_Units = [
    "vn_c_men_01",                      // Villager 01
    "vn_c_men_02",                      // Villager 02
    "vn_c_men_03",                      // Villager 03
    "vn_c_men_04",                      // Villager 04
    "vn_c_men_13",                      // Doctor
    "vn_c_men_14",                      // Priest
    "vn_c_men_31",                      // Worker
    "vn_c_men_32"                       // Worker
];

// --- Civilian Vehicles (Vietnam Era Civilian Transport) ---
MWF_CIV_Vehicles = [
    "vn_c_car_01_01",                   // Citroen 2CV
    "vn_c_wheeled_m151_01",             // M151 Jeep
    "vn_c_wheeled_z157_01",             // Z-157 Transport
    "vn_c_bicycle_01",                  // Bicycle
    "vn_c_wheeled_z157_02"              // Z-157 Fuel
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_CIV_Units";
publicVariable "MWF_CIV_Vehicles";

diag_log "[MWF] Preset: SOGPF_Civ Loaded.";