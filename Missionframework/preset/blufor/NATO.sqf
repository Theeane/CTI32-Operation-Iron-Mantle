/*
    Author: Theeane
    Function: Blufor Preset - NATO (MTP)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy (Supply/Intel). 

    Integrated DLC Support for:
    - Marksmen (Units & Weapons)
    - Tanks (Heavy Armor & Rhino MGS)
    - Jets (Fighters & CAS)
    - Helicopters (Huron & Support)
    - Art of War (Recreation Force assets)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "B_Truck_01_Repair_F";                           // HEMTT Repair
CTI32_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
CTI32_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
CTI32_Respawn_Truck = "B_Truck_01_ammo_F";                         // Mobile Respawn vehicle (Fixed 100 S)
CTI32_Crewman = "B_crew_F";                                        // Default crew
CTI32_Pilot = "B_Helipilot_F";                                     // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team (Marksmen DLC Integration)
CTI32_Support_Group1 = [
    "B_LSV_01_armed_F",                 // Prowler HMG
    [
        "B_recon_TL_F",                 // Unit 1: Team Leader
        "B_recon_M_F",                  // Unit 2: Marksman (Marksmen DLC)
        "B_recon_F"                     // Unit 3: Scout
    ],
    150                                 
];

// Button 2: Heavy Infantry Section
CTI32_Support_Group2 = [
    "B_Truck_01_transport_F",           // HEMTT Transport
    [
        "B_Soldier_SL_F",               // Unit 1: Squad Leader
        "B_Soldier_AR_F",               // Unit 2: Auto Rifleman
        "B_Soldier_AR_F",               // Unit 3: Auto Rifleman
        "B_soldier_LAT_F",              // Unit 4: AT Specialist
        "B_medic_F"                     // Unit 5: Medic
    ],
    250                                 
];

// Button 3: Anti-Tank Squad (Titan & LSV AT)
CTI32_Support_Group3 = [
    "B_LSV_01_AT_F",                    // Prowler AT (Apex/Tanks)
    [
        "B_Soldier_SL_F",               // Unit 1: Squad Leader
        "B_soldier_AT_F",               // Unit 2: AT Specialist
        "B_soldier_AT_F",               // Unit 3: AT Specialist
        "B_medic_F"                     // Unit 4: Medic
    ],
    300                                 
];

// Button 4: Armored Support (Tanks DLC Integration)
CTI32_Support_Group4 = [
    "B_APC_Wheeled_01_cannon_F",        // Marshall APC
    [
        "B_Soldier_SL_F",               // Unit 1: Squad Leader
        "B_soldier_F",                  // Unit 2: Rifleman
        "B_soldier_M_F",                // Unit 3: Marksman (Marksmen DLC)
        "B_engineer_F"                  // Unit 4: Engineer
    ],
    450                                 
];

// Button 5: Air Assault (Heli DLC Integration)
CTI32_Support_Group5 = [
    "B_Heli_Transport_01_F",            // Ghost Hawk
    [
        "B_recon_TL_F",                 // Unit 1: Team Leader
        "B_recon_F",                    // Unit 2: Scout
        "B_recon_LAT_F",                // Unit 3: AT Specialist
        "B_recon_M_F"                   // Unit 4: Marksman
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["B_Quadbike_01_F", 5],                                        
    ["B_LSV_01_unarmed_F", 20],                                    
    ["B_LSV_01_armed_F", 45],                                      
    ["B_MRAP_01_F", 60]                                            // Hunter
];

CTI32_Preset_APC = [
    ["B_APC_Wheeled_01_cannon_F", 180],                             // Marshall
    ["B_APC_Tracked_01_rcws_F", 200],                              // Panther
    ["B_AFV_Wheeled_01_cannon_F", 250]                             // Rhino MGS (Tanks DLC)
];

CTI32_Preset_Tanks = [
    ["B_MBT_01_cannon_F", 450],                                     // Slammer
    ["B_MBT_01_TUSK_F", 500],                                       // Slammer UP (Tanks DLC)
    ["B_MBT_01_arty_F", 650]                                        // Scorcher
];

CTI32_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    // Hummingbird
    ["B_Heli_Transport_01_F", 250],                                // Ghost Hawk
    ["B_Heli_Transport_03_unarmed_F", 280]                         // Huron (Heli DLC)
];

CTI32_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550],                       // Wipeout
    ["B_Plane_Fighter_01_F", 700]                                   // Black Wasp II (Jets DLC)
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           // Blackfoot
    "B_Heli_Transport_03_F"                                        // Huron Armed (Heli DLC)
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_Stealth_F"                                 // Black Wasp Stealth (Jets DLC)
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "B_MRAP_01_hmg_F",                                             // Hunter HMG
    "B_MRAP_01_gmg_F"                                              // Hunter GMG
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "B_Truck_01_fuel_F",                                           
    "B_Truck_01_Repair_F"                                          
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "B_APC_Tracked_01_CRV_F"                                        // Bobcat CRV (Tanks DLC)
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: NATO.sqf (Full DLC Integration) loaded.";
