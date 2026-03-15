/*
    Author: Theane / ChatGPT
    Function: Preset - Takistan_Army
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for Takistan Army using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "LOP_TKA_Infantry_Rifleman",         // Rifleman (Lite)
        "LOP_TKA_Infantry_Rifleman_2",       // Rifleman
        "LOP_TKA_Infantry_Corpsman"          // Medic
    ]],
    ["Infantry_T2", [
        "LOP_TKA_Infantry_GL",               // Grenadier
        "LOP_TKA_Infantry_MG",               // Machinegunner
        "LOP_TKA_Infantry_TL"                // Team Leader
    ]],
    ["Infantry_T3", [
        "LOP_TKA_Infantry_AT",               // AT Specialist
        "LOP_TKA_Infantry_MG",               // Heavy Gunner
        "LOP_TKA_Infantry_SL"                // Squad Leader
    ]],
    ["Infantry_T4", [
        "LOP_TKA_Infantry_Marksman",         // Marksman
        "LOP_TKA_Infantry_AA",               // AA Specialist
        "LOP_TKA_Infantry_Engineer"          // Engineer
    ]],
    ["Infantry_T5", [
        "LOP_TKA_Infantry_Sharpshooter",     // Sharpshooter
        "LOP_TKA_Infantry_Officer"           // Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "LOP_TKA_Truck_02_transport",        // Light Transport Vehicle
        "LOP_TKA_LSV_Unarmed"                // Light Vehicle (Unarmed)
    ]],
    ["Vehicles_T2", [
        "LOP_TKA_MRAP_02_hmg",               // MRAP (Heavy Machine Gun)
        "LOP_TKA_LSV_Armed"                  // Armed Light Vehicle
    ]],
    ["Vehicles_T3", [
        "LOP_TKA_APC_Wheeled_02_rcws_v2",    // APC
        "LOP_TKA_BMP_Infantry"               // Infantry Fighting Vehicle
    ]],
    ["Vehicles_T4", [
        "LOP_TKA_MBT_02_cannon",             // Main Battle Tank
        "LOP_TKA_Tigris_AA"                  // Tigris (AA Variant)
    ]],
    ["Vehicles_T5", [
        "LOP_TKA_MBT_04_cannon",             // T-140 Angara (Elite Tank)
        "LOP_TKA_Heli_Attack_02_dynamicLoadout" // Mi-48 Kajman Attack Helicopter
    ]]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: Takistan_Army.sqf (OPFOR) Loaded.";
