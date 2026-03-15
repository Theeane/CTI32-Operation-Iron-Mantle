/*
    Author: Theane / ChatGPT
    Function: Preset - RACS
    Project: Military War Framework

    Description:
    Defines the resistance preset configuration for RACS.
*/

MWF_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Military Standard) ---
    ["Infantry_T1", [
        "LOP_RACS_Infantry_Rifleman",        // Rifleman
        "LOP_RACS_Infantry_Rifleman_2",      // Rifleman (M16)
        "LOP_RACS_Infantry_Corpsman"         // Medic
    ]],
    ["Infantry_T2", [
        "LOP_RACS_Infantry_GL",              // Grenadier
        "LOP_RACS_Infantry_AR",              // Autorifleman
        "LOP_RACS_Infantry_TL"               // Team Leader
    ]],
    ["Infantry_T3", [
        "LOP_RACS_Infantry_SL",              // Squad Leader
        "LOP_RACS_Infantry_M",               // Marksman
        "LOP_RACS_Infantry_Engineer"         // Engineer
    ]],
    ["Infantry_T4", [
        "LOP_RACS_Infantry_AA",              // AA Specialist
        "LOP_RACS_Infantry_AT",              // AT Specialist
        "LOP_RACS_Infantry_MG"               // HMG Assistant
    ]],
    ["Infantry_T5", [
        "LOP_RACS_Infantry_Sniper",          // Sniper
        "LOP_RACS_Infantry_Explosive"        // Explosives Specialist
    ]],

    // --- VEHICLE POOLS (Escalation from Cars to MBTs and Air) ---
    ["Vehicles_T1", [
        "LOP_RACS_Vehicle_Truck", 
        "LOP_RACS_Vehicle_MRAP"              // MRAP (Unarmed)
    ]],
    ["Vehicles_T2", [
        "LOP_RACS_Vehicle_MRAP_HMG",         // MRAP (HMG)
        "LOP_RACS_Vehicle_MRAP_GMG"          // MRAP (GMG)
    ]],
    ["Vehicles_T3", [
        "LOP_RACS_Vehicle_Radar",            // Radar Vehicle
        "LOP_RACS_Vehicle_Cannon"            // Cannon Vehicle
    ]],
    ["Vehicles_T4", [
        "LOP_RACS_Vehicle_Armored",          // Gorgon (Tracked)
        "LOP_RACS_Vehicle_Tracked_APC"       // Mora
    ]],
    ["Vehicles_T5", [
        "LOP_RACS_Vehicle_MBT",              // Main Battle Tank
        "LOP_RACS_Vehicle_Armed_Helicopter", // Armed Helicopter
        "LOP_RACS_Vehicle_Fighter_Aircraft"  // Fighter Aircraft
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "LOP_RACS_Infantry_Officer"],
    ["Pilot",  "LOP_RACS_Infantry_HelicopterPilot"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_RES_Preset";

diag_log "[MWF] Preset: RACS.sqf (RESISTANCE) Loaded.";
