/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ACR_Woodland
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for CUP ACR Woodland.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "CUP_B_T810_Repair_CZ_WDL";                      // Heavy FOB builder truck (Woodland)
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "CUP_B_T810_Reammo_CZ_WDL";                 // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "CUP_B_CZ_Crew_WDL";                              // Default crew for armored vehicles
MWF_Pilot = "CUP_B_CZ_Pilot_WDL";                               // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 
// Physical Intel (Laptops/Officers) must be returned to FOB/MOB Laptop interaction.
// Player death with physical Intel: 15 min loot window before garbage cleanup.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
MWF_Support_Group1 = [
    // Vehicle used
    "CUP_B_LR_MG_CZ_W",                 // Land Rover HMG (Woodland)
    [
        // AI Units
        "CUP_B_CZ_SpecOps_TL_WDL",      // Unit 1: Team Leader
        "CUP_B_CZ_SpecOps_Recon_WDL",   // Unit 2: Recon
        "CUP_B_CZ_SpecOps_MG_WDL"       // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
    // Vehicle used
    "CUP_B_T810_Armed_CZ_WDL",          // Transport Vehicle: Tatra (Armed)
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_WDL",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_AR_WDL",      // Unit 2: Auto Rifleman
        "CUP_B_CZ_Soldier_AR_WDL",      // Unit 3: Auto Rifleman
        "CUP_B_CZ_Soldier_RPG_WDL",     // Unit 4: AT Specialist
        "CUP_B_CZ_Medic_WDL"            // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
MWF_Support_Group3 = [
    // Vehicle used
    "CUP_B_UAZ_METIS_ACR",              // UAZ (Metis ATGM)
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_WDL",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_AT_WDL",      // Unit 2: AT Specialist
        "CUP_B_CZ_Soldier_AT_WDL",      // Unit 3: AT Specialist
        "CUP_B_CZ_Medic_WDL"            // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
MWF_Support_Group4 = [
    // Vehicle used
    "CUP_B_Pandur_CZ_WDL",              // Pandur II APC (Woodland)
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_WDL",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_WDL",         // Unit 2: Rifleman
        "CUP_B_CZ_Soldier_805_GL_WDL",  // Unit 3: Grenadier
        "CUP_B_CZ_Engineer_WDL"         // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
MWF_Support_Group5 = [
    // Vehicle used
    "CUP_B_Mi171Sh_Unarmed_CZ_WDL",     // Transport Helicopter
    [
        // AI Units
        "CUP_B_CZ_SpecOps_TL_WDL",      // Unit 1: Team Leader
        "CUP_B_CZ_SpecOps_Recon_WDL",   // Unit 2: Recon
        "CUP_B_CZ_SpecOps_Exp_WDL",     // Unit 3: Explosives Expert
        "CUP_B_CZ_SpecOps_MG_WDL"       // Unit 4: Machinegunner
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---
MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_UAZ_Unarmed_ACR", 15],                                 // Basic UAZ
    ["CUP_B_UAZ_MG_ACR", 40],                                      // Armed UAZ
    ["CUP_B_LR_Transport_CZ_W", 25],                               // Land Rover Transport
    ["CUP_B_T810_Unarmed_CZ_WDL", 50]                              // Heavy Transport Truck
];

MWF_Preset_APC = [
    ["CUP_B_Pandur_CZ_WDL", 150],                                  // Pandur II
    ["CUP_B_BVP2_CZ_WDL", 180]                                     // BVP-2 IFV
];

MWF_Preset_Tanks = [
    ["CUP_B_T72_CZ_WDL", 350]                                      // T-72M4CZ Main Battle Tank
];

MWF_Preset_Helis = [
    ["CUP_B_Mi171Sh_Unarmed_CZ_WDL", 250]                          // Transport Helicopter
];

MWF_Preset_Jets = [
    ["CUP_B_L159_CZ_WDL", 500]                                     // Light Attack Jet
];

// --- 5. MISSION UNLOCKS ---
// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "CUP_B_Mi24_V_CZ_WDL",                                         // Mi-24V Hind Attack Heli
    "CUP_B_Mi171Sh_CZ_WDL"                                         // Mi-171Sh Armed
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "CUP_B_L39_CZ_WDL",                                            // L-39ZA Fighter
    "I_Plane_Fighter_04_F"                                         // JAS 39 Gripen
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "CUP_B_Dingo_CZ_Wdl",                                          // Dingo 2 MG
    "CUP_B_Dingo_GL_CZ_Wdl"                                        // Dingo 2 GL
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_T810_Refuel_CZ_WDL",                                    // Fuel Truck
    "CUP_B_T810_Repair_CZ_WDL"                                     // Repair Truck
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "CUP_B_BRDM2_HQ_CZ_WDL"                                        // Armored Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP ACR Woodland loaded. Digital Economy active.";
