/* PRESET: CSAT Pacific (Vanilla + DLC)
    Author: Theane using Gemini
    Framework: CTI32 - Operation Iron Mantle
*/

// --- Tier 1: Light / Insurgent Style ---
GVAR_OPFOR_T1 = [
    "O_T_Soldier_F", "O_T_Soldier_AR_F", "O_T_Soldier_LAT_F",
    "O_T_LSV_02_unarmed_F"                      // Qilin (Unarmed)
];

// --- Tier 2: Motorized ---
GVAR_OPFOR_T2 = [
    "O_T_Soldier_TL_F", "O_T_Soldier_GL_F", "O_T_Medic_F",
    "O_T_LSV_02_armed_F",                       // Qilin (Minigun)
    "O_T_MRAP_02_gmg_ghex_F"                    // Ifrit (GMG)
];

// --- Tier 3: Mechanized ---
GVAR_OPFOR_T3 = [
    "O_T_APC_Wheeled_02_rcws_v2_ghex_F",        // MSE-3 Marid
    "O_T_APC_Tracked_02_cannon_ghex_F",         // BTR-K Kamysh
    "O_T_Soldier_PG_F"                          // Paratroopers
];

// --- Tier 4: Heavy Armor & AA ---
GVAR_OPFOR_T4 = [
    "O_T_MBT_02_cannon_ghex_F",                 // T-100 Varsuk
    "O_MBT_04_cannon_F",                        // T-140 Angara (Tanks DLC)
    "O_T_APC_Tracked_02_AA_ghex_F"              // ZSU-39 Tigris
];

// --- Tier 5: Elite & Air (Används i Grand Ops) ---
GVAR_OPFOR_T5 = [
    "O_V_Soldier_Viper_F", "O_V_Soldier_Viper_LAT_F", // Viper Special Forces
    "O_Heli_Attack_02_dynamicLoadout_ghex_F",   // Mi-48 Kajman
    "O_T_VTOL_02_infantry_dynamicLoadout_F",    // Y-32 Xi'an
    "O_Plane_Fighter_02_F"                      // To-201 Shikra (Jets DLC)
];

// --- HVT & Officerare ---
GVAR_OPFOR_Officer_Standard = "O_T_Officer_F";
GVAR_OPFOR_Officer_Endgame = "O_V_Soldier_Viper_F"; // Viper som Elite Officer
GVAR_OPFOR_Pilot = "O_T_Helipilot_F";
