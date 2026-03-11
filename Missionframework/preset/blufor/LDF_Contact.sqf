/* PRESET: Contact DLC (LDF/NATO Forest)
    Author: Theane using Gemini
    Framework: CTI32 - Operation Iron Mantle
*/

// --- Tier 1: Basic Logistics (Forest Camo) ---
GVAR_BLUFOR_T1 = [
    ["I_E_Quadbike_01_F", 50, 0],
    ["I_E_Offroad_01_F", 150, 0],                // LDF Offroad
    ["I_E_Truck_02_transport_F", 300, 0],        // Zamak Transport (LDF)
    ["I_E_Truck_02_box_F", 500, 0]               // Zamak Repair
];

// --- Tier 2: Motorized & Recon ---
GVAR_BLUFOR_T2 = [
    ["I_E_Offroad_01_comms_F", 400, 0],          // LDF Comms (Great for Intel roleplay)
    ["I_E_Offroad_01_covered_F", 450, 0],
    ["B_T_MRAP_01_F", 600, 0],                   // Hunter (Tropic/Forest)
    ["B_T_MRAP_01_hmg_F", 800, 0]                // Hunter HMG (Tropic/Forest)
];

// --- Tier 3: APCs & IFVs (Contact/Tanks DLC) ---
GVAR_BLUFOR_T3 = [
    ["I_E_APC_tracked_03_cannon_F", 1600, 0],    // FV-720 Mora (LDF)
    ["B_T_APC_Wheeled_01_cannon_F", 1800, 0],    // Marshall (Forest)
    ["B_AFV_Wheeled_01_up_cannon_F", 2400, 0]    // Rhino MGS UP (Tanks DLC)
];

// --- Tier 4: Heavy Armor (Tanks DLC) ---
GVAR_BLUFOR_T4 = [
    ["B_T_MBT_01_cannon_F", 4200, 0],            // Slammer (Forest)
    ["B_T_MBT_01_TUSK_F", 5200, 0],              // Slammer UP
    ["B_MBT_01_arty_F", 6000, 0],                // Scorcher (Artillery)
    ["B_T_APC_Tracked_01_AA_F", 3800, 0]         // Cheetah (Forest)
];

// --- Tier 5: Air & High-Tech (Jets DLC) ---
GVAR_BLUFOR_T5_Heli = [
    ["I_E_Heli_light_03_unarmed_F", 1800, 1],    // Hellcat (LDF Transport)
    ["B_Heli_Attack_01_dynamicLoadout_F", 5500, 1] // Blackfoot
];
GVAR_BLUFOR_T5_Plane = [
    ["B_Plane_Fighter_01_F", 8500, 2],           // Black Wasp II (Jets DLC)
    ["B_Plane_CAS_01_dynamicLoadout_F", 6500, 2] // Wipeout
];
