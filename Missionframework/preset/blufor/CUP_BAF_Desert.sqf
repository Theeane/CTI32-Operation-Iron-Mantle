/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_BAF_Desert
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for CUP BAF Desert.
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
MWF_FOB_Truck      = "CUP_B_MTVR_Repair_BAF_DES";  // Heavy FOB builder truck from CUP BAF
MWF_FOB_Box        = "B_Slingload_01_Cargo_F";     // FOB container from CUP
MWF_Arsenal_Box    = "B_supplyCrate_F";            // Arsenal crate for supplying gear
MWF_Respawn_Truck  = "CUP_B_MTVR_Reammo_BAF_DES";  // Mobile Respawn vehicle (Ammo truck from CUP BAF)
MWF_Crewman        = "CUP_B_BAF_Soldier_Crew_DDPM"; // CUP BAF Crewman class
MWF_Pilot          = "CUP_B_BAF_Soldier_Pilot_DDPM"; // CUP BAF Pilot class

// --- 3. TENT SYSTEM (Portable Respawn) ---
MWF_Tent_Backpack   = "B_Messenger_IDAP_F";  // Tent backpack for mobile respawn
MWF_Tent_Object     = "Land_TentDome_F";     // Tent object for respawn
MWF_Tent_Price      = 10;                     // Cost of the tent system

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---

// Group Type: Recon Squad
MWF_Support_Group1 = [
    "CUP_LSV_01_armed_F",  // Armed light support vehicle from CUP
    ["CUP_B_BAF_Soldier_SL_DDPM", "CUP_B_BAF_Soldier_AR_DDPM", "CUP_B_BAF_Soldier_AR_DDPM"], 
    150, 2
];

// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "CUP_Truck_01_transport_F",  // Transport truck from CUP
    ["CUP_B_BAF_Soldier_SL_DDPM", "CUP_B_BAF_Soldier_AR_DDPM", "CUP_B_BAF_Soldier_AR_DDPM", "CUP_B_BAF_Soldier_LAT_DDPM", "CUP_B_BAF_Soldier_Medic_DDPM"], 
    250, 3
];

// Group Type: AT Team
MWF_Support_Group3 = [
    "CUP_LSV_01_AT_F",  // Anti-tank light support vehicle from CUP
    ["CUP_B_BAF_Soldier_SL_DDPM", "CUP_B_BAF_Soldier_AT_DDPM", "CUP_B_BAF_Soldier_AT_DDPM", "CUP_B_BAF_Soldier_Medic_DDPM"], 
    300, 4
];

// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "CUP_APC_Wheeled_01_cannon_F",  // Wheeled APC from CUP
    ["CUP_B_BAF_Soldier_SL_DDPM", "CUP_B_BAF_Soldier_F_DDPM", "CUP_B_BAF_Soldier_M_DDPM", "CUP_B_BAF_Soldier_Engineer_DDPM"], 
    450, 5
];

// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "CUP_Heli_Transport_01_F",  // Transport helicopter from CUP
    ["CUP_B_BAF_Soldier_TL_DDPM", "CUP_B_BAF_Soldier_F_DDPM", "CUP_B_BAF_Soldier_LAT_DDPM", "CUP_B_BAF_Soldier_M_DDPM"], 
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
    ["CUP_Quadbike_01_F", 5, 1],  // CUP Quadbike
    ["CUP_LSV_01_unarmed_F", 20, 1],  // Unarmed LSV from CUP
    ["CUP_LSV_01_armed_F", 45, 2],  // Armed LSV from CUP
    ["CUP_MRAP_01_F", 60, 2]  // MRAP vehicle from CUP
];

MWF_Preset_APC = [
    ["CUP_APC_Wheeled_01_cannon_F", 180, 3],  // APC with cannon from CUP
    ["CUP_APC_Tracked_01_rcws_F", 200, 3],  // Tracked APC from CUP
    ["CUP_AFV_Wheeled_01_cannon_F", 250, 4]  // Wheeled AFV from CUP
];

MWF_Preset_Tanks = [
    ["CUP_MBT_01_cannon_F", 450, 5],  // Main battle tank from CUP
    ["CUP_MBT_01_TUSK_F", 500, 5],  // TUSK variant tank from CUP
    ["CUP_MBT_01_arty_F", 650, 5]  // Artillery tank from CUP
];

MWF_Preset_Helis = [
    ["CUP_Heli_Light_01_F", 150, 3],  // Light helicopter from CUP
    ["CUP_Heli_Transport_01_F", 250, 4],  // Transport helicopter from CUP
    ["CUP_Heli_Transport_03_unarmed_F", 280, 5]  // Unarmed transport helicopter from CUP
];

MWF_Preset_Jets = [
    ["CUP_Plane_CAS_01_dynamicLoadout_F", 550, 4],  // CAS jet from CUP
    ["CUP_Plane_Fighter_01_F", 700, 5]  // Fighter jet from CUP
];

// --- 6. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["CUP_B_Truck_01_Repair_F", 300, 5];  // Rearm truck from CUP

// --- 7. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: CUP_BAF_Desert.sqf Loaded.";
