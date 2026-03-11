/* PRESET: NATO Pacific (Apex)
    Author: Theane using Gemini
*/

// --- Tier 1: Basic Logistics ---
GVAR_BLUFOR_T1 = [
    ["B_T_Quadbike_01_F", 50, 0],
    ["B_T_LSV_01_unarmed_F", 150, 0],            // Prowler (Tropic)
    ["B_T_Truck_01_transport_F", 300, 0],        // HEMTT Tropic
    ["B_T_Truck_01_box_F", 500, 0]               // HEMTT Repair Tropic
];

// --- Tier 2: Motorized & GL ---
GVAR_BLUFOR_T2 = [
    ["B_T_LSV_01_armed_F", 400, 0],
    ["B_T_MRAP_01_F", 500, 0],                   // Hunter (Tropic)
    ["B_T_MRAP_01_hmg_F", 700, 0],
    ["B_T_MRAP_01_gmg_F", 800, 0]
];

// --- Tier 3: APCs & IFVs ---
GVAR_BLUFOR_T3 = [
    ["B_T_APC_Wheeled_01_cannon_F", 1500, 0],    // Marshall (Tropic)
    ["B_T_APC_Tracked_01_rcws_F", 1800, 0],      // Panther (Tropic)
    ["B_AFV_Wheeled_01_cannon_F", 2200, 0]       // Rhino MGS (Tropic)
];

// --- Tier 4: Heavy Armor ---
GVAR_BLUFOR_T4 = [
    ["B_T_MBT_01_cannon_F", 4000, 0],            // Slammer (Tropic)
    ["B_T_MBT_01_TUSK_F", 5000, 0],
    ["B_T_APC_Tracked_01_AA_F", 3500, 0]
];

// --- Tier 5: Air ---
GVAR_BLUFOR_T5_Heli = [
    ["B_Heli_Light_01_dynamicLoadout_F", 2000, 1], 
    ["B_Heli_Attack_01_dynamicLoadout_F", 5500, 1]
];
GVAR_BLUFOR_T5_Plane = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 6000, 2],
    ["B_T_VTOL_01_vehicle_F", 5000, 2]           // Blackfish (Tropic)
];
