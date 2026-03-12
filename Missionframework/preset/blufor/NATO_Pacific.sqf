/*
    Author: Theeane
    Function: Blufor Preset - NATO Pacific (Apex)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy active. Tropical equipment focus with heavy DLC support.

    Integrated DLC Support for:
    - Apex (Core Units & Tropical Gear)
    - Marksmen (Pacific Marksmen Units)
    - Tanks (Pacific Camo Armor & Rhino MGS)
    - Jets (Black Wasp II & CAS)
    - Helicopters (Huron & Support)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "B_T_Truck_01_Repair_F";                         // HEMTT Repair (Pacific)
CTI32_FOB_Box = "B_Slingload_01_Cargo_F"; 
CTI32_Arsenal_Box = "B_supplyCrate_F";
CTI32_Respawn_Truck = "B_T_Truck_01_ammo_F";                       // Mobile Respawn (Fixed 100 S)
CTI32_Crewman = "B_T_Crew_F";                                      // Pacific Crew
CTI32_Pilot = "B_T_Helipilot_F";                                   // Pacific Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team (Apex/Marksmen DLC Pacific)
CTI32_Support_Group1 = [
    "B_T_LSV_01_armed_F",               // Prowler HMG (Pacific)
    [
        "B_T_Recon_TL_F",               // Leader
        "B_T_Recon_M_F",                // Marksman (Pacific)
        "B_T_Recon_LAT_F"               // Recon AT
    ],
    150                                 
];

// Button 2: Tropical Infantry Section
CTI32_Support_Group2 = [
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
CTI32_Support_Group3 = [
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
CTI32_Support_Group4 = [
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
CTI32_Support_Group5 = [
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["B_T_Quadbike_01_F", 5],                                      
    ["B_T_LSV_01_unarmed_F", 20],                                  
    ["B_T_LSV_01_armed_F", 45],                                    
    ["B_T_MRAP_01_F", 60]                                          // Hunter (Pacific)
];

CTI32_Preset_APC = [
    ["B_T_APC_Wheeled_01_cannon_F", 180],                          
    ["B_T_APC_Tracked_01_rcws_F", 200],                            
    ["B_T_AFV_Wheeled_01_cannon_F", 250]                           // Rhino MGS (Pacific)
];

CTI32_Preset_Tanks = [
    ["B_T_MBT_01_cannon_F", 450],                                  // Slammer (Pacific)
    ["B_T_MBT_01_TUSK_F", 500],                                    // Slammer UP (Pacific)
    ["B_T_MBT_01_arty_F", 650]                                     // Scorcher (Pacific)
];

CTI32_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    
    ["B_Heli_Transport_01_F", 250],                                
    ["B_Heli_Transport_03_unarmed_F", 280]                         // Huron (Heli DLC)
];

CTI32_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550],                       
    ["B_Plane_Fighter_01_F", 700]                                   // Black Wasp II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           
    "B_Heli_Transport_03_F",                                       // Huron Armed
    "B_T_VTOL_01_infantry_F"                                       // Blackfish Infantry (Apex)
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_Stealth_F",                                
    "B_T_VTOL_01_armed_F"                                          // Blackfish Armed (Apex)
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "B_T_MRAP_01_hmg_F",                                           
    "B_T_MRAP_01_gmg_F"                                            
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "B_T_Truck_01_fuel_F",                                         
    "B_T_Truck_01_Repair_F"                                        
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "B_T_APC_Tracked_01_CRV_F"                                      // Bobcat CRV (Pacific)
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: NATO_Pacific.sqf (Apex DLC Support) loaded.";
