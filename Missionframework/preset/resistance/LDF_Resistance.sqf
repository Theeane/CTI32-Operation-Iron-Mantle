/* PRESET: LDF (Livonian Defense Force)
    Author: Theane using Gemini
    Framework: CTI32 - Operation Iron Mantle
    Description: Professional Forest Resistance faction scaling from Tier 1 to 5.
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Forest Warfare Standard) ---
    ["Infantry_T1", [
        "I_E_Soldier_F",                    // Rifleman
        "I_E_Soldier_LAT_F",                // Rifleman (AT)
        "I_E_Medic_F"                       // Medic
    ]],
    ["Infantry_T2", [
        "I_E_Soldier_GL_F",                 // Grenadier
        "I_E_Soldier_AR_F",                 // Autorifleman
        "I_E_Soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "I_E_Soldier_SL_F",                 // Squad Leader
        "I_E_Soldier_M_F",                  // Marksman
        "I_E_Engineer_F"                    // Engineer
    ]],
    ["Infantry_T4", [
        "I_E_Soldier_AA_F",                 // AA Specialist
        "I_E_Soldier_AT_F",                 // AT Specialist
        "I_E_Support_MG_F"                  // HMG Assistant
    ]],
    ["Infantry_T5", [
        "I_E_Soldier_Pathfinder_F",         // Pathfinder (Recon)
        "I_E_Soldier_Exp_F",                // Explosives Specialist
        "I_E_Spotter_F"                     // Spotter
    ]],

    // --- VEHICLE POOLS (Escalation from Forest Logistics to Heavy Armor) ---
    ["Vehicles_T1", [
        "I_E_Truck_02_transport_F",         // Zamak Transport
        "I_E_Offroad_01_F"                  // Offroad (LDF)
    ]],
    ["Vehicles_T2", [
        "I_E_Offroad_01_comms_F",           // Comms Truck
        "I_E_Offroad_01_covered_F"          // Covered Offroad
    ]],
    ["Vehicles_T3", [
        "I_E_APC_tracked_03_cannon_F",      // FV-720 Mora (LDF)
        "I_E_Truck_02_MRL_F"                // Zamak MRL (Artillery)
    ]],
    ["Vehicles_T4", [
        "B_T_MBT_01_cannon_F",              // Looted Slammer (Forest Camo - Tanks DLC)
        "B_AFV_Wheeled_01_up_cannon_F"      // Rhino MGS UP (Forest - Tanks DLC)
    ]],
    ["Vehicles_T5", [
        "B_T_MBT_01_arty_F",                // Scorcher (Forest - Tanks DLC)
        "I_E_Heli_light_03_dynamicLoadout_F", // WY-55 Hellcat (Armed)
        "I_Plane_Fighter_03_dynamicLoadout_F" // A-143 Buzzard (Jets DLC)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "I_E_Officer_F"],
    ["Pilot",  "I_E_Helipilot_F"]
];
