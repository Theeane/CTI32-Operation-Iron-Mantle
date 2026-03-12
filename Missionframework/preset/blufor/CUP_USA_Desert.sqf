/*
    Author: Theane using gemini
    Function: Blufor Preset - CUP USMC (United States Marine Corps Desert)
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
CTI32_FOB_Truck = "CUP_B_MTVR_Repair_USMC_DES";                   // Heavy FOB builder truck
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "CUP_B_MTVR_Reammo_USMC_DES";               // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "CUP_B_USMC_Crew_DES";                            // Default crew for armored vehicles
CTI32_Pilot = "CUP_B_USMC_Pilot_DES";                             // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
CTI32_Support_Group1 = [
    // Vehicle used
    "CUP_B_M1114_UA_M2_DES_USMC",       // HMMWV M2 (Up-armored)
    [
        // AI Units
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_Scout",     // Unit 2: Scout
        "CUP_B_USMC_SpecOps_MG"         // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
CTI32_Support_Group2 = [
    // Vehicle used
    "CUP_B_LAV25_USMC_D",               // LAV-25 Transport
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_DES",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AR_DES",    // Unit 2: Auto Rifleman
        "CUP_B_USMC_Soldier_AR_DES",    // Unit 3: Auto Rifleman
        "CUP_B_USMC_Soldier_AT_DES",    // Unit 4: AT Specialist
        "CUP_B_USMC_Medic_DES"          // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
CTI32_Support_Group3 = [
    // Vehicle used
    "CUP_B_M1167_UA_TOW_DES_USMC",      // HMMWV TOW
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_DES",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AT_DES",    // Unit 2: AT Specialist (Javelin)
        "CUP_B_USMC_Soldier_AT_DES",    // Unit 3: AT Specialist (Javelin)
        "CUP_B_USMC_Medic_DES"          // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
CTI32_Support_Group4 = [
    // Vehicle used
    "CUP_B_AAV_USMC_D",                 // AAV7A1
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_DES",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_DES",       // Unit 2: Rifleman
        "CUP_B_USMC_Soldier_GL_DES",    // Unit 3: Grenadier
        "CUP_B_USMC_Engineer_DES"       // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
CTI32_Support_Group5 = [
    // Vehicle used
    "CUP_B_UH1Y_UNA_USMC_D",            // Venom Transport
    [
        // AI Units
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_Scout",     // Unit 2: Scout
        "CUP_B_USMC_SpecOps_MG",        // Unit 3: Machinegunner
        "CUP_B_USMC_Medic_DES"          // Unit 4: Medic
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_M1152_USMC_D", 20],                                    // HMMWV Unarmed
    ["CUP_B_M1114_UA_M2_DES_USMC", 45],                            // HMMWV M2
    ["CUP_B_M1114_UA_Mk19_DES_USMC", 55],                          // HMMWV Mk19
    ["CUP_B_MTVR_USMC_DES", 50]                                    // Heavy Transport Truck
];

CTI32_Preset_APC = [
    ["CUP_B_LAV25_USMC_D", 180],                                   // LAV-25
    ["CUP_B_AAV_USMC_D", 200]                                      // AAV7A1
];

CTI32_Preset_Tanks = [
    ["CUP_B_M1A1_DES_USMC", 450]                                   // M1A1 Abrams
];

CTI32_Preset_Helis = [
    ["CUP_B_UH1Y_UNA_USMC_D", 220],                                // UH-1Y Venom
    ["CUP_B_CH53E_USMC_D", 300]                                    // CH-53E Super Stallion
];

CTI32_Preset_Jets = [
    ["CUP_B_AV8B_D_USMC", 550]                                     // AV-8B Harrier II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "CUP_B_AH1Z_Dynamic_USMC_D",                                   // AH-1Z Viper
    "CUP_B_UH1Y_Gunship_Dynamic_USMC_D"                            // UH-1Y Gunship
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "CUP_B_F35B_AA_USMC_D",                                        // F-35B Lightning II
    "CUP_B_F35B_Stealth_USMC_D"                                    // F-35B Stealth
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "CUP_B_RG31_M2_USMC_D",                                        // RG-31 M2
    "CUP_B_RG31_Mk19_USMC_D"                                       // RG-31 Mk19
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_MTVR_Fuel_USMC_DES",                                    // Fuel Truck
    "CUP_B_MTVR_Repair_USMC_DES"                                   // Repair Truck
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "CUP_B_LAV25_HQ_USMC_D"                                        // LAV-HQ Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP USMC Desert loaded successfully.";
