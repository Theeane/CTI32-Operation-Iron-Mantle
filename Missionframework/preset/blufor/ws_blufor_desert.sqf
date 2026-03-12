/*
    Author: Theane using gemini
    Function: Blufor Preset - Western Sahara (DLC)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy active. No Workshop links needed (Vanilla/DLC assets).

    Required DLC: 
    - Western Sahara (Creator DLC)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
    3. English comments and logs only.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "B_D_Truck_01_Repair_F";                         // HEMTT Repair (Desert)
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "B_D_Truck_01_ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "B_D_crew_F";                                      // Default crew for armored vehicles
CTI32_Pilot = "B_D_Helipilot_F";                                   // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team (Zubr Patrol)
CTI32_Support_Group1 = [
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
CTI32_Support_Group2 = [
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
CTI32_Support_Group3 = [
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
CTI32_Support_Group4 = [
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
CTI32_Support_Group5 = [
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["B_D_LSV_01_unarmed_F", 20],                                  // Prowler Unarmed
    ["B_D_LSV_01_armed_F", 45],                                    // Prowler HMG
    ["B_D_LSV_01_AT_F", 60],                                       // Prowler AT
    ["B_D_Truck_01_covered_F", 50]                                 // HEMTT Covered
];

CTI32_Preset_APC = [
    ["B_D_APC_Wheeled_01_cannon_v2_F", 180],                       // Marshall
    ["B_D_APC_Tracked_01_rcws_F", 200]                             // Panther
];

CTI32_Preset_Tanks = [
    ["B_D_MBT_01_cannon_F", 450]                                   // Slammer
];

CTI32_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    // Hummingbird
    ["B_Heli_Transport_01_F", 250]                                 // Ghost Hawk
];

CTI32_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550]                       // Wipeout
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           // Blackfoot
    "B_Heli_Transport_03_unarmed_F"                                // Huron
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_F",                                        // Black Wasp II
    "B_Plane_Fighter_01_Stealth_F"                                 // Black Wasp Stealth
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "B_D_MRAP_01_hmg_F",                                           // Hunter HMG
    "B_D_MRAP_01_gmg_F"                                            // Hunter GMG
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               // FOB Builder Truck
    "B_D_Truck_01_fuel_F",                                         // Fuel Truck
    "B_D_Truck_01_Repair_F"                                        // Repair Truck
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "B_D_APC_Tracked_01_CRV_F"                                      // CRV Bobcat
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: Western Sahara (DLC) loaded successfully.";
