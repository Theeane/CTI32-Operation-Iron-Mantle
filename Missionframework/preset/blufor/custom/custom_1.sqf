/*
    Author: Theane / ChatGPT
    Function: Preset - Custom
    Project: Military War Framework

    Description:
    Defines custom assets for BLUFOR preset in Military War Framework.
*/

// --- 1. PHYSICAL INFRASTRUCTURE (Invulnerable objects) ---
MWF_FOB_Terminal_Class = "RuggedTerminal_01_communications_F";    // Required for Respawn Truck & Tents
MWF_Heli_Tower_Class   = "Land_TTowerSmall_1_F";                 // Unlocks Helicopter Category
MWF_Jet_Control_Class  = "Land_TBox_F";                          // Unlocks Jet Category
// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";
// --- 2. CORE SUPPORT ASSETS ---
MWF_FOB_Truck      = "B_Truck_01_Repair_F"; 
MWF_FOB_Box        = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box    = "B_supplyCrate_F"; 
MWF_Respawn_Truck  = "B_Truck_01_ammo_F"; 
MWF_Crewman        = "B_crew_F"; 
MWF_Pilot          = "B_Helipilot_F"; 

// --- 3. TENT SYSTEM (Portable Respawn) ---
MWF_Tent_Backpack   = "B_Messenger_IDAP_F";  
MWF_Tent_Object     = "Land_TentDome_F";     
MWF_Tent_Price      = 10;                    

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---
// Group Type: Recon Squad
MWF_Support_Group1 = [
    "B_LSV_01_armed_F", 
    ["B_recon_TL_F", "B_recon_M_F", "B_recon_F"], 
    150, 2
];

// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "B_Truck_01_transport_F", 
    ["B_Soldier_SL_F", "B_Soldier_AR_F", "B_Soldier_AR_F", "B_soldier_LAT_F", "B_medic_F"], 
    250, 3
];

// Group Type: AT Team
MWF_Support_Group3 = [
    "B_LSV_01_AT_F", 
    ["B_Soldier_SL_F", "B_soldier_AT_F", "B_soldier_AT_F", "B_medic_F"], 
    300, 4
];

// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "B_APC_Wheeled_01_cannon_F", 
    ["B_Soldier_SL_F", "B_soldier_F", "B_soldier_M_F", "B_engineer_F"], 
    450, 5
];

// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "B_Heli_Transport_01_F", 
    ["B_recon_TL_F", "B_recon_F", "B_recon_LAT_F", "B_recon_M_F"], 
    600, 5
];


MWF_Support_GroupMeta = [
    ["MWF_Support_Group1", "Recon Squad"],
    ["MWF_Support_Group2", "Rifle Squad"],
    ["MWF_Support_Group3", "AT Team"],
    ["MWF_Support_Group4", "Mechanized Squad"],
    ["MWF_Support_Group5", "Air Assault Team"]
];

// --- 5. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---
MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100, 1], 
    ["B_Quadbike_01_F", 5, 1],
    ["B_LSV_01_unarmed_F", 20, 1],
    ["B_LSV_01_armed_F", 45, 2],
    ["B_MRAP_01_F", 60, 2]
];

MWF_Preset_APC = [
    ["B_APC_Wheeled_01_cannon_F", 180, 3],
    ["B_APC_Tracked_01_rcws_F", 200, 3],
    ["B_AFV_Wheeled_01_cannon_F", 250, 4]
];

MWF_Preset_Tanks = [
    ["B_MBT_01_cannon_F", 450, 5],
    ["B_MBT_01_TUSK_F", 500, 5],
    ["B_MBT_01_arty_F", 650, 5]
];

MWF_Preset_Helis = [
    ["B_Heli_Light_01_F", 150, 3],
    ["B_Heli_Transport_01_F", 250, 4],
    ["B_Heli_Transport_03_unarmed_F", 280, 5]
];

MWF_Preset_Jets = [
    ["B_Plane_CAS_01_dynamicLoadout_F", 550, 4],
    ["B_Plane_Fighter_01_F", 700, 5]
];

// --- 6. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["B_Truck_01_Repair_F", 300, 5]; 

// --- 7. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: Custom.sqf Loaded.";
