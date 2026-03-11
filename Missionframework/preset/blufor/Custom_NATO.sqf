/* PRESET: Custom NATO (Vanilla Base)
    Author: Theane using Gemini
    Description: Use this file to create your own custom faction. 
    Replace the classnames below with your desired units.
*/

// --- Tier 1: Basic Logistics ---
GVAR_BLUFOR_T1 = [
    ["B_Quadbike_01_F", 50, 0],
    ["B_LSV_01_unarmed_F", 150, 0],
    ["B_Truck_01_transport_F", 300, 0]
];

// --- Tier 2: Light Combat ---
GVAR_BLUFOR_T2 = [
    ["B_LSV_01_armed_F", 400, 0],
    ["B_MRAP_01_hmg_F", 700, 0],
    ["B_MRAP_01_gmg_F", 850, 0]
];

// --- Tier 3: Medium Support ---
GVAR_BLUFOR_T3 = [
    ["B_APC_Wheeled_01_cannon_F", 1800, 0],
    ["B_APC_Tracked_01_rcws_F", 2000, 0],
    ["B_AFV_Wheeled_01_cannon_F", 2500, 0]
];

// --- Tier 4: Heavy Assault ---
GVAR_BLUFOR_T4 = [
    ["B_MBT_01_cannon_F", 4500, 0],
    ["B_MBT_01_TUSK_F", 5500, 0],
    ["B_APC_Tracked_01_AA_F", 3800, 0]
];

// --- Tier 5: Air Superiority ---
GVAR_BLUFOR_T5_Heli = [
    ["B_Heli_Light_01_dynamicLoadout_F", 2500, 1],
    ["B_Heli_Attack_01_dynamicLoadout_F", 6000, 1]
];
GVAR_BLUFOR_T5_Plane = [
    ["B_Plane_Fighter_01_F", 8500, 2],
    ["B_Plane_CAS_01_dynamicLoadout_F", 7000, 2]
];
