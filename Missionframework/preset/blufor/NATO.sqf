/* PRESET: NATO Standard (Altis/Stratis)
    Author: Theane using Gemini
*/

// --- Tier 1: Basic Logistics ---
GVAR_BLUFOR_T1 = [
    ["B_Quadbike_01_F", 50, 0],
    ["B_LSV_01_unarmed_F", 150, 0],              // Prowler (Sand)
    ["B_Truck_01_transport_F", 300, 0],          // HEMTT Transport
    ["B_Truck_01_box_F", 500, 0]                 // HEMTT Repair
];

// --- Tier 2: Motorized & GL ---
GVAR_BLUFOR_T2 = [
    ["B_LSV_01_armed_F", 400, 0],                // Prowler (HMG)
    ["B_MRAP_01_F", 500, 0],                     // Hunter
    ["B_MRAP_01_hmg_F", 700, 0],                 // Hunter (HMG)
    ["B_MRAP_01_gmg_F", 800, 0]                  // Hunter (GMG)
];

// --- Tier 3: APCs & IFVs ---
GVAR_BLUFOR_T3 = [
    ["B_APC_Wheeled_01_cannon_F", 1500, 0],      // Marshall
    ["B_APC_Tracked_01_rcws_F", 1800, 0],        // Panther
    ["B_AFV_Wheeled_01_cannon_F", 2200, 0]       // Rhino MGS
];

// --- Tier 4: Heavy Armor ---
GVAR_BLUFOR_T4 = [
    ["B_MBT_01_cannon_F", 4000, 0],              // Slammer
    ["B_MBT_01_TUSK_F", 5000, 0],                // Slammer UP
    ["B_APC_Tracked_01_AA_F", 3500, 0]           // Cheetah
];

// --- Tier 5: Air ---
GVAR_BLUFOR_T5_Heli = [
    ["B_Heli_Light_01_dynamicLoadout_F", 2000, 1], // Pawnee
    ["B_Heli_Attack_01_dynamicLoadout_F", 5500, 1] // Blackfoot
];
GVAR_BLUFOR_T5_Plane = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 6000, 2], // Wipeout
    ["B_Plane_Fighter_01_F", 8000, 2]             // Black Wasp II
];
