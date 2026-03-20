/*
    Author: Theane / ChatGPT
    Function: Preset - NATO_Woodland
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for NATO Woodland.
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
MWF_FOB_Truck      = "B_W_Truck_01_Repair_F";                         // HEMTT Repair (Woodland)
MWF_FOB_Box        = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box    = "B_supplyCrate_F";                               // Standard Arsenal box
MWF_Respawn_Truck  = "B_W_Truck_01_ammo_F";                          // Mobile Respawn (Fixed 100 S)
MWF_Respawn_Heli   = "B_W_Heli_Light_01_F"; 
MWF_Virtual_Garage = "Land_HelipadSquare_F"; 

MWF_Crewman        = "B_W_Crew_F";                                     // Woodland Crew
MWF_Pilot          = "B_W_Helipilot_F";                               // Woodland Pilot

// --- 3. TENT SYSTEM (Portable Respawn) ---
MWF_Tent_Backpack   = "B_Messenger_IDAP_F";  // Tent backpack for mobile respawn
MWF_Tent_Object     = "Land_TentDome_F";     // Tent object for respawn
MWF_Tent_Price      = 10;                     // Cost of the tent system

// --- 4. NPC SUPPORT GROUPS [Vehicle, [Units], Price, MinTier] ---

// Group Type: Recon Squad
MWF_Support_Group1 = [
    "B_W_LSV_01_armed_F",               // Prowler HMG (Woodland)
    [
        "B_W_Recon_TL_F",               // Leader
        "B_W_Recon_M_F",                // Marksman
        "B_W_Recon_F"                   // Recon Soldier
    ],
    150, 2
];

// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "B_W_Truck_01_transport_F",  // Transport truck from Woodland
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_AR_F", 
        "B_W_Soldier_AR_F", 
        "B_W_Soldier_LAT_F", 
        "B_W_Soldier_Medic_F"
    ],
    250, 3
];

// Group Type: AT Team
MWF_Support_Group3 = [
    "B_W_LSV_01_AT_F",  // Anti-tank light support vehicle from Woodland
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_AT_F", 
        "B_W_Soldier_AT_F", 
        "B_W_Soldier_Medic_F"
    ],
    300, 4
];

// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "B_W_APC_Wheeled_01_cannon_F",  // APC from Woodland
    [
        "B_W_Soldier_SL_F", 
        "B_W_Soldier_F_F", 
        "B_W_Soldier_M_F", 
        "B_W_Soldier_Engineer_F"
    ],
    450, 5
];

// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "B_W_Heli_Transport_01_F",  // Transport helicopter from Woodland
    [
        "B_W_Soldier_TL_F", 
        "B_W_Soldier_F_F", 
        "B_W_Soldier_LAT_F", 
        "B_W_Soldier_M_F"
    ],
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
    ["B_W_Quadbike_01_F", 5, 1],  // Woodland Quadbike
    ["B_W_LSV_01_unarmed_F", 20, 1],  // Unarmed LSV from Woodland
    ["B_W_LSV_01_armed_F", 45, 2],  // Armed LSV from Woodland
    ["B_W_MRAP_01_F", 60, 2]  // MRAP vehicle from Woodland
];

MWF_Preset_APC = [
    ["B_W_APC_Wheeled_01_cannon_F", 180, 3],  // APC with cannon from Woodland
    ["B_W_APC_Tracked_01_rcws_F", 200, 3],  // Tracked APC from Woodland
    ["B_W_AFV_Wheeled_01_cannon_F", 250, 4]  // Wheeled AFV from Woodland
];

MWF_Preset_Tanks = [
    ["B_W_MBT_01_cannon_F", 450, 5],  // Main battle tank from Woodland
    ["B_W_MBT_01_TUSK_F", 500, 5],  // TUSK variant tank from Woodland
    ["B_W_MBT_01_arty_F", 650, 5]  // Artillery tank from Woodland
];

MWF_Preset_Helis = [
    [MWF_Respawn_Heli, 150, 3],
    ["B_W_Heli_Light_01_F", 150, 3],  // Light helicopter from Woodland
    ["B_W_Heli_Transport_01_F", 250, 4],  // Transport helicopter from Woodland
    ["B_W_Heli_Transport_03_unarmed_F", 280, 5]  // Unarmed transport helicopter from Woodland
];

MWF_Preset_Jets = [
    ["B_W_Plane_CAS_01_dynamicLoadout_F", 550, 4],  // CAS jet from Woodland
    ["B_W_Plane_Fighter_01_F", 700, 5]  // Fighter jet from Woodland
];


MWF_Preset_Light_T5 = [
    ["", 0, 0],
    ["", 0, 0]
];

MWF_Preset_Armor_T5 = [
    ["", 0, 0],
    ["", 0, 0]
];

MWF_Preset_Helis_T5 = [
    ["", 0, 0],
    ["", 0, 0]
];

MWF_Preset_Jets_T5 = [
    ["", 0, 0],
    ["", 0, 0]
];

// --- 6. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["B_W_Truck_01_Repair_F", 300, 5];  // Rearm truck from Woodland

// --- 7. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Respawn_Heli", "MWF_Virtual_Garage", "MWF_Crewman", "MWF_Pilot", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Preset_Light_T5", "MWF_Preset_Armor_T5", "MWF_Preset_Helis_T5", "MWF_Preset_Jets_T5", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: NATO_Woodland.sqf Loaded.";
