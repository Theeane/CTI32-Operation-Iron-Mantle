/* PRESET: Vietnam CIDG (Unsung)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "uns_men_CIDG_S1",                   // Rifleman (M1 Carbine)
        "uns_men_CIDG_S2",                   // Rifleman (M2 Carbine)
        "uns_men_CIDG_MED"                   // Medic
    ]],
    ["Infantry_T2", [
        "uns_men_CIDG_MRK2",                 // Marksman (M1903)
        "uns_men_CIDG_nco",                  // NCO (Team Leader)
        "uns_men_ARVNci_S2"                  // ARVN Support Infantry
    ]],
    ["Infantry_T3", [
        "uns_men_CIDG_AT",                   // AT Specialist (M20)
        "uns_men_CIDG_SL",                   // Squad Leader
        "uns_men_ARVNci_SL"                  // ARVN Squad Leader
    ]],
    ["Infantry_T4", [
        "uns_men_CIDG_HMG",                  // Heavy Gunner (M1919)
        "uns_men_CIDG_ENG",                  // Engineer
        "uns_men_ARVNci_HMG"                 // ARVN Machinegunner
    ]],
    ["Infantry_T5", [
        "uns_men_CIDG_COM",                  // Commander
        "uns_men_CIDG_M1",                   // Elite Scout (M16)
        "uns_men_CIDG_M2"                    // Elite Scout (XM177)
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "uns_M151_unarmed",                  // M151 Jeep
        "uns_nvatruck_open"                  // Ural Transport (Looted)
    ]],
    ["Vehicles_T2", [
        "uns_M151_m60",                      // M151 (M60)
        "uns_nvatruck_mg"                    // Ural (ZPU-2)
    ]],
    ["Vehicles_T3", [
        "uns_Type63_mg",                     // Type 63 APC
        "uns_BTR152_ZPU"                     // BTR-152 (AA)
    ]],
    ["Vehicles_T4", [
        "uns_t34_76_vc",                     // T-34/76
        "pook_ZSU57_NVA"                     // ZSU-57-2
    ]],
    ["Vehicles_T5", [
        "uns_t54_nva",                       // T-54 MBT
        "uns_Mi8TV_VPAF_MG"                  // Mi-8 Hip (Armed)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "uns_men_CIDG_COM"],
    ["Pilot", "uns_pilot_nva"]
];
