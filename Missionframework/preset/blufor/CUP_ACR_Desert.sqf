/*
    Author: Theane using gemini
    Function: Blufor Preset - CUP ACR (Army of the Czech Republic Desert)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Physical crates removed in favor of a 100% digital supply system.

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
CTI32_FOB_Truck = "CUP_B_T810_Repair_CZ_DES";                      // Heavy FOB builder truck
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "CUP_B_T810_Reammo_CZ_DES";                 // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "CUP_B_CZ_Crew_DES";                              // Default crew for armored vehicles
CTI32_Pilot = "CUP_B_CZ_Pilot_DES";                               // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// All Side Ops rewards (Supply, Ammo, Fuel) are handled digitally. No physical crates required.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
CTI32_Support_Group1 = [
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
CTI32_Support_Group2 = [
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
CTI32_Support_Group3 = [
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
CTI32_Support_Group4 = [
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
CTI32_Support_Group5 = [
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_UAZ_Unarmed_ACR", 15],                                 // Basic UAZ
    ["CUP_B_UAZ_MG_ACR", 40],                                      // Armed UAZ
    ["CUP_B_LR_Transport_CZ_D", 25],                               // Land Rover Transport
    ["CUP_B_T810_Unarmed_CZ_DES", 50]                              // Heavy Transport Truck
];

CTI32_Preset_APC = [
    ["CUP_B_Pandur_CZ_DES", 150],                                  // Pandur II
    ["CUP_B_BVP2_CZ_DES", 180]                                     // BVP-2 IFV
];

CTI32_Preset_Tanks = [
    ["CUP_B_T72_CZ_DES", 350]                                      // T-72M4CZ Main Battle Tank
];

CTI32_Preset_Helis = [
    ["CUP_B_Mi171Sh_Unarmed_CZ_DES", 250]                          // Transport Helicopter
];

CTI32_Preset_Jets = [
    ["CUP_B_L159_CZ_DES", 500]                                     // Light Attack Jet
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "CUP_B_Mi24_V_CZ_DES",                                         // Mi-24V Hind Attack Heli
    "CUP_B_Mi171Sh_CZ_DES"                                         // Mi-171Sh Armed
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "CUP_B_L39_CZ_DES",                                            // L-39ZA Fighter
    "I_Plane_Fighter_04_F"                                         // JAS 39 Gripen
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "CUP_B_Dingo_CZ_Des",                                          // Dingo 2 MG
    "CUP_B_Dingo_GL_CZ_Des"                                        // Dingo 2 GL
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_T810_Refuel_CZ_DES",                                    // Fuel Truck
    "CUP_B_T810_Repair_CZ_DES"                                     // Repair Truck
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "CUP_B_BRDM2_HQ_CZ_Des"                                        // Armored Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP ACR Desert (Master) loaded. Digital Economy active.";
