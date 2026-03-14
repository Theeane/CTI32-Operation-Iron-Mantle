/*
    Author: Theane / ChatGPT
    Function: Preset - Syndikat
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for Syndikat.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Guerrilla Standard) ---
    ["Infantry_T1", [
        "I_C_Soldier_Bandit_01_F",          // Bandit (Rifle)
        "I_C_Soldier_Bandit_03_F",          // Bandit (Shotgun)
        "I_C_Soldier_Bandit_07_F"           // Bandit (Pistol)
    ]],
    ["Infantry_T2", [
        "I_C_Soldier_Bandit_02_F",          // Bandit (AK)
        "I_C_Soldier_Bandit_05_F",          // Bandit (AR)
        "I_C_Soldier_Bandit_08_F"           // Bandit (LAT)
    ]],
    ["Infantry_T3", [
        "I_C_Soldier_Para_01_F",            // Paramilitary (Rifle)
        "I_C_Soldier_Para_04_F",            // Paramilitary (AR)
        "I_C_Soldier_Para_06_F"             // Paramilitary (Medic)
    ]],
    ["Infantry_T4", [
        "I_C_Soldier_Para_02_F",            // Paramilitary (AK)
        "I_C_Soldier_Para_03_F",            // Paramilitary (GL)
        "I_C_Soldier_Para_05_F"             // Paramilitary (Marksman)
    ]],
    ["Infantry_T5", [
        "I_C_Soldier_Para_07_F",            // Paramilitary (Heavy)
        "I_C_Soldier_Para_08_F",            // Paramilitary (AT)
        "I_C_Soldier_Camo_F"                // Recon Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Technicals to Looted/Stolen Air) ---
    ["Vehicles_T1", [
        "C_Offroad_01_F", 
        "I_C_Offroad_02_unarmed_F"          // MB 4WD
    ]],
    ["Vehicles_T2", [
        "I_C_Offroad_02_LMG_F", 
        "O_G_Offroad_01_armed_F"            // Offroad HMG
    ]],
    ["Vehicles_T3", [
        "I_C_Van_01_transport_F", 
        "O_G_Offroad_01_AT_F"               // Offroad AT
    ]],
    ["Vehicles_T4", [
        "I_C_Offroad_02_AT_F", 
        "O_G_Van_01_multipurpose_F"         // Transport Van
    ]],
    ["Vehicles_T5", [
        "I_E_APC_tracked_03_cannon_F",      // Looted Mora/APC
        "I_C_Plane_Civil_01_F",             // Caesar BTT (Armed Recon)
        "C_IDAP_Heli_Light_01_civil_F"      // Stolen/Modified M-900
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "I_C_Soldier_Para_01_F"],
    ["Pilot",  "I_C_Soldier_Para_04_F"]
];
