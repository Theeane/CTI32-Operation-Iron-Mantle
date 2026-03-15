/*
    Author: Theane / ChatGPT
    Function: Preset - Islamic_State
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for Islamic State using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "LOP_SYR_Infantry_Rifleman_2",       // Rifleman (AKM)
        "LOP_SYR_Infantry_Rifleman",         // Rifleman (AK-74)
        "LOP_SYR_Infantry_TL"                // Team Leader
    ]],
    ["Infantry_T2", [
        "LOP_SYR_Infantry_Grenadier",        // Grenadier
        "LOP_SYR_Infantry_MG",               // Machinegunner
        "LOP_SYR_Infantry_SL"                // Squad Leader
    ]],
    ["Infantry_T3", [
        "LOP_SYR_Infantry_AT",               // AT Specialist
        "LOP_SYR_Infantry_Marksman",         // Marksman
        "LOP_SYR_Infantry_Officer"           // Officer
    ]],
    ["Infantry_T4", [
        "LOP_ISTS_OPF_Infantry_Marksman",    // Elite Marksman
        "LOP_ISTS_OPF_Infantry_AT",          // Anti-Tank Specialist (Elite)
        "LOP_ISTS_OPF_Infantry_AA"           // Anti-Air Specialist (Elite)
    ]],
    ["Infantry_T5", [
        "LOP_ISTS_OPF_Infantry_Officer",     // Elite Officer
        "LOP_ISTS_OPF_Infantry_Sniper"       // Elite Sniper
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "LOP_SYR_Infantry_Truck_1",           // Transport Vehicle
        "LOP_SYR_Infantry_Van_1"              // Light Transport Vehicle
    ]],
    ["Vehicles_T2", [
        "LOP_SYR_MRAP_1",                    // MRAP
        "LOP_SYR_LSV_1"                      // Light Support Vehicle
    ]],
    ["Vehicles_T3", [
        "LOP_SYR_APC_1",                     // APC
        "LOP_SYR_MBT_1"                      // Main Battle Tank
    ]],
    ["Vehicles_T4", [
        "LOP_SYR_MBT_2",                     // Heavy MBT
        "LOP_SYR_APC_2"                      // Heavy APC
    ]],
    ["Vehicles_T5", [
        "LOP_SYR_Heli_1",                    // Attack Helicopter
        "LOP_SYR_Heli_2"                     // Heavy Attack Helicopter
    ]]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: Islamic_State.sqf (OPFOR) Loaded.";
