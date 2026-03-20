/*
    Author: Theane / ChatGPT
    Function: Preset - SOG_MACV
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for SOG MACV.
*/

// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";



// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "vn_b_wheeled_m54_repair";                     // M54 Repair Truck
MWF_FOB_Box = "vn_b_static_m45_01"; 
MWF_Arsenal_Box = "vn_b_ammobox_supply_05";                    // Standard Arsenal box
MWF_Respawn_Truck = "vn_b_wheeled_m54_ammo";                   // M54 Ammo (Fixed 100 S)
MWF_Crewman = "vn_b_m_69_01";                                  // MACV Crewman
MWF_Pilot = "vn_b_m_43_01";                                    // MACV Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Physical Intel (Laptops/Officers) rules apply.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: MACV-SOG Recon Team
// Group Type: Recon Squad
MWF_Support_Group1 = [
    "vn_b_wheeled_m151_mg_01", 
    [
        "vn_b_is_army_07",             // Team Leader
        "vn_b_is_army_08",             // Marksman
        "vn_b_is_army_01"              // Scout
    ],
    150, 2
];

// Button 2: US Army Squad
// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "vn_b_wheeled_m151_mg_01", 
    [
        "vn_b_is_army_06", 
        "vn_b_is_army_01", 
        "vn_b_is_army_03"
    ],
    200, 3
];

// Button 3: US Army APC
// Group Type: AT Team
MWF_Support_Group3 = [
    "vn_b_armored_m113_mg_01", 
    [
        "vn_b_is_army_04", 
        "vn_b_is_army_05", 
        "vn_b_is_army_02"
    ],
    300, 4
];

// Button 4: M113 APC & Infantry
// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "vn_b_armored_m113_mg_01", 
    [
        "vn_b_is_army_06", 
        "vn_b_is_army_07", 
        "vn_b_is_army_05"
    ],
    350, 5
];

// Button 5: Helicopter Support
// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "vn_b_heli_mi8", 
    [
        "vn_b_is_pilot_01", 
        "vn_b_is_army_07"
    ],
    400, 5
];

MWF_Support_GroupMeta = [
    ["MWF_Support_Group1", "Recon Squad"],
    ["MWF_Support_Group2", "Rifle Squad"],
    ["MWF_Support_Group3", "AT Team"],
    ["MWF_Support_Group4", "Mechanized Squad"],
    ["MWF_Support_Group5", "Air Assault Team"]
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100, 1], 
    ["vn_b_wheeled_m151_mg_01", 50, 1], // M151 from SOG MACV
    ["vn_b_wheeled_m54_ammo", 60, 2]   // M54 Ammo from SOG MACV
];

MWF_Preset_APC = [
    ["vn_b_armored_m113_mg_01", 200, 3], // APC from SOG MACV
    ["vn_b_wheeled_m54_repair", 250, 4]  // M54 Repair from SOG MACV
];

MWF_Preset_Tanks = [
    ["vn_b_armored_m113_mg_01", 350, 4]  // M113 APC from SOG MACV
];

MWF_Preset_Helis = [
    ["vn_b_heli_mi8", 300, 5],  // Mi8 helicopter from SOG MACV
    ["vn_b_heli_mi24", 350, 5]  // Mi24 from SOG MACV
];

MWF_Preset_Jets = [
    ["vn_b_jet_01", 500, 5]  // Jet from SOG MACV
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

// --- 5. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["vn_b_wheeled_m54_repair", 300, 5];  // Rearm truck from SOG MACV

// --- 6. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Preset_Light_T5", "MWF_Preset_Armor_T5", "MWF_Preset_Helis_T5", "MWF_Preset_Jets_T5", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: SOG_MACV.sqf Loaded.";
