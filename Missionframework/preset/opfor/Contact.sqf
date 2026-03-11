/* PRESET: Russian Spetsnaz (Contact/Enoch)
    Author: Theeane
    Framework: CTI32 - Operation Iron Mantle
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY Tiers ---
    ["Infantry_T1", [
        "O_R_Soldier_unarmed_F",            // Rifleman (Unarmed)
        "O_R_medic_F",                      // Medic
        "O_R_Soldier_LAT_F"                 // Rifleman (LAT)
    ]],
    ["Infantry_T2", [
        "O_R_Soldier_GL_F",                 // Grenadier
        "O_R_Soldier_AR_F",                 // Autorifleman
        "O_R_soldier_TL_F"                  // Team Leader
    ]],
    ["Infantry_T3", [
        "O_R_JTAC_F",                       // JTAC
        "O_R_soldier_exp_F",                // Explosives Specialist
        "O_R_soldier_SL_F"                  // Squad Leader
    ]],
    ["Infantry_T4", [
        "O_R_marksman_F",                   // Marksman
        "O_R_soldier_M_F",                  // Rifleman (M)
        "O_R_soldier_AR_F"                  // Heavy Gunner
    ]],
    ["Infantry_T5", [
        "O_R_recon_F",                      // Recon Rifleman
        "O_R_recon_GL_F",                   // Recon Grenadier
        "O_R_recon_M_F"                     // Recon Marksman
    ]],

    // --- VEHICLE Tiers ---
    ["Vehicles_T1", [
        "O_R_Truck_02_transport_F",         // Zamak Transport
        "O_R_Offroad_02_LMG_F"              // MB 4WD (LMG)
    ]],
    ["Vehicles_T2", [
        "O_R_LSV_02_armed_F",               // Qilin (Armed)
        "O_R_MRAP_02_hmg_F"                 // Ifrit (HMG)
    ]],
    ["Vehicles_T3", [
        "O_R_APC_Wheeled_02_rcws_v2_F"      // Marid (Enoch)
    ]],
    ["Vehicles_T4", [
        "O_R_MBT_02_cannon_F"               // T-100 Varsuk (Enoch)
    ]],
    ["Vehicles_T5", [
        "O_R_Heli_Attack_02_dynamicLoadout_F" // Mi-48 Kajman (Enoch)
    ]],

    // --- Special Classes ---
    ["Leader", "O_R_soldier_SL_F"],
    ["Pilot", "O_R_helipilot_F"]
];
