/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ACR_Desert
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for CUP ACR Desert.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "CUP_B_T810_Repair_CZ_DES";                      // Heavy FOB builder truck
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "CUP_B_T810_Reammo_CZ_DES";                 // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "CUP_B_CZ_Crew_DES";                              // Default crew for armored vehicles
MWF_Pilot = "CUP_B_CZ_Pilot_DES";                               // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// All Side Ops rewards (Supply, Ammo, Fuel) are handled digitally. No physical crates required.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
MWF_Support_Group1 = [
    // Vehicles used
    "CUP_B_LR_MG_CZ_W",                 // Land Rover HMG
    [
        // AI Units
        "CUP_B_CZ_SpecOps_TL_DES",      // Unit 1: Team Leader
        "CUP_B_CZ_SpecOps_Scout_DES",   // Unit 2: Scout
        "CUP_B_CZ_SpecOps_MG_DES"       // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
    // Vehicles used
    "CUP_B_T810_Armed_CZ_DES",          // Transport Vehicle: Tatra (Armed)
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_DES",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_AR_DES",      // Unit 2: Auto Rifleman
        "CUP_B_CZ_Soldier_AR_DES",      // Unit 3: Auto Rifleman
        "CUP_B_CZ_Soldier_RPG_DES",     // Unit 4: AT Specialist
        "CUP_B_CZ_Medic_DES"            // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
MWF_Support_Group3 = [
    // Vehicles used
    "CUP_B_UAZ_METIS_ACR",              // UAZ (Metis ATGM)
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_DES",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_AT_DES",      // Unit 2: AT Specialist
        "CUP_B_CZ_Soldier_AT_DES",      // Unit 3: AT Specialist
        "CUP_B_CZ_Medic_DES"            // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
MWF_Support_Group4 = [
    // Vehicles used
    "CUP_B_Pandur_CZ_DES",              // Pandur II APC
    [
        // AI Units
        "CUP_B_CZ_Soldier_SL_DES",      // Unit 1: Squad Leader
        "CUP_B_CZ_Soldier_DES",         // Unit 2: Rifleman
        "CUP_B_CZ_Soldier_805_GL_DES",  // Unit 3: Grenadier
        "CUP_B_CZ_Engineer_DES"         // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
MWF_Support_Group5 = [
    // Vehicles used
    "CUP_B_Mi171Sh_Unarmed_CZ_DES",     // Transport Helicopter
    [
        // AI Units
        "CUP_B_CZ_SpecOps_TL_DES",      // Unit 1: Team Leader
        "CUP_B_CZ_SpecOps_Recon_DES",   // Unit 2: Recon
        "CUP_B_CZ_SpecOps_Exp_DES",     // Unit 3: Explosives Expert
        "CUP_B_CZ_SpecOps_MG_DES"       // Unit 4: Machinegunner
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_UAZ_Unarmed_ACR", 15],                                 // Basic UAZ
    ["CUP_B_UAZ_MG_ACR", 40],                                      // Armed UAZ
    ["CUP_B_LR_Transport_CZ_D", 25],                               // Land Rover Transport
    ["CUP_B_T810_Unarmed_CZ_DES", 50]                              // Heavy Transport Truck
];

MWF_Preset_APC = [
    ["CUP_B_Pandur_CZ_DES", 150],                                  // Pandur II
    ["CUP_B_BVP2_CZ_DES", 180]                                     // BVP-2 IFV
];

MWF_Preset_Tanks = [
    ["CUP_B_T72_CZ_DES", 350]                                      // T-72M4CZ Main Battle Tank
];

MWF_Preset_Helis = [
    ["CUP_B_Mi171Sh_Unarmed_CZ_DES", 250]                          // Transport Helicopter
];

MWF_Preset_Jets = [
    ["CUP_B_L159_CZ_DES", 500]                                     // Light Attack Jet
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "CUP_B_Mi24_V_CZ_DES",                                         // Mi-24V Hind Attack Heli
    "CUP_B_Mi171Sh_CZ_DES"                                         // Mi-171Sh Armed
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "CUP_B_L39_CZ_DES",                                            // L-39ZA Fighter
    "I_Plane_Fighter_04_F"                                         // JAS 39 Gripen
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "CUP_B_Dingo_CZ_Des",                                          // Dingo 2 MG
    "CUP_B_Dingo_GL_CZ_Des"                                        // Dingo 2 GL
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_T810_Refuel_CZ_DES",                                    // Fuel Truck
    "CUP_B_T810_Repair_CZ_DES"                                     // Repair Truck
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "CUP_B_BRDM2_HQ_CZ_Des"                                        // Armored Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP ACR Desert (Master) loaded. Digital Economy active.";
