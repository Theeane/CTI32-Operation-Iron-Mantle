/*
    Author: Theane / ChatGPT
    Function: Preset - CSAT_Pacific
    Project: Military War Framework

    Description:
    Defines the opfor preset configuration for CSAT Pacific.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "O_T_Soldier_F",                    // Rifleman
        "O_T_Soldier_LAT_F",                // Rifleman (LAT)
        "O_T_Medic_F"                       // Medic
    ]],
    ["Infantry_T2", [
        "O_T_Soldier_GL_F",                 // Grenadier
        "O_T_Soldier_AR_F",                 // Autorifleman
        "O_T_Soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "O_T_Soldier_AT_F",                 // AT Specialist
        "O_T_Soldier_MG_F",                 // Heavy Gunner
        "O_T_Soldier_SL_F"                  // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_T_Marksman_F",                   // Marksman
        "O_T_Soldier_AA_F",                 // AA Specialist
        "O_T_Engineer_F"                    // Engineer
    ]],
    ["Infantry_T5", [
        "O_V_Soldier_ghex_F",               // Viper (Green Hex)
        "O_T_Recon_F",                      // Recon Rifleman
        "O_T_Officer_F"                     // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "O_T_Truck_03_transport_ghex_F",    // Tempest Transport
        "O_T_LSV_02_unarmed_F"              // Qilin (Unarmed)
    ]],
    ["Vehicles_T2", [
        "O_T_LSV_02_armed_F",               // Qilin (Minigun)
        "O_T_MRAP_02_ghex_F"                // Ifrit (Green Hex)
    ]],
    ["Vehicles_T3", [
        "O_T_APC_Wheeled_02_rcws_v2_ghex_F", // Marid (Green Hex)
        "O_T_APC_Tracked_02_cannon_ghex_F"  // Kamysh (Green Hex)
    ]],
    ["Vehicles_T4", [
        "O_T_MBT_02_cannon_ghex_F",         // Varsuk (Green Hex)
        "O_T_APC_Tracked_02_AA_ghex_F"      // Tigris (Green Hex)
    ]],
    ["Vehicles_T5", [
        "O_T_VTOL_02_infantry_dynamicLoadout_F", // Y-32 Xi'an
        "O_Heli_Attack_02_dynamicLoadout_black_F", // Kajman (Black)
        "O_Plane_CAS_02_dynamicLoadout_ghex_F"    // Neophron (Green Hex)
    ]],

    ["Leader", "O_T_Officer_F"],
    ["Pilot", "O_T_Helipilot_F"]
];
