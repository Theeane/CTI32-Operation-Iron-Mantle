/*
    Author: Theane / ChatGPT
    Function: Preset - Unsung_Vietnam
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for Unsung Vietnam using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "uns_men_NVA_68_AS5",                // Rifleman (Type 56)
        "uns_men_NVA_68_M",                  // Medic
        "uns_men_NVA_68_RSAP"                // Sapper (Lite)
    ]],
    ["Infantry_T2", [
        "uns_men_NVA_68_AS1",                // Grenadier
        "uns_men_NVA_68_LMG",                // Light Machinegunner
        "uns_men_NVA_68_nco"                 // NCO (Team Leader)
    ]],
    ["Infantry_T3", [
        "uns_men_NVA_68_AT2",                // AT Specialist (RPG-7)
        "uns_men_NVA_68_HMG",                // Heavy Machinegunner
        "uns_men_NVA_68_off"                 // Officer (Squad Leader)
    ]],
    ["Infantry_T4", [
        "uns_men_NVA_68_Rmrk",               // Marksman
        "uns_men_NVA_68_Engineer",           // Engineer
        "uns_men_NVA_68_Sniper"              // Sniper (Elite)
    ]],
    ["Infantry_T5", [
        "uns_men_NVA_68_Officer",            // Officer (High Rank)
        "uns_men_NVA_68_Elite"               // Elite Soldier
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "uns_vhc_NVA_Truck",                 // Light Transport Vehicle
        "uns_vhc_NVA_Motorbike"              // Motorbike
    ]],
    ["Vehicles_T2", [
        "uns_vhc_NVA_MRAP",                  // MRAP (Heavy Machine Gun)
        "uns_vhc_NVA_Vehicle"                // Armed Vehicle
    ]],
    ["Vehicles_T3", [
        "uns_vhc_NVA_APC",                   // APC (Armored Personnel Carrier)
        "uns_vhc_NVA_BTR60"                  // IFV (Infantry Fighting Vehicle)
    ]],
    ["Vehicles_T4", [
        "uns_vhc_NVA_Tank",                  // Main Battle Tank
        "uns_vhc_NVA_Turret"                 // Anti-Tank Vehicle
    ]],
    ["Vehicles_T5", [
        "uns_vhc_NVA_Heli_Attack",           // Attack Helicopter
        "uns_vhc_NVA_Heavy_Vehicle"          // Heavy Vehicle (Elite)
    ]],
    ["Leader", "uns_men_NVA_68_Officer"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: Unsung_Vietnam.sqf (OPFOR) Loaded.";
