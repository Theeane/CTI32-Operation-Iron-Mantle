/*
    Author: Theane / ChatGPT
    Function: Preset - Custom 1 (Safe Fallback)
    Project: Military War Framework

    Description:
    Defines the civilians preset configuration for Civilian Custom 1 safe fallback.
*/

// --- Civilian Units (Mix of casual and workers) ---
MWF_CIV_Units = [
    "C_man_1", 
    "C_man_polo_1_F", 
    "C_man_polo_2_F", 
    "C_man_p_beggar_F", 
    "C_man_1_1_F", 
    "C_man_hunter_1_F",
    "C_man_shorts_1_F", 
    "C_idap_man_shorts_01_F", 
    "C_idap_man_casual_01_F"
];

// --- Civilian Vehicles (Standard cars and vans) ---
MWF_CIV_Vehicles = [
    "C_Offroad_01_F",                   // Offroad
    "C_Hatchback_01_F",                 // Hatchback
    "C_Hatchback_01_sport_F",           // Hatchback (Sport)
    "C_SUV_01_F",                       // SUV
    "C_Van_01_transport_F",             // Truck Boxer
    "C_Van_02_vehicle_F",               // Van (Laws of War DLC)
    "C_Truck_02_transport_F"            // Zamak Transport
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_CIV_Units";
publicVariable "MWF_CIV_Vehicles";

diag_log "[MWF] Preset: custom_1 Loaded.";
