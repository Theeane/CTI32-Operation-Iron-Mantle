/* PRESET: CSAT Pacific (Apex)
    Author: Theane using Gemini
*/

GVAR_OPFOR_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS ---
    ["Infantry_T1", ["O_T_Soldier_F", "O_T_Soldier_LAT_F", "O_T_Soldier_AR_F"]],
    ["Infantry_T2", ["O_T_Soldier_TL_F", "O_T_Soldier_GL_F", "O_T_Medic_F", "O_T_Soldier_M_F"]],
    ["Infantry_T3", ["O_T_Soldier_SL_F", "O_T_HeavyGunner_F", "O_T_Soldier_AT_F", "O_T_Soldier_AA_F"]],
    ["Infantry_T4", ["O_V_Soldier_ghex_F", "O_T_Soldier_PG_F"]],
    ["Infantry_T5", ["O_V_Soldier_Viper_F", "O_V_Soldier_Viper_LAT_F", "O_V_Soldier_Viper_M_F"]],

    // --- VEHICLE POOLS ---
    ["Vehicles_T1", ["O_T_LSV_02_unarmed_F", "O_T_Quadbike_01_ghex_F"]],
    ["Vehicles_T2", ["O_T_LSV_02_armed_F", "O_T_MRAP_02_hmg_ghex_F"]],
    ["Vehicles_T3", ["O_T_APC_Wheeled_02_rcws_v2_ghex_F", "O_T_APC_Tracked_02_cannon_ghex_F"]],
    ["Vehicles_T4", ["O_T_MBT_02_cannon_ghex_F", "O_MBT_04_cannon_F"]],
    ["Vehicles_T5", ["O_Heli_Attack_02_dynamicLoadout_ghex_F", "O_T_VTOL_02_infantry_dynamicLoadout_F"]],

    // --- SPECIAL UNITS ---
    ["Officer_Standard", "O_T_Officer_F"],
    ["Officer_Elite",    "O_V_Soldier_Viper_F"],
    ["Pilot",           "O_T_Helipilot_F"]
];
