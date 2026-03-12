/*
    Author: Theeane
    Function: Blufor Preset - LDF (Contact DLC)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy (Supply/Intel). Focuses on Livonia Defense Force assets.

    Required DLC: 
    - Contact

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
    3. English comments and logs only.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "I_E_Truck_02_Medical_F";                        // Zamak Medical (Contact)
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "I_E_Truck_02_Ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "I_E_Crew_F";                                      // LDF Crew
CTI32_Pilot = "I_E_Helipilot_F";                                   // LDF Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Physical Intel (Laptops/Officers) rules apply.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
CTI32_Support_Group1 = [
    "I_E_Offroad_01_comms_F",           // LDF Comms Offroad
    [
        "I_E_Soldier_TL_F",             // Unit 1: Team Leader
        "I_E_Soldier_Pathfinder_F",     // Unit 2: Marksman/Pathfinder
        "I_E_Soldier_F"                 // Unit 3: Rifleman
    ],
    150                                 
];

// Button 2: Infantry Section
CTI32_Support_Group2 = [
    "I_E_Truck_02_Transport_F",         // Zamak Transport
    [
        "I_E_Soldier_SL_F",             // Unit 1: Squad Leader
        "I_E_Soldier_AR_F",             // Unit 2: Auto Rifleman
        "I_E_Soldier_AR_F",             // Unit 3: Auto Rifleman
        "I_E_Soldier_LAT_F",            // Unit 4: AT Specialist
        "I_E_Medic_F"                   // Unit 5: Medic
    ],
    250                                 
];

// Button 3: Anti-Tank Squad
CTI32_Support_Group3 = [
    "I_E_Offroad_01_AT_F",              // LDF AT Offroad
    [
        "I_E_Soldier_SL_F",             // Unit 1: Squad Leader
        "I_E_Soldier_AT_F",             // Unit 2: AT Specialist
        "I_E_Soldier_AT_F",             // Unit 3: AT Specialist
        "I_E_Medic_F"                   // Unit 4: Medic
    ],
    300                                 
];

// Button 4: Armored Support
CTI32_Support_Group4 = [
    "I_E_APC_tracked_03_cannon_F",      // FV510 Mora (LDF)
    [
        "I_E_Soldier_SL_F",             // Unit 1: Squad Leader
        "I_E_Soldier_F",                // Unit 2: Rifleman
        "I_E_Soldier_Marksman_F",       // Unit 3: Marksman
        "I_E_Engineer_F"                // Unit 4: Engineer
    ],
    450                                 
];

// Button 5: Air Assault
CTI32_Support_Group5 = [
    "I_E_Heli_light_03_unarmed_F",      // Hellcat Transport
    [
        "I_E_Soldier_TL_F",             // Unit 1: Team Leader
        "I_E_Soldier_F",                // Unit 2: Rifleman
        "I_E_Soldier_LAT_F",            // Unit 3: AT Specialist
        "I_E_Soldier_Pathfinder_F"      // Unit 4: Marksman
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["I_E_Offroad_01_F", 15],                                      // Basic Offroad
    ["I_E_Offroad_01_comms_F", 25],                                // Comms Offroad
    ["I_E_Offroad_01_AT_F", 45],                                   // AT Offroad
    ["I_E_Truck_02_covered_F", 50]                                 // Zamak Covered
];

CTI32_Preset_APC = [
    ["I_E_APC_tracked_03_cannon_F", 200]                            // Mora
];

CTI32_Preset_Tanks = [
    ["I_E_APC_tracked_03_cannon_F", 250]                            // High Tier Mora (LDF lacks MBTs)
];

CTI32_Preset_Helis = [
    ["I_E_Heli_light_03_unarmed_F", 200]                           
];

CTI32_Preset_Jets = [
    // LDF lacks Jets (Ready for community/mod addition)
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "I_E_Heli_light_03_dynamicLoadout_F"                           // Armed Hellcat
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    // LDF lacks Jets
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "I_E_Offroad_01_covered_F",
    "I_E_Offroad_01_comms_F"
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "I_E_Truck_02_fuel_F",                                         
    "I_E_Truck_02_Repair_F"                                        
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "I_E_Truck_02_MRL_F"                                            // Zamak MRL
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: LDF_Contact.sqf loaded successfully.";
