/*
    Author: Theane / ChatGPT
    Function: Preset - NATO_Pacific
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for NATO Pacific.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "B_T_Truck_01_Repair_F";                         // HEMTT Repair (Pacific)
MWF_FOB_Box = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box = "B_supplyCrate_F";
MWF_Respawn_Truck = "B_T_Truck_01_ammo_F";                       // Mobile Respawn (Fixed 100 S)
MWF_Crewman = "B_T_Crew_F";                                      // Pacific Crew
MWF_Pilot = "B_T_Helipilot_F";                                   // Pacific Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team (Apex/Marksmen DLC Pacific)
MWF_Support_Group1 = [
    "B_T_LSV_01_armed_F",               // Prowler HMG (Pacific)
    [
        "B_T_Recon_TL_F",               // Leader
        "B_T_Recon_M_F",                // Marksman (Pacific)
        "B_T_Recon_LAT_F"               // Recon AT
    ],
    150                                 
];

// Button 2: Tropical Infantry Section
MWF_Support_Group2 = [
    "B_T_Truck_01_transport_F", 
    [
        "B_T_Soldier_SL_F", 
        "B_T_Soldier_AR_F", 
        "B_T_Soldier_AR_F", 
        "B_T_Soldier_LAT_F", 
        "B_T_Medic_F"
    ],
    250                                 
];

// Button 3: Anti-Tank Squad (Pacific Titan/LSV)
MWF_Support_Group3 = [
    "B_T_LSV_01_AT_F",                  // Prowler AT (Pacific)
    [
        "B_T_Soldier_SL_F", 
        "B_T_Soldier_AT_F", 
        "B_T_Soldier_AT_F", 
        "B_T_Medic_F"
    ],
    300                                 
];

// Button 4: Armored Support (Pacific/Tanks DLC)
MWF_Support_Group4 = [
    "B_T_APC_Wheeled_01_cannon_F",      // Marshall (Pacific)
    [
        "B_T_Soldier_SL_F", 
        "B_T_Soldier_F", 
        "B_T_Soldier_M_F",              // Marksman (Pacific)
        "B_T_Engineer_F"
    ],
    450                                 
];

// Button 5: Air Assault (Apex Pacific)
MWF_Support_Group5 = [
    "B_Heli_Transport_01_F",            // Ghost Hawk
    [
        "B_T_Recon_TL_F", 
        "B_T_Recon_F", 
        "B_T_Recon_LAT_F", 
        "B_T_Recon_M_F"
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    
    ["B_T_Quadbike_01_F", 5],                                      
    ["B_T_LSV_01_unarmed_F", 20],                                  
    ["B_T_LSV_01_armed_F", 45],                                    
    ["B_T_MRAP_01_F", 60]                                          // Hunter (Pacific)
];

MWF_Preset_APC = [
    ["B_T_APC_Wheeled_01_cannon_F", 180],                          
    ["B_T_APC_Tracked_01_rcws_F", 200],                            
    ["B_T_AFV_Wheeled_01_cannon_F", 250]                           // Rhino MGS (Pacific)
];

MWF_Preset_Tanks = [
    ["B_T_MBT_01_cannon_F", 450],                                  // Slammer (Pacific)
    ["B_T_MBT_01_TUSK_F", 500],                                    // Slammer UP (Pacific)
    ["B_T_MBT_01_arty_F", 650]                                     // Scorcher (Pacific)
];

MWF_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    
    ["B_Heli_Transport_01_F", 250],                                
    ["B_Heli_Transport_03_unarmed_F", 280]                         // Huron (Heli DLC)
];

MWF_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550],                       
    ["B_Plane_Fighter_01_F", 700]                                   // Black Wasp II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           
    "B_Heli_Transport_03_F",                                       // Huron Armed
    "B_T_VTOL_01_infantry_F"                                       // Blackfish Infantry (Apex)
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_Stealth_F",                                
    "B_T_VTOL_01_armed_F"                                          // Blackfish Armed (Apex)
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "B_T_MRAP_01_hmg_F",                                           
    "B_T_MRAP_01_gmg_F"                                            
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               
    "B_T_Truck_01_fuel_F",                                         
    "B_T_Truck_01_Repair_F"                                        
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "B_T_APC_Tracked_01_CRV_F"                                      // Bobcat CRV (Pacific)
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: NATO_Pacific.sqf (Apex DLC Support) loaded.";
