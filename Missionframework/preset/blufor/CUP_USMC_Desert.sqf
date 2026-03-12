/*
    Author: Theeane
    Function: Blufor Preset - USMC (Desert)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy (Supply/Intel). Includes Heavy Armor, Jets, and Marksmen support.

    Required Mods:
    - CUP Vehicles
    - CUP Units
    - CUP Weapons

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
CTI32_Crewman = "CUP_B_USMC_Crew_DES";                            // Default crew
CTI32_Pilot = "CUP_B_USMC_Pilot_DES";                             // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
CTI32_Support_Group1 = [
    "CUP_B_M1114_UA_M2_DES_USMC",       // HMMWV M2
    [
        "CUP_B_USMC_SpecOps_TL",        // Unit 1: Team Leader
        "CUP_B_USMC_SpecOps_M",         // Unit 2: Marksman
        "CUP_B_USMC_SpecOps_Scout"      // Unit 3: Scout
    ],
    150                                 
];

// Button 2: Infantry Section
CTI32_Support_Group2 = [
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
CTI32_Support_Group3 = [
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
CTI32_Support_Group4 = [
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
CTI32_Support_Group5 = [
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["CUP_B_M1152_USMC_D", 20],                                    
    ["CUP_B_M1114_UA_M2_DES_USMC", 45],                            
    ["CUP_B_M1114_UA_Mk19_DES_USMC", 55],                          
    ["CUP_B_MTVR_USMC_DES", 50]                                    
];

CTI32_Preset_APC = [
    ["CUP_B_LAV25_USMC_D", 180],                                   
    ["CUP_B_AAV_USMC_D", 200]                                      
];

CTI32_Preset_Tanks = [
    ["CUP_B_M1A1_DES_USMC", 450],                                  // Abrams
    ["CUP_B_M1A2_TUSK_MG_DES_USMC", 520]                           // Abrams TUSK
];

CTI32_Preset_Helis = [
    ["CUP_B_UH1Y_UNA_USMC_D", 220],                                
    ["CUP_B_CH53E_USMC_D", 300]                                    
];

CTI32_Preset_Jets = [
    ["CUP_B_AV8B_D_USMC", 550]                                     
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "CUP_B_AH1Z_Dynamic_USMC_D",                                   // Viper
    "CUP_B_UH1Y_Gunship_Dynamic_USMC_D"                            // Venom Gunship
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "CUP_B_F35B_AA_USMC_D",                                        
    "CUP_B_F35B_Stealth_USMC_D"                                    
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "CUP_B_RG31_M2_USMC_D",                                        
    "CUP_B_RG31_Mk19_USMC_D"                                       
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "CUP_B_MTVR_Fuel_USMC_DES",                                    
    "CUP_B_MTVR_Repair_USMC_DES"                                   
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "CUP_B_LAV25_HQ_USMC_D"                                        
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: USMC_Desert.sqf loaded successfully.";
