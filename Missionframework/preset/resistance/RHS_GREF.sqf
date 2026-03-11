/* PRESET: RHS GREF (Nationalist)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "rhsgref_ins_g_rifleman",            // Rifleman
        "rhsgref_ins_g_rifleman_akm",        // Rifleman (AKM)
        "rhsgref_ins_g_medic"                // Medic
    ]],
    ["Infantry_T2", [
        "rhsgref_ins_g_grenadier",           // Grenadier
        "rhsgref_ins_g_arifleman",           // Autorifleman
        "rhsgref_ins_g_squadleader"          // Team Leader
    ]],
    ["Infantry_T3", [
        "rhsgref_ins_g_at",                  // AT Specialist
        "rhsgref_ins_g_machinegunner",       // Heavy Gunner
        "rhsgref_ins_g_commander"            // Squad Leader
    ]],
    ["Infantry_T4", [
        "rhsgref_ins_g_marksman",            // Marksman
        "rhsgref_ins_g_engineer",            // Engineer
        "rhsgref_ins_g_sniper"               // Sniper
    ]],
    ["Infantry_T5", [
        "rhsgref_ins_g_special_enforcer",    // Elite Enforcer
        "rhsgref_ins_g_officer",             // Officer
        "rhsgref_ins_g_commander"            // High Command
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "rhsgref_ins_g_uaz",                 // UAZ
        "rhsgref_ins_g_ural"                // Ural Transport
    ]],
    ["Vehicles_T2", [
        "rhsgref_ins_g_uaz_dshkm",           // UAZ (DShKM)
        "rhsgref_ins_g_uaz_spg9"             // UAZ (SPG-9)
    ]],
    ["Vehicles_T3", [
        "rhsgref_ins_g_btr60",               // BTR-60PB
        "rhsgref_ins_g_brdm2"                // BRDM-2
    ]],
    ["Vehicles_T4", [
        "rhsgref_ins_g_bmp1",                // BMP-1
        "rhsgref_ins_g_zsu234"               // ZSU-23-4 Shilka
    ]],
    ["Vehicles_T5", [
        "rhsgref_ins_g_t72ba",               // T-72B
        "rhsgref_ins_g_Mi8amt"               // Mi-8AMT (Armed)
    ]],

    // --- SPECIAL UNITS ---
    ["Leader", "rhsgref_ins_g_commander"],
    ["Pilot", "rhsgref_ins_g_pilot"]
];
