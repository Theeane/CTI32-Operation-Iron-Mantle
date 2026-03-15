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
        "I_C_Soldier_Bandit_02_F",          // Bandit (Grenadier)
        "I_C_Soldier_Bandit_04_F",          // Bandit (Autorifleman)
        "I_C_Soldier_Bandit_08_F"           // Bandit (Team Leader)
    ]],
    ["Infantry_T3", [
        "I_C_Soldier_Bandit_05_F",          // Bandit (Squad Leader)
        "I_C_Soldier_Bandit_06_F",          // Bandit (Marksman)
        "I_C_Soldier_Bandit_09_F"           // Bandit (Engineer)
    ]],
    ["Infantry_T4", [
        "I_C_Soldier_Bandit_10_F",          // Bandit (AA Specialist)
        "I_C_Soldier_Bandit_11_F",          // Bandit (AT Specialist)
        "I_C_Soldier_Bandit_12_F"           // Bandit (HMG Assistant)
    ]],
    ["Infantry_T5", [
        "I_C_Soldier_Bandit_13_F",          // Bandit (Sniper)
        "I_C_Soldier_Bandit_14_F"           // Bandit (Explosives Specialist)
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "I_C_Truck_01_F", 
        "I_C_MRAP_01_F"                     // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "I_C_MRAP_01_hmg_F",                // MRAP (HMG)
        "I_C_MRAP_01_gmg_F"                 // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "I_C_LT_01_scout_F",                // Nyx (Radar)
        "I_C_LT_01_cannon_F"                // Nyx (Autocannon)
    ]],
    ["Vehicles_T4", [
        "I_C_APC_Wheeled_01_cannon_F",      // Gorgon
        "I_C_APC_tracked_01_cannon_F"       // Mora
    ]],
    ["Vehicles_T5", [
        "I_C_MBT_01_cannon_F",              // Kuma (MBT)
        "I_C_Heli_light_01_dynamicLoadout_F", // WY-55 Hellcat (Armed)
        "I_C_Plane_Fighter_01_dynamicLoadout_F" // A-143 Buzzard (CAS)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "I_C_Officer_F"],
    ["Pilot",  "I_C_helipilot_F"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: Syndikat.sqf (RESISTANCE) Loaded.";
