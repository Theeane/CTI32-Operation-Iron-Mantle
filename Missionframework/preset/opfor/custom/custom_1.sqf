/*
    Author: Theane / ChatGPT
    Function: Preset - Custom 1 (Safe Fallback)
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for OPFOR Custom 1 safe fallback.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers (Replace with your mod classes) ---
    ["Infantry_T1", [
        "O_Soldier_F",                      // Entry Level Rifleman
        "O_Medic_F"                         // Entry Level Medic
    ]],
    ["Infantry_T2", [
        "O_Soldier_GL_F",                   // Grenadier
        "O_Soldier_AR_F"                    // Light Machinegunner
    ]],
    ["Infantry_T3", [
        "O_Soldier_AT_F",                   // AT Specialist
        "O_Soldier_SL_F"                    // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_marksman_F",                     // Designated Marksman
        "O_engineer_F"                      // Combat Engineer
    ]],
    ["Infantry_T5", [
        "O_Sharpshooter_F",                 // Sniper / Special Forces
        "O_Officer_F"                       // High Ranking Officer
    ]],

    // --- VEHICLE Tiers (Replace with your mod classes) ---
    ["Vehicles_T1", ["O_Truck_02_transport_F"]],      // Light Transport
    ["Vehicles_T2", ["O_MRAP_02_hmg_F"]],             // Armed Recon
    ["Vehicles_T3", ["O_APC_Wheeled_02_rcws_v2_F"]],  // Infantry Fighting Vehicle
    ["Vehicles_T4", ["O_MBT_02_cannon_F"]],           // Main Battle Tank
    ["Vehicles_T5", ["O_Heli_Attack_02_dynamicLoadout_F"]], // Heavy Air Support

    // --- Core Units ---
    ["Leader", "O_Officer_F"],
    ["Pilot", "O_helipilot_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: Custom.sqf (OPFOR) Loaded.";
