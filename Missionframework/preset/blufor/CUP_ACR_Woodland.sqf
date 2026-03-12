/*
    Author: Theane using gemini
    Function: Blufor Preset - CUP ACR (Army of the Czech Republic Woodland)
    Description: Master Template for CTI32 Operation Iron Mantle.

    Required Mods:
    - CUP Weapons: https://steamcommunity.com/sharedfiles/filedetails/?id=497660133
    - CUP Units: https://steamcommunity.com/sharedfiles/filedetails/?id=497661914
    - CUP Vehicles: https://steamcommunity.com/sharedfiles/filedetails/?id=541888371

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
    3. English comments and logs only.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "CUP_B_T810_Repair_CZ_WDL";                      // Heavy FOB builder truck
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "CUP_B_T810_Reammo_CZ_WDL";                 // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "CUP_B_CZ_Crew_WDL";                              // Default crew for armored vehicles
CTI32_Pilot = "CUP_B_CZ_Pilot_WDL";                               // Default pilot for helis and jets

// --- 2. LOGISTICS & CRATES ---
CTI32_Supply_Crate = "CargoNet_01_box_F";                         // Reward crate for Supply side ops
CTI32_Ammo_Crate = "B_CargoNet_01_ammo_F";                        // Reward crate for Ammo objectives
CTI32_Fuel_Crate = "CargoNet_01_barrels_F";                       // Reward crate for Fuel objectives

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
CTI32_Support_Group1 = [
    // Vehicles used
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
CTI32_Support_Group2 = [
    // Vehicles used
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
CTI32_Support_Group3 = [
    // Vehicles used
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
CTI32_Support_Group4 = [
    // Vehicles used
    "CUP_B_Pandur_CZ_WDL",              // Pandur II APC
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
CTI32_Support_Group5 = [
    // Vehicles used
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_UAZ_Unarmed_ACR", 15],                                 // Basic UAZ
    ["CUP_B_UAZ_MG_ACR", 40],                                      // Armed UAZ
    ["CUP_B_LR_Transport_CZ_W", 25],                               // Land Rover Transport
    ["CUP_B_T810_Unarmed_CZ_WDL", 50]                              // Heavy Transport Truck
];

CTI32_Preset_APC = [
    ["CUP_B_Pandur_CZ_WDL", 150],                                  // Pandur II (Woodland)
    ["CUP_B_BVP2_CZ_WDL", 180]                                     // BVP-2 IFV
];

CTI32_Preset_Tanks = [
    ["CUP_B_T72_CZ_WDL", 350]                                      // T-72M4CZ Main Battle Tank
];

CTI32_Preset_Helis = [
    ["CUP_B_Mi171Sh_Unarmed_CZ_WDL", 250]                          // Transport Helicopter
];

CTI32_Preset_Jets = [
    ["CUP_B_L159_CZ_WDL", 500]                                     // Light Attack Jet
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis =
