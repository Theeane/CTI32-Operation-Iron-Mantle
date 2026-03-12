/*
    Author: Theeane
    Function: Blufor Preset - NATO Woodland (Contact/Livonia)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy active. Focus on dark woodland camouflage with full DLC support.

    Integrated DLC Support for:
    - Contact (Core Woodland Assets)
    - Marksmen (Woodland Marksmen Units)
    - Tanks (Woodland Camo for Armor & Rhino MGS)
    - Jets (Dark/Woodland Air Liveries)
    - Helicopters (Woodland/Olive Liveries)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "B_W_Truck_01_Repair_F";                         // HEMTT Repair (Woodland)
CTI32_FOB_Box = "B_Slingload_01_Cargo_F"; 
CTI32_Arsenal_Box = "B_supplyCrate_F";
CTI32_Respawn_Truck = "B_W_Truck_01_ammo_F";                       // Mobile Respawn (Fixed 100 S)
CTI32_Crewman = "B_W_Crew_F";                                      // Woodland Crew
CTI32_Pilot = "B_W_Helipilot_F";                                   // Woodland Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team (Woodland/Marksmen DLC)
CTI32_Support_Group1 = [
    "B_W_LSV_01_armed_F",               // Prowler HMG (Woodland)
    [
        "B_W_Recon_TL_F",               // Leader
        "B_W_Recon_M_F",                // Marksman (Woodland)
        "B_W_Recon_LAT_F"               // Recon AT
    ],
    150                                 
];

// Button 2: Woodland Infantry Section
CTI32_Support_Group2 = [
    "B_W_Truck_01_transport_F", 
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_AR_F", 
        "B_W_Soldier_AR_F", 
        "B_W_Soldier_LAT_F", 
        "B_W_Medic_F"
    ],
    250                                 
];

// Button 3: Anti-Tank Squad (Woodland)
CTI32_Support_Group3 = [
    "B_W_LSV_01_AT_F",                  // Prowler AT (Woodland)
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_AT_F", 
        "B_W_Soldier_AT_F", 
        "B_W_Medic_F"
    ],
    300                                 
];

// Button 4: Armored Support (Woodland/Tanks DLC)
CTI32_Support_Group4 = [
    "B_W_APC_Wheeled_01_cannon_F",      // Marshall (Woodland)
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_F", 
        "B_W_Soldier_M_F",              // Marksman (Woodland)
        "B_W_Engineer_F"
    ],
    450                                 
];

// Button 5: Air Assault (Woodland/Dark)
CTI32_Support_Group5 = [
    "B_Heli_Transport_01_F",            // Ghost Hawk (Standard dark livery)
    [
        "B_W_Recon_TL_F", 
        "B_W_Recon_F", 
        "B_W_Recon_LAT_F", 
        "B_W_Recon_M_F"
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["B_W_Quadbike_01_F", 5],                                      
    ["B_W_LSV_01_unarmed_F", 20],                                  
    ["B_W_LSV_01_armed_F", 45],                                    
    ["B_W_MRAP_01_F", 60]                                          // Hunter (Woodland)
];

CTI32_Preset_APC = [
    ["B_W_APC_Wheeled_01_cannon_F", 180],                          
    ["B_W_APC_Tracked_01_rcws_F", 200],                            
    ["B_AFV_Wheeled_01_up_cannon_F", 250]                          // Rhino MGS (Woodland UP)
];

CTI32_Preset_Tanks = [
    ["B_W_MBT_01_cannon_F", 450],                                  // Slammer (Woodland)
    ["B_W_MBT_01_TUSK_F", 500],                                    // Slammer UP (Woodland)
    ["B_W_MBT_01_arty_F", 650]                                     // Scorcher (Woodland)
];

CTI32_Preset_Helis = [
    ["B_Heli_Light_01_F", 150],                                    
    ["B_Heli_Transport_01_F", 250],                                
    ["B_Heli_Transport_03_unarmed_F", 280]                         // Huron
];

CTI32_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550],                       
    ["B_Plane_Fighter_01_F", 700]                                   // Black Wasp II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "B_Heli_Attack_01_dynamicLoadout_F",                           
    "B_Heli_Transport_03_F"                                        // Huron Armed
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "B_Plane_Fighter_01_Stealth_F"                                 
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "B_W_MRAP_01_hmg_F",                                           
    "B_W_MRAP_01_gmg_F"                                            
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "B_W_Truck_01_fuel_F",                                         
    "B_W_Truck_01_Repair_F"                                        
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "B_W_APC_Tracked_01_CRV_F"                                      // Bobcat CRV (Woodland)
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: NATO_Woodland.sqf (Contact/DLC Support) loaded.";
