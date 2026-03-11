/* PRESET: GM East Germany (NVA)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    ["Infantry_T1", [
        "gm_gc_army_rifleman_akp74_80_str",   // Rifleman
        "gm_gc_army_antitank_akp74_rpg7_80_str", // RPG-7
        "gm_gc_army_medic_akp74_80_str"       // Medic
    ]],
    ["Infantry_T2", [
        "gm_gc_army_grenadier_akp74_80_str",  // Grenadier
        "gm_gc_army_machinegunner_lmgrpk_80_str", // RPK
        "gm_gc_army_squadleader_akp74_80_str" // Squad Leader
    ]],
    ["Infantry_T3", [
        "gm_gc_army_machinegunner_pk_80_str", // PKM
        "gm_gc_army_officer_80_str"           // Officer
    ]],
    ["Infantry_T4", [
        "gm_gc_army_marksman_svd_80_str",     // SVD
        "gm_gc_army_engineer_akp74_80_str"    // Engineer
    ]],
    ["Infantry_T5", [
        "gm_gc_army_officer_80_str",          // Commander
        "gm_gc_army_paratrooper_akp74_80_str" // Paratrooper
    ]],

    ["Vehicles_T1", [
        "gm_gc_army_p601",                    // Trabant
        "gm_gc_army_uaz469_cargo"             // UAZ
    ]],
    ["Vehicles_T2", [
        "gm_gc_army_btr60pa",                 // BTR-60
        "gm_gc_army_brdm2"                    // BRDM-2
    ]],
    ["Vehicles_T3", [
        "gm_gc_army_bmp1sp2",                 // BMP-1
        "gm_gc_army_btr60pb"                  // BTR-60PB
    ]],
    ["Vehicles_T4", [
        "gm_gc_army_t55am2",                  // T-55
        "gm_gc_army_zsu234v1"                 // Shilka
    ]],
    ["Vehicles_T5", [
        "gm_gc_army_t72m1",                   // T-72
        "gm_gc_army_mi2p"                     // Mi-2 (Armed)
    ]],

    ["Leader", "gm_gc_army_officer_80_str"],
    ["Pilot", "gm_gc_army_pilot_80_str"]
];
