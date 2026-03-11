/* PRESET: Syndikat (Apex Rebs)
    Author: Theane using Gemini
    Framework: CTI32 - Operation Iron Mantle
    Description: Guerrilla faction scaling from Tier 1 to 5 based on Player Actions.
*/

GVAR_RES_Preset = createHashMapFromArray [
    // --- INFANTRY POOLS (Guerrilla Style) ---
    ["Infantry_T1", [
        "I_C_Soldier_Bandit_01_F",          // Bandit (Rifle)
        "I_C_Soldier_Bandit_03_F",          // Bandit (Shotgun)
        "I_C_Soldier_Bandit_07_F"           // Bandit (Pistol)
    ]],
    ["Infantry_T2", [
        "I_C_Soldier_Bandit_02_F",          // Bandit (AK)
        "I_C_Soldier_Bandit_05_F",          // Bandit (AR)
        "I_C_Soldier_Bandit_08_F"           // Bandit (LAT)
    ]],
    ["Infantry_T3", [
        "I_C_Soldier_Para_01_F",            // Paramilitary (Rifle)
        "I_C_Soldier_Para_04_F",            // Paramilitary (AR)
        "I_C_Soldier_Para_06_F"             // Paramilitary (Medic)
    ]],
    ["Infantry_T4", [
        "I_C_Soldier_Para_02_F",            // Paramilitary (AK)
        "I_C_Soldier_Para_03_F",            // Paramilitary (GL)
        "I_C_Soldier_Para_05_F"             // Paramilitary (Marksman)
    ]],
    ["Infantry_T5", [
        "I_C_Soldier_Para_07_F",            // Paramilitary (Heavy)
        "I_C_Soldier_Para_08_F",            // Paramilitary (LAT/AT)
        "I_C_Soldier_Camo_F"                // Recon/Viper-lite
    ]],

    // --- VEHICLE POOLS (Technicals & Looted) ---
    ["Vehicles_T1", ["C_Offroad_01_F", "I_C_Offroad_02_unarmed_F"]],
    ["Vehicles_T2", ["I_C_Offroad_02_LMG_F", "O_G_Offroad_01_armed_F"]],
    ["Vehicles_T3", ["I_C_Van_01_transport_F", "O_G_Offroad_01_AT_F"]],
    ["Vehicles_T4", ["I_C_Offroad_02_AT_F", "O_G_Van_01_multipurpose_F"]],
    ["Vehicles_T5", ["I_E_APC_tracked_03_cannon_F", "O_T_LSV_02_armed_F"]], // Looted armor

    // --- SPECIAL UNITS ---
    ["Leader", "I_C_Soldier_Para_01_F"]
];
