/* PRESET: Vietnam NVA (Unsung)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
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
        "uns_men_NVA_68_SPR",                // Sniper
        "uns_men_NVA_68_ENG"                 // Engineer
    ]],
    ["Infantry_T5", [
        "uns_men_NVA_68_MR7",                // Elite Scout
        "uns_men_NVA_68_COM",                // Commander
        "uns_men_NVA_68_off"                 // High Officer
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "uns_nvatruck_open",                 // Ural (Open)
        "uns_nvatruck"                       // Ural (Closed)
    ]],
    ["Vehicles_T2", [
        "uns_nvatruck_mg",                    // Ural (ZPU-2)
        "uns_Type63_mg"                      // Type 63 APC
    ]],
    ["Vehicles_T3", [
        "uns_Type63_amb",                    // Type 63 (Ambulance)
        "uns_BTR152_ZPU"                     // BTR-152 (AA)
    ]],
    ["Vehicles_T4", [
        "uns_t34_76_vc",                     // T-34 Tank
        "pook_ZSU57_NVA"                     // ZSU-57-2 (AA)
    ]],
    ["Vehicles_T5", [
        "uns_t54_nva",                       // T-54 Main Battle Tank
        "uns_Mi8TV_VPAF_MG",                 // Mi-8 Hip (Armed)
        "uns_Mig21_CAS"                      // Mig-21 Frogfoot
    ]],

    // --- Special Classes ---
    ["Leader", "uns_men_NVA_68_COM"],
    ["Pilot", "uns_pilot_nva"]
];
