/*
    Author: Theane using gemini
    Function: Blufor Preset - CUP BAF (British Armed Forces Desert)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy (Supply/Intel). Physical Intel (Laptop/Officer) requires FOB/MOB drop-off.

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
CTI32_FOB_Truck = "CUP_B_MTVR_Repair_BAF_DES";                     // Heavy FOB builder truck
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "CUP_B_MTVR_Reammo_BAF_DES";                // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "CUP_B_BAF_Soldier_Crew_DDPM";                    // Default crew for armored vehicles
CTI32_Pilot = "CUP_B_BAF_Soldier_Pilot_DDPM";                     // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 
// Physical Intel (Laptops/Officers) must be returned to FOB/MOB Laptop interaction.
// Player death with physical Intel: 15 min loot window before garbage cleanup.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team (Jackal Patrol)
CTI32_Support_Group1 = [
    // Vehicle used
    "CUP_B_Jackal2_GMG_GB_D",           // Jackal 2 (GMG)
    [
        // AI Units
        "CUP_B_BAF_Soldier_TL_DDPM",    // Unit 1: Team Leader
        "CUP_B_BAF_Soldier_Scout_DDPM", // Unit 2: Scout
        "CUP_B_BAF_Soldier_MG_DDPM"     // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
CTI32_Support_Group2 = [
    // Vehicle used
    "CUP_B_Ridgback_HMG_GB_D",          // Ridgback PPV (HMG)
    [
        // AI Units
        "CUP_B_BAF_Soldier_SL_DDPM",    // Unit 1: Squad Leader
        "CUP_B_BAF_Soldier_AR_DDPM",    // Unit 2: Auto Rifleman
        "CUP_B_BAF_Soldier_AR_DDPM",    // Unit 3: Auto Rifleman
        "CUP_B_BAF_Soldier_AT_DDPM",    // Unit 4: AT Specialist (NLAW/Javelin)
        "CUP_B_BAF_Soldier_Medic_DDPM"  // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
CTI32_Support_Group3 = [
    // Vehicle used
    "CUP_B_Jackal2_HMG_GB_D",           // Jackal 2 (HMG)
    [
        // AI Units
        "CUP_B_BAF_Soldier_SL_DDPM",    // Unit 1: Squad Leader
        "CUP_B_BAF_Soldier_AT_DDPM",    // Unit 2: AT Specialist
        "CUP_B_BAF_Soldier_AT_DDPM",    // Unit 3: AT Specialist
        "CUP_B_BAF_Soldier_Medic_DDPM"  // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
CTI32_Support_Group4 = [
    // Vehicle used
    "CUP_B_FV432_Bulldog_GB_D",         // FV432 Bulldog APC
    [
        // AI Units
        "CUP_B_BAF_Soldier_SL_DDPM",    // Unit 1: Squad Leader
        "CUP_B_BAF_Soldier_DDPM",       // Unit 2: Rifleman
        "CUP_B_BAF_Soldier_GL_DDPM",    // Unit 3: Grenadier
        "CUP_B_BAF_Soldier_EN_DDPM"     // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
CTI32_Support_Group5 = [
    // Vehicle used
    "CUP_B_Merlin_HC3_GB",              // Merlin Transport Heli
    [
        // AI Units
        "CUP_B_BAF_Soldier_TL_DDPM",    // Unit 1: Team Leader
        "CUP_B_BAF_Soldier_Scout_DDPM", // Unit 2: Scout
        "CUP_B_BAF_Soldier_AT_DDPM",    // Unit 3: AT Specialist
        "CUP_B_BAF_Soldier_MG_DDPM"     // Unit 4: Machinegunner
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_LandRover_Amb_GB_D", 20],                              // Ambulance
    ["CUP_B_Jackal2_L2A1_GB_D", 45],                               // Jackal 2 HMG
    ["CUP_B_Coyote_L2A1_GB_D", 60],                                // Coyote HMG
    ["CUP_B_MTVR_BAF_DES", 50]                                     // Heavy Transport
];

CTI32_Preset_APC = [
    ["CUP_B_FV432_Bulldog_GB_D_RWS", 160],                         // Bulldog RWS
    ["CUP_B_MCV80_GB_D", 220]                                      // Warrior IFV
];

CTI32_Preset_Tanks = [
    ["CUP_B_Challenger2_Desert_BAF", 450]                          // Challenger 2
];

CTI32_Preset_Helis = [
    ["CUP_B_Wildcat_Unarmed_GB_D", 200],                           // Wildcat Transport
    ["CUP_B_Merlin_HC3_GB", 250]                                   // Merlin Transport
];

CTI32_Preset_Jets = [
    ["CUP_B_GR9_D_GB", 550]                                        // Harrier GR9
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "CUP_B_Apache_AH1_BAF",                                        // AH1 Apache Attack Heli
    "CUP_B_Wildcat_AH1_CAS_GB_D"                                   // Wildcat CAS
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "CUP_B_F35B_BAF",                                              // F-35B Lightning II
    "CUP_B_F35B_Stealth_BAF"                                       // F-35B Stealth
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "CUP_B_Mastiff_HMG_GB_D",                                      // Mastiff PPV HMG
    "CUP_B_Mastiff_GMG_GB_D"                                       // Mastiff PPV GMG
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_MTVR_Fuel_BAF_DES",                                     // Fuel Truck
    "CUP_B_MTVR_Repair_BAF_DES"                                    // Repair Truck
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "CUP_B_FV432_GB_D_HQ"                                          // FV432 HQ Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP BAF Desert loaded successfully.";
