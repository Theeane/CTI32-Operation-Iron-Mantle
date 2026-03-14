/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_USA_Woodland
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for CUP USA Woodland.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "CUP_B_MTVR_Repair_USMC_WDL";                   // Heavy FOB builder truck
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "CUP_B_MTVR_Reammo_USMC_WDL";               // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "CUP_B_USMC_Crew_WDL";                            // Default crew for armored vehicles
MWF_Pilot = "CUP_B_USMC_Pilot_WDL";                             // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
MWF_Support_Group1 = [
    // Vehicle used
    "CUP_B_M1114_UA_M2_WDL_USMC",       // HMMWV M2 (Up-armored)
    [
        // AI Units
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_Scout",     // Unit 2: Scout
        "CUP_B_USMC_SpecOps_MG"         // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
    // Vehicle used
    "CUP_B_LAV25_USMC_W",               // LAV-25 Transport
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_WDL",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AR_WDL",    // Unit 2: Auto Rifleman
        "CUP_B_USMC_Soldier_AR_WDL",    // Unit 3: Auto Rifleman
        "CUP_B_USMC_Soldier_AT_WDL",    // Unit 4: AT Specialist
        "CUP_B_USMC_Medic_WDL"          // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
MWF_Support_Group3 = [
    // Vehicle used
    "CUP_B_M1167_UA_TOW_WDL_USMC",      // HMMWV TOW
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_WDL",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AT_WDL",    // Unit 2: AT Specialist
        "CUP_B_USMC_Soldier_AT_WDL",    // Unit 3: AT Specialist
        "CUP_B_USMC_Medic_WDL"          // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
MWF_Support_Group4 = [
    // Vehicle used
    "CUP_B_AAV_USMC_W",                 // AAV7A1
    [
        // AI Units
        "CUP_B_USMC_Soldier_SL_WDL",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_WDL",       // Unit 2: Rifleman
        "CUP_B_USMC_Soldier_GL_WDL",    // Unit 3: Grenadier
        "CUP_B_USMC_Engineer_WDL"       // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
MWF_Support_Group5 = [
    // Vehicle used
    "CUP_B_UH1Y_UNA_USMC_W",            // Venom Transport
    [
        // AI Units
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_Recon",     // Unit 2: Recon
        "CUP_B_USMC_SpecOps_MG",        // Unit 3: Machinegunner
        "CUP_B_USMC_Medic_WDL"          // Unit 4: Medic
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["CUP_B_M1152_USMC_W", 20],                                    // HMMWV Unarmed
    ["CUP_B_M1114_UA_M2_WDL_USMC", 45],                            // HMMWV M2
    ["CUP_B_M1114_UA_Mk19_WDL_USMC", 55],                          // HMMWV Mk19
    ["CUP_B_MTVR_USMC_WDL", 50]                                    // Heavy Transport Truck
];

MWF_Preset_APC = [
    ["CUP_B_LAV25_USMC_W", 180],                                   // LAV-25
    ["CUP_B_AAV_USMC_W", 200]                                      // AAV7A1
];

MWF_Preset_Tanks = [
    ["CUP_B_M1A1_WDL_USMC", 450]                                   // M1A1 Abrams
];

MWF_Preset_Helis = [
    ["CUP_B_UH1Y_UNA_USMC_W", 220],                                // UH-1Y Venom
    ["CUP_B_CH53E_USMC_W", 300]                                    // CH-53E Super Stallion
];

MWF_Preset_Jets = [
    ["CUP_B_AV8B_USMC", 550]                                       // AV-8B Harrier II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "CUP_B_AH1Z_Dynamic_USMC_W",                                   // AH-1Z Viper
    "CUP_B_UH1Y_Gunship_Dynamic_USMC_W"                            // UH-1Y Gunship
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "CUP_B_F35B_AA_USMC_W",                                        // F-35B Lightning II
    "CUP_B_F35B_Stealth_USMC_W"                                    // F-35B Stealth
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "CUP_B_RG31_M2_WDL_USMC",                                      // RG-31 M2
    "CUP_B_RG31_Mk19_WDL_USMC"                                     // RG-31 Mk19
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               // FOB Builder Truck
    "CUP_B_MTVR_Fuel_USMC_WDL",                                    // Fuel Truck
    "CUP_B_MTVR_Repair_USMC_WDL"                                   // Repair Truck
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "CUP_B_LAV25_HQ_USMC_W"                                        // LAV-HQ Command Vehicle
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: CUP USMC Woodland loaded successfully.";
