/*
    Author: Theeane / Gemini
    Function: Blufor Preset - NATO (MTP)
    Project: Operation Iron Mantle
    
    Description: 
    Master Template for NATO Forces. This file defines all purchaseable 
    assets, digital tiers, and physical infrastructure.
*/

// --- 1. PHYSICAL INFRASTRUCTURE (Invulnerable objects) ---
KPIN_FOB_Terminal_Class = "RuggedTerminal_01_communications_F";    // Required for Respawn Truck & Tents
KPIN_Heli_Tower_Class   = "Land_TTowerSmall_1_F";                 // Unlocks Helicopter Category
KPIN_Jet_Control_Class  = "Land_TBox_F";                          // Unlocks Jet Category

// --- 2. CORE SUPPORT ASSETS ---
KPIN_FOB_Truck      = "B_Truck_01_Repair_F"; 
KPIN_FOB_Box        = "B_Slingload_01_Cargo_F"; 
KPIN_Arsenal_Box    = "B_supplyCrate_F"; 
KPIN_Respawn_Truck  = "B_Truck_01_ammo_F"; 
KPIN_Crewman        = "B_crew_F"; 
KPIN_Pilot          = "B_Helipilot_F"; 

// --- 3. TENT SYSTEM (Portable Respawn) ---
KPIN_Tent_Backpack   = "B_Messenger_IDAP_F";  
KPIN_Tent_Object     = "Land_TentDome_F";     
KPIN_Tent_Price      = 10;                    

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---

KPIN_Support_Group1 = [
    "B_LSV_01_armed_F", 
    ["B_recon_TL_F", "B_recon_M_F", "B_recon_F"], 
    150, 2
];

KPIN_Support_Group2 = [
    "B_Truck_01_transport_F", 
    ["B_Soldier_SL_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_soldier_LAT_F", "B_medic_F"], 
    250, 3
];

KPIN_Support_Group3 = [
    "B_LSV_01_AT_F", 
    ["B_Soldier_SL_F", "B_soldier_AT_F", "B_soldier_AT_F", "B_medic_F"], 
    300, 4
];

KPIN_Support_Group4 = [
    "B_APC_Wheeled_01_cannon_F", 
    ["B_Soldier_SL_F", "B_soldier_F", "B_soldier_M_F", "B_engineer_F"], 
    450, 5
];

KPIN_Support_Group5 = [
    "B_Heli_Transport_01_F", 
    ["B_recon_TL_F", "B_recon_F", "B_recon_LAT_F", "B_recon_M_F"], 
    600, 5
];

// --- 5. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---

KPIN_Preset_Light = [
    [KPIN_Respawn_Truck, 100, 1], 
    ["B_Quadbike_01_F", 5, 1],
    ["B_LSV_01_unarmed_F", 20, 1],
    ["B_LSV_01_armed_F", 45, 2],
    ["B_MRAP_01_F", 60, 2]
];

KPIN_Preset_APC = [
    ["B_APC_Wheeled_01_cannon_F", 180, 3],
    ["B_APC_Tracked_01_rcws_F", 200, 3],
    ["B_AFV_Wheeled_01_cannon_F", 250, 4]
];

KPIN_Preset_Tanks = [
    ["B_MBT_01_cannon_F", 450, 5],
    ["B_MBT_01_TUSK_F", 500, 5],
    ["B_MBT_01_arty_F", 650, 5]
];

KPIN_Preset_Helis = [
    ["B_Heli_Light_01_F", 150, 3],
    ["B_Heli_Transport_01_F", 250, 4],
    ["B_Heli_Transport_03_unarmed_F", 280, 5]
];

KPIN_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550, 4],
    ["B_Plane_Fighter_01_F", 700, 5]
];

// --- 6. SPECIAL ASSETS ---
KPIN_Rearm_Truck = ["B_Truck_01_Repair_F", 300, 5]; 

// --- 7. SYNC & BROADCAST ---
private _allVars = [
    "KPIN_FOB_Terminal_Class", "KPIN_Heli_Tower_Class", "KPIN_Jet_Control_Class",
    "KPIN_Tent_Backpack", "KPIN_Tent_Object", "KPIN_Tent_Price",
    "KPIN_FOB_Truck", "KPIN_FOB_Box", "KPIN_Arsenal_Box", "KPIN_Respawn_Truck",
    "KPIN_Support_Group1", "KPIN_Support_Group2", "KPIN_Support_Group3", "KPIN_Support_Group4", "KPIN_Support_Group5",
    "KPIN_Preset_Light", "KPIN_Preset_APC", "KPIN_Preset_Tanks", "KPIN_Preset_Helis", "KPIN_Preset_Jets",
    "KPIN_Rearm_Truck"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[KPIN] Preset: NATO.sqf (Final Naming Convention) Loaded.";
