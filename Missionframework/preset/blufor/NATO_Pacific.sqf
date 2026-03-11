/* PRESET: NATO Pacific (Vanilla + DLC)
    Author: Theane using Gemini
    Framework: CTI32 - Operation Iron Mantle
*/

// --- Tier 1: Basic Logistics & Scouting ---
// [Classname, SupplyCost, SlotRequirement (0:None, 1:Heli, 2:Plane)]
GVAR_BLUFOR_T1 = [
    ["B_T_Quadbike_01_F", 50, 0],
    ["B_T_LSV_01_unarmed_F", 150, 0],           // Prowler (Unarmed)
    ["B_T_Truck_01_transport_F", 300, 0],       // HEMTT Transport
    ["B_T_Truck_01_medical_F", 400, 0],         // HEMTT Medical
    ["B_T_Truck_01_box_F", 500, 0]              // HEMTT Repair
];

// --- Tier 2: Motorized & Grenade Launchers ---
GVAR_BLUFOR_T2 = [
    ["B_T_LSV_01_armed_F", 400, 0],             // Prowler (HMG)
    ["B_T_MRAP_01_F", 500, 0],                  // Hunter
    ["B_T_MRAP_01_hmg_F", 700, 0],              // Hunter (HMG)
    ["B_T_MRAP_01_gmg_F", 800, 0]               // Hunter (GMG/GL)
];

// --- Tier 3: APCs & IFVs (Mechanized) ---
GVAR_BLUFOR_T3 = [
    ["B_T_APC_Wheeled_01_cannon_F", 1500, 0],   // AMV-7 Marshall
    ["B_T_APC_Tracked_01_rcws_F", 1800, 0],     // IFV-6c Panther
    ["B_T_APC_Tracked_01_CRV_F", 2000, 0],      // CRV-6e Bobcat
    ["B_AFV_Wheeled_01_cannon_F", 2200, 0],     // Rhino MGS (Tanks DLC)
    ["B_AFV_Wheeled_01_up_cannon_F", 2500, 0]   // Rhino MGS UP
];

// --- Tier 4: Heavy Armor & AA ---
GVAR_BLUFOR_T4 = [
    ["B_T_MBT_01_cannon_F", 4000, 0],           // M2A1 Slammer
    ["B_T_MBT_01_TUSK_F", 5000, 0],             // M2A4 Slammer UP
    ["B_T_APC_Tracked_01_AA_F", 3500, 0],       // IFV-6a Cheetah
    ["B_T_MBT_01_arty_F", 6000, 0],             // M4 Scorcher
    ["B_T_MBT_01_mlrs_F", 6500, 0]              // M5 Sandstorm
];

// --- Tier 5: Air & Specialized (Requires Grand Op + Slot Placement) ---
GVAR_BLUFOR_T5_Heli = [
    ["B_Heli_Light_01_F", 1500, 1],             // MH-9 Hummingbird
    ["B_Heli_Light_01_dynamicLoadout_F", 2000, 1], // AH-9 Pawnee
    ["B_Heli_Transport_01_F", 2500, 1],         // UH-80 Ghost Hawk
    ["B_Heli_Transport_03_F", 3000, 1],         // CH-67 Huron
    ["B_Heli_Attack_01_dynamicLoadout_F", 5500, 1] // AH-99 Blackfoot
];

GVAR_BLUFOR_T5_Plane = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 6000, 2], // A-164 Wipeout
    ["B_Plane_Fighter_01_F", 8000, 2],           // F/A-181 Black Wasp II
    ["B_Plane_Fighter_01_Stealth_F", 9500, 2],   // F/A-181 Stealth
    ["B_T_VTOL_01_infantry_F", 4500, 2],        // V-44 X Blackfish (Infantry)
    ["B_T_VTOL_01_vehicle_F", 5000, 2],         // V-44 X Blackfish (Vehicle)
    ["B_UAV_02_dynamicLoadout_F", 2500, 2],      // MQ-4A Greyhawk
    ["B_UAV_05_F", 3500, 2]                      // UCAV Sentinel
];

// --- Static Weapons & Defensive Objects ---
GVAR_BLUFOR_Statics = [
    ["B_T_HMG_01_F", 150, 0],                   // Mk30 HMG
    ["B_T_GMG_01_F", 250, 0],                   // Mk32 GMG
    ["B_T_Static_AA_F", 400, 1],                // Mini-Slammer AA
    ["B_T_Static_AT_F", 400, 1],                // Mini-Slammer AT
    ["B_T_Mortar_01_F", 600, 2]                 // Mk6 Mortar
];
