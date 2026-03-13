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
CTI32_FOB_Truck      = "B_Truck_01_Repair_F"; 
CTI32_FOB_Box        = "B_Slingload_01_Cargo_F"; 
CTI32_Arsenal_Box    = "B_supplyCrate_F"; 
CTI32_Respawn_Truck  = "B_Truck_01_ammo_F"; // Mobile Respawn Truck (100 S)
CTI32_Crewman        = "B_crew_F"; 
CTI32_Pilot          = "B_Helipilot_F"; 

// --- 3. TENT SYSTEM (Portable Respawn) ---
KPIN_Tent_Backpack   = "B_Messenger_IDAP_F";  // The item to buy and carry
KPIN_Tent_Object     = "Land_TentDome_F";     // The physical spawn point object
KPIN_Tent_Price      = 10;                    // Cost in Supplies

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---

// Button 1: Recon Team
CTI32_Support_Group1 = [
    "B_LSV_01_armed_F", 
    ["B_recon_TL_F", "B_recon_M_F", "B_recon_F"], 
    150, 2
];

// Button 2: Heavy Infantry Section
CTI32_Support_Group2 = [
    "B_Truck_01_transport_F", 
    ["B_Soldier_SL_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_soldier_LAT_F", "B_medic_F"], 
    250, 3
];

// Button 3: Anti-Tank Squad
CTI32_Support_Group3 = [
    "B_LSV_01_AT_F", 
    ["B_Soldier_SL_F", "B_soldier_AT_F", "B_soldier_AT_F", "B_medic_F"], 
    300, 4
];

// Button 4: Armored Support
CTI32_Support_Group4 = [
    "B_APC_Wheeled_01_cannon_F", 
    ["B_Soldier_SL_F", "B_soldier_F", "B_soldier_M_F", "B_engineer_F"], 
    450, 5
];

// Button 5: Air Assault (Requires Heli Unlock + Tier 5)
CTI32_Support_Group5 = [
    "B_Heli_Transport_01_F", 
    ["B_recon_TL_F", "B_recon_F", "B_recon_LAT_F", "B_recon_M_F"], 
    600, 5
];

// --- 5. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100, 1], // Restricted by Terminal, not Tier
    ["B_Quadbike_01_F", 5, 1],
    ["B_LSV_01_unarmed_F", 20, 1],
    ["B_LSV_01_armed_F", 45, 2],
    ["B_MRAP_01_F", 60, 2]
];

CTI32_Preset_APC = [
    ["B_APC_Wheeled_01_cannon_F", 180, 3],
    ["B_APC_Tracked_01_rcws_F", 200, 3],
    ["B_AFV_Wheeled_01_cannon_F", 250, 4]
];

CTI32_Preset_Tanks = [
    ["B_MBT_01_cannon_F", 450, 5],
    ["B_MBT_01_TUSK_F", 500, 5],
    ["B_MBT_01_arty_F", 650, 5]
];

CTI32_Preset_Helis = [
    ["B_Heli_Light_01_F", 150, 3],
    ["B_Heli_Transport_01_F", 250, 4],
    ["B_Heli_Transport_03_unarmed_F", 280, 5]
];

CTI32_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550, 4],
    ["B_Plane_Fighter_01_F", 700, 5]
];

// --- 6. SPECIAL ASSETS ---
CTI32_Rearm_Truck = ["B_Truck_01_Repair_F", 300, 5]; // Rearm trucks require Tier 5

// --- 7. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "KPIN_FOB_Terminal_Class", "KPIN_Heli_Tower_Class", "KPIN_Jet_Control_Class",
    "KPIN_Tent_Backpack", "KPIN_Tent_Object", "KPIN_Tent_Price",
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Rearm_Truck"
];

diag_log "[CTI32] Preset: NATO.sqf (Full Tier & Logistics) Loaded.";
