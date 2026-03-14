/*
    Author: Theane / ChatGPT
    Function: Preset - LDF_Contact
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for LDF Contact.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "I_E_Truck_02_Medical_F";                        // Zamak Medical (Contact)
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "I_E_Truck_02_Ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "I_E_Crew_F";                                      // LDF Crew
MWF_Pilot = "I_E_Helipilot_F";                                   // LDF Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Physical Intel (Laptops/Officers) rules apply.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
MWF_Support_Group1 = [
    "I_E_Offroad_01_comms_F",           // LDF Comms Offroad
    [
        "I_E_Soldier_TL_F",             // Unit 1: Team Leader
        "I_E_Soldier_Pathfinder_F",     // Unit 2: Marksman/Pathfinder
        "I_E_Soldier_F"                 // Unit 3: Rifleman
    ],
    150                                 
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
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
MWF_Support_Group3 = [
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
MWF_Support_Group4 = [
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
MWF_Support_Group5 = [
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

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    // Mobile Respawn (Rule: 100 S)
    ["I_E_Offroad_01_F", 15],                                      // Basic Offroad
    ["I_E_Offroad_01_comms_F", 25],                                // Comms Offroad
    ["I_E_Offroad_01_AT_F", 45],                                   // AT Offroad
    ["I_E_Truck_02_covered_F", 50]                                 // Zamak Covered
];

MWF_Preset_APC = [
    ["I_E_APC_tracked_03_cannon_F", 200]                            // Mora
];

MWF_Preset_Tanks = [
    ["I_E_APC_tracked_03_cannon_F", 250]                            // High Tier Mora (LDF lacks MBTs)
];

MWF_Preset_Helis = [
    ["I_E_Heli_light_03_unarmed_F", 200]                           
];

MWF_Preset_Jets = [
    // LDF lacks Jets (Ready for community/mod addition)
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "I_E_Heli_light_03_dynamicLoadout_F"                           // Armed Hellcat
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    // LDF lacks Jets
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "I_E_Offroad_01_covered_F",
    "I_E_Offroad_01_comms_F"
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               
    "I_E_Truck_02_fuel_F",                                         
    "I_E_Truck_02_Repair_F"                                        
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "I_E_Truck_02_MRL_F"                                            // Zamak MRL
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: LDF_Contact.sqf loaded successfully.";
