/*
    Author: Theane / ChatGPT
    Function: Preset - ws_blufor_desert
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for ws blufor desert.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "B_D_Truck_01_Repair_F";                         // HEMTT Repair (Desert)
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "B_D_Truck_01_ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "B_D_crew_F";                                      // Default crew for armored vehicles
MWF_Pilot = "B_D_Helipilot_F";                                   // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team (Zubr Patrol)
MWF_Support_Group1 = [
    // Vehicle used
    "B_D_LSV_01_armed_F",               // Prowler HMG (Desert)
    [
        // AI Units
        "B_D_Soldier_TL_F",             // Unit 1: Team Leader
        "B_D_soldier_UAV_06_F",         // Unit 2: UAV Operator
        "B_D_Soldier_AR_F"              // Unit 3: Machinegunner
    ],
    150                                 // Cost
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
    // Vehicle used
    "B_D_Truck_01_transport_F",         // HEMTT Transport
    [
        // AI Units
        "B_D_Soldier_SL_F",             // Unit 1: Squad Leader
        "B_D_Soldier_AR_F",             // Unit 2: Auto Rifleman
        "B_D_Soldier_AR_F",             // Unit 3: Auto Rifleman
        "B_D_Soldier_LAT_F",            // Unit 4: AT Specialist
        "B_D_Medic_F"                   // Unit 5: Medic
    ],
    250                                 // Cost
];

// Button 3: Anti-Tank Squad
MWF_Support_Group3 = [
    // Vehicle used
    "B_D_LSV_01_AT_F",                  // Prowler AT
    [
        // AI Units
        "B_D_Soldier_SL_F",             // Unit 1: Squad Leader
        "B_D_Soldier_AT_F",             // Unit 2: AT Specialist (Titan)
        "B_D_Soldier_AT_F",             // Unit 3: AT Specialist (Titan)
        "B_D_Medic_F"                   // Unit 4: Medic
    ],
    300                                 // Cost
];

// Button 4: Armored Support
MWF_Support_Group4 = [
    // Vehicle used
    "B_D_APC_Wheeled_01_cannon_v2_F",   // Marshall APC (Desert)
    [
        // AI Units
        "B_D_Soldier_SL_F",             // Unit 1: Squad Leader
        "B_D_Soldier_F",                // Unit 2: Rifleman
        "B_D_Soldier_GL_F",             // Unit 3: Grenadier
        "B_D_Engineer_F"                // Unit 4: Engineer
    ],
    450                                 // Cost
];

// Button 5: Air Assault
MWF_Support_Group5 = [
    // Vehicle used
    "B_Heli_Transport_01_F",            // Ghost Hawk
    [
        // AI Units
        "B_D_Soldier_TL_F",             // Unit 1: Team Leader
        "B_D_Soldier_F",                // Unit 2: Rifleman
        "B_D_Soldier_LAT_F",            // Unit 3: AT Specialist
        "B_D_Soldier_MG_F"              // Unit 4: Machinegunner
    ],
    600                                 // Cost
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["B_D_LSV_01_unarmed_F", 20],                                  // Prowler Unarmed
    ["B_D_LSV_01_armed_F", 45],                                    // Prowler HMG
    ["B_D_LSV_01_AT_F", 60],                                       // Prowler AT
    ["B_D_Truck_01_covered_F", 50]                                 // HEMTT Covered
];

MWF_Preset_APC = [
    ["B_D_APC_Wheeled_01_cannon_v2_F", 180],                       // Marshall
    ["B_D_APC_Tracked_01_rcws_F", 200]                             // Panther
];

MWF_Preset_Tanks = [
    ["B_D_MBT_01_cannon_F", 450]                                   // Slammer
];

MWF_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    // Hummingbird
    ["B_Heli_Transport_01_F", 250]                                 // Ghost Hawk
];

MWF_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550]                       // Wipeout
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           // Blackfoot
    "B_Heli_Transport_03_unarmed_F"                                // Huron
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_F",                                        // Black Wasp II
    "B_Plane_Fighter_01_Stealth_F"                                 // Black Wasp Stealth
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "B_D_MRAP_01_hmg_F",                                           // Hunter HMG
    "B_D_MRAP_01_gmg_F"                                            // Hunter GMG
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               // FOB Builder Truck
    "B_D_Truck_01_fuel_F",                                         // Fuel Truck
    "B_D_Truck_01_Repair_F"                                        // Repair Truck
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "B_D_APC_Tracked_01_CRV_F"                                      // CRV Bobcat
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: Western Sahara (DLC) loaded successfully.";
