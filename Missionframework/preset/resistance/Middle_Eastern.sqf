/*
    Author: Theane / ChatGPT
    Function: Preset - Middle_Eastern
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for Middle Eastern.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
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
        "LOP_AM_Infantry_SL",                // Squad Leader
        "LOP_AM_Infantry_M",                 // Marksman
        "LOP_AM_Infantry_Engineer"           // Engineer
    ]],
    ["Infantry_T4", [
        "LOP_AM_Infantry_AA",                // AA Specialist
        "LOP_AM_Infantry_AT",                // AT Specialist
        "LOP_AM_Infantry_MG"                 // HMG Assistant
    ]],
    ["Infantry_T5", [
        "LOP_AM_Infantry_Sniper",            // Sniper
        "LOP_AM_Infantry_Explosive"          // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "LOP_AM_Vehicle_Truck", 
        "LOP_AM_Vehicle_MRAP"                // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "LOP_AM_Vehicle_MRAP_HMG",           // MRAP (HMG)
        "LOP_AM_Vehicle_MRAP_GMG"            // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "LOP_AM_Vehicle_Radar",              // Radar Vehicle
        "LOP_AM_Vehicle_Cannon"              // Cannon Vehicle
    ]],
    ["Vehicles_T4", [
        "LOP_AM_Vehicle_Armored",            // Gorgon (Tracked)
        "LOP_AM_Vehicle_Tracked_APC"         // Mora
    ]],
    ["Vehicles_T5", [
        "LOP_AM_Vehicle_MBT",                // Main Battle Tank
        "LOP_AM_Vehicle_Armed_Helicopter",   // Armed Helicopter
        "LOP_AM_Vehicle_Fighter_Aircraft"    // Fighter Aircraft
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "LOP_AM_Infantry_Officer"],
    ["Pilot",  "LOP_AM_Infantry_HelicopterPilot"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: Middle_Eastern.sqf (RESISTANCE) Loaded.";
