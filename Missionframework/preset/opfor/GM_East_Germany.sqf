/*
    Author: Theane / ChatGPT
    Function: Preset - GM_East_Germany
    Project: Military War Framework

    Description:
    Defines the OPFOR preset configuration for GM East Germany using MWF_OPFOR_Preset and Tiered structure.
*/

MWF_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "gm_gc_army_rifleman_akp74_80_str",        // Rifleman
        "gm_gc_army_antitank_akp74_rpg7_80_str",    // RPG-7
        "gm_gc_army_medic_akp74_80_str"             // Medic
    ]],
    ["Infantry_T2", [
        "gm_gc_army_grenadier_akp74_80_str",       // Grenadier
        "gm_gc_army_machinegunner_lmgrpk_80_str",   // RPK
        "gm_gc_army_squadleader_akp74_80_str"      // Squad Leader
    ]],
    ["Infantry_T3", [
        "gm_gc_army_machinegunner_pk_80_str",      // PKM
        "gm_gc_army_officer_80_str"                // Officer
    ]],
    ["Infantry_T4", [
        "gm_gc_army_marksman_svd_80_str",          // SVD Marksman
        "gm_gc_army_engineer_akp74_80_str"         // Engineer
    ]],
    ["Infantry_T5", [
        "gm_gc_army_officer_80_str",               // Officer (Elite)
        "gm_gc_army_soldier_specialist_akp74_80_str" // Specialist
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "gm_gc_army_jeep_akp74_80_str"             // Light Vehicle (Jeep)
    ]],
    ["Vehicles_T2", [
        "gm_gc_army_mrap_akp74_80_str"             // MRAP
    ]],
    ["Vehicles_T3", [
        "gm_gc_army_apc_akp74_80_str",             // APC (Armored)
        "gm_gc_army_bmp_akp74_80_str"              // BMP IFV
    ]],
    ["Vehicles_T4", [
        "gm_gc_army_mbts_akp74_80_str"             // Main Battle Tank
    ]],
    ["Vehicles_T5", [
        "gm_gc_army_heli_akp74_80_str"             // Attack Helicopter
    ]],
    ["Leader", "gm_gc_army_officer_80_str"]
];

// --- SYNC & BROADCAST ---
publicVariable "MWF_OPFOR_Preset";

diag_log "[MWF] Preset: GM_East_Germany.sqf (OPFOR) Loaded.";
