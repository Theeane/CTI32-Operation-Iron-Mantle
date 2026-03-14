/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_USMC_Desert
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for CUP USMC Desert.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "CUP_B_MTVR_Repair_USMC_DES";                   // Heavy FOB builder truck
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "CUP_B_MTVR_Reammo_USMC_DES";               // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "CUP_B_USMC_Crew_DES";                            // Default crew
MWF_Pilot = "CUP_B_USMC_Pilot_DES";                             // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
MWF_Support_Group1 = [
    "CUP_B_M1114_UA_M2_DES_USMC",       // HMMWV M2
    [
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_M",         // Unit 2: Marksman
        "CUP_B_USMC_SpecOps_Scout"      // Unit 3: Scout
    ],
    150                                 
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
    "CUP_B_MTVR_USMC_DES",              // MTVR Transport
    [
        "B_D_Soldier_SL_F",             // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AR_DES",    // Unit 2: Auto Rifleman
        "CUP_B_USMC_Soldier_AR_DES",    // Unit 3: Auto Rifleman
        "CUP_B_USMC_Soldier_LAT_DES",   // Unit 4: AT Specialist
        "CUP_B_USMC_Medic_DES"          // Unit 5: Medic
    ],
    250                                 
];

// Button 3: Anti-Tank Squad
MWF_Support_Group3 = [
    "CUP_B_M1167_UA_TOW_DES_USMC",      // HMMWV TOW
    [
        "CUP_B_USMC_Soldier_SL_DES",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_AT_DES",    // Unit 2: AT Specialist (Javelin)
        "CUP_B_USMC_Soldier_AT_DES",    // Unit 3: AT Specialist (Javelin)
        "CUP_B_USMC_Medic_DES"          // Unit 4: Medic
    ],
    300                                 
];

// Button 4: Armored Support
MWF_Support_Group4 = [
    "CUP_B_LAV25_USMC_D",               // LAV-25
    [
        "CUP_B_USMC_Soldier_SL_DES",    // Unit 1: Squad Leader
        "CUP_B_USMC_Soldier_DES",       // Unit 2: Rifleman
        "CUP_B_USMC_Soldier_Marksman_DES", // Unit 3: Marksman
        "CUP_B_USMC_Engineer_DES"       // Unit 4: Engineer
    ],
    450                                 
];

// Button 5: Air Assault
MWF_Support_Group5 = [
    "CUP_B_UH1Y_UNA_USMC_D",            // Venom Transport
    [
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_Scout",     // Unit 2: Scout
        "CUP_B_USMC_SpecOps_LAT",       // Unit 3: AT Specialist
        "CUP_B_USMC_SpecOps_M"          // Unit 4: Marksman
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    
    ["CUP_B_M1152_USMC_D", 20],                                    
    ["CUP_B_M1114_UA_M2_DES_USMC", 45],                            
    ["CUP_B_M1114_UA_Mk19_DES_USMC", 55],                          
    ["CUP_B_MTVR_USMC_DES", 50]                                    
];

MWF_Preset_APC = [
    ["CUP_B_LAV25_USMC_D", 180],                                   
    ["CUP_B_AAV_USMC_D", 200]                                      
];

MWF_Preset_Tanks = [
    ["CUP_B_M1A1_DES_USMC", 450],                                  // Abrams
    ["CUP_B_M1A2_TUSK_MG_DES_USMC", 520]                           // Abrams TUSK
];

MWF_Preset_Helis = [
    ["CUP_B_UH1Y_UNA_USMC_D", 220],                                
    ["CUP_B_CH53E_USMC_D", 300]                                    
];

MWF_Preset_Jets = [
    ["CUP_B_AV8B_D_USMC", 550]                                     
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "CUP_B_AH1Z_Dynamic_USMC_D",                                   // Viper
    "CUP_B_UH1Y_Gunship_Dynamic_USMC_D"                            // Venom Gunship
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "CUP_B_F35B_AA_USMC_D",                                        
    "CUP_B_F35B_Stealth_USMC_D"                                    
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "CUP_B_RG31_M2_USMC_D",                                        
    "CUP_B_RG31_Mk19_USMC_D"                                       
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               
    "CUP_B_MTVR_Fuel_USMC_DES",                                    
    "CUP_B_MTVR_Repair_USMC_DES"                                   
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "CUP_B_LAV25_HQ_USMC_D"                                        
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: USMC_Desert.sqf loaded successfully.";
