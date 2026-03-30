/*
    Author: Theane / ChatGPT
    Function: Preset - CUP_ACR_Woodland
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for CUP ACR Woodland.
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
MWF_FOB_Truck      = "CUP_B_T810_Repair_CZ_WDL";  // CUP-specific truck for repairing (Woodland)
MWF_FOB_Box        = "B_Slingload_01_Cargo_F"; // Support container for FOB
MWF_Arsenal_Box    = "B_supplyCrate_F";  // Arsenal crate for supplying gear
MWF_Respawn_Truck  = "CUP_B_T810_Reammo_CZ_WDL";  // Mobile ammo supply for respawn (Woodland)
MWF_Respawn_Heli   = "CUP_Heli_Light_01_F"; 
MWF_Virtual_Garage = "Land_HelipadSquare_F"; 

MWF_Crewman        = "CUP_B_CZ_Crew_WDL";   // CUP-specific crewman for vehicles (Woodland)
MWF_Pilot          = "CUP_B_CZ_Pilot_WDL";  // CUP-specific pilot for helicopters (Woodland)

// --- 3. TENT SYSTEM (Portable Respawn) ---
MWF_Tent_Backpack   = "B_Messenger_IDAP_F";  // Tent backpack for mobile respawn
MWF_Tent_Object     = "Land_TentDome_F";     // Tent object for respawn
MWF_Tent_Price      = 10;                     // Cost of the tent system

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---

// Group Type: Recon Squad
MWF_Support_Group1 = [
    "CUP_LSV_01_armed_F",  // Armed light support vehicle from CUP
    ["CUP_B_CZ_Soldier_Desert_F", "CUP_B_CZ_Soldier_M_F", "CUP_B_CZ_Soldier_F"], 
    150, 2
];

// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "CUP_Truck_01_transport_F",  // Transport truck from CUP
    ["CUP_B_CZ_Soldier_SL_F", "CUP_B_CZ_Soldier_AR_F", "CUP_B_CZ_Soldier_AR_F", "CUP_B_CZ_Soldier_LAT_F", "CUP_B_CZ_Soldier_Medic_F"], 
    250, 3
];

// Group Type: AT Team
MWF_Support_Group3 = [
    "CUP_LSV_01_AT_F",  // Anti-tank light support vehicle from CUP
    ["CUP_B_CZ_Soldier_SL_F", "CUP_B_CZ_Soldier_AT_F", "CUP_B_CZ_Soldier_AT_F", "CUP_B_CZ_Soldier_Medic_F"], 
    300, 4
];

// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "CUP_APC_Wheeled_01_cannon_F",  // Wheeled APC from CUP
    ["CUP_B_CZ_Soldier_SL_F", "CUP_B_CZ_Soldier_F", "CUP_B_CZ_Soldier_M_F", "CUP_B_CZ_Soldier_Engineer_F"], 
    450, 5
];

// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "CUP_Heli_Transport_01_F",  // Transport helicopter from CUP
    ["CUP_B_CZ_Soldier_TL_F", "CUP_B_CZ_Soldier_F", "CUP_B_CZ_Soldier_LAT_F", "CUP_B_CZ_Soldier_M_F"], 
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
    [MWF_Respawn_Heli, 150, 3],
    ["CUP_Heli_Light_01_F", 150, 3],  // Light helicopter from CUP
    ["CUP_Heli_Transport_01_F", 250, 4],  // Transport helicopter from CUP
    ["CUP_Heli_Transport_03_unarmed_F", 280, 5]  // Unarmed transport helicopter from CUP
];

MWF_Preset_Jets = [
    ["CUP_Plane_CAS_01_dynamicLoadout_F", 550, 4],  // CAS jet from CUP
    ["CUP_Plane_Fighter_01_F", 700, 5]  // Fighter jet from CUP
];


MWF_Preset_Light_T5 = [
    ["B_MRAP_01_hmg_F", 90, 5]
];

MWF_Preset_Armor_T5 = [
    ["B_APC_Tracked_01_CRV_F", 325, 5]
];

MWF_Preset_Tanks_T5 = [
    ["B_MBT_01_mlrs_F", 900, 5]
];

MWF_Preset_Helis_T5 = [
    ["B_Heli_Attack_01_F", 600, 5]
];

MWF_Preset_Jets_T5 = [
    ["B_Plane_Fighter_01_F", 900, 5]
];

// --- 6. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["CUP_B_Truck_01_Repair_F", 300, 5];  // Rearm truck from CUP

// --- 7. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Respawn_Heli", "MWF_Virtual_Garage", "MWF_Crewman", "MWF_Pilot", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Preset_Light_T5", "MWF_Preset_Armor_T5", "MWF_Preset_Tanks_T5", "MWF_Preset_Helis_T5", "MWF_Preset_Jets_T5", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: CUP_ACR_Woodland.sqf Loaded.";
