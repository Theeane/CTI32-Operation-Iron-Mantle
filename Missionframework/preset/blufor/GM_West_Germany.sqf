/*
    Author: Theane / ChatGPT
    Function: Preset - GM_West_Germany
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for GM West Germany.
*/

// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";



// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "gm_ge_army_u1300l_repair";                      // Unimog Repair
MWF_FOB_Box = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box = "B_supplyCrate_F";                             // Standard Arsenal box
MWF_Respawn_Truck = "gm_ge_army_kat1_451_reargo";                // KAT1 5t Reammo (Fixed 100 S)
MWF_Crewman = "gm_ge_army_conscript_80_oli";                     // Default crew
MWF_Pilot = "gm_ge_army_pilot_p1_80_oli";                        // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Using MWF_S_Currency

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
MWF_Support_Group1 = [
    "gm_ge_army_iltis_m2",              // Iltis (M2)
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_ls",   // Marksman/Scout
    ],
    150, 2
];

// Button 2: Transport Team
MWF_Support_Group2 = [
    "gm_ge_army_mtz_451_repair",  // MTZ truck from GM
    [
        "gm_ge_army_conscript_80_sl", 
        "gm_ge_army_conscript_80_ls", 
        "gm_ge_army_conscript_80_medic"
    ],
    250, 3
];

// Button 3: Armored Support
MWF_Support_Group3 = [
    "gm_ge_army_marder_1a3",  // Marder APC from GM
    [
        "gm_ge_army_conscript_80_sl", 
        "gm_ge_army_conscript_80_gunner", 
        "gm_ge_army_conscript_80_technician"
    ],
    300, 4
];

// Button 4: Artillery Support
MWF_Support_Group4 = [
    "gm_ge_army_pzh2000",  // PZH 2000 Artillery from GM
    [
        "gm_ge_army_conscript_80_sl", 
        "gm_ge_army_conscript_80_gunner", 
        "gm_ge_army_conscript_80_ammo"
    ],
    350, 4
];

// Button 5: Helicopter Support
MWF_Support_Group5 = [
    "gm_ge_army_bo105",  // Helicopter from GM
    [
        "gm_ge_army_pilot_p1_80_oli", 
        "gm_ge_army_conscript_80_heli_gunner"
    ],
    500, 5
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100, 1], 
    ["gm_ge_army_iltis", 20, 1],  // GM Iltis vehicle
    ["gm_ge_army_mtz_451_repair", 50, 2],  // GM repair truck
    ["gm_ge_army_bo105", 100, 3]  // GM Helicopter
];

MWF_Preset_APC = [
    ["gm_ge_army_marder_1a3", 200, 3],  // APC from GM
    ["gm_ge_army_mtz_451_transport", 150, 3]  // GM transport truck
];

MWF_Preset_Tanks = [
    ["gm_ge_army_pzh2000", 500, 5]  // Artillery from GM
];

MWF_Preset_Helis = [
    ["gm_ge_army_bo105", 250, 4],  // GM Helicopter
    ["gm_ge_army_puma", 300, 5]  // Another helicopter from GM
];

// --- 5. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["gm_ge_army_u1300l_repair", 300, 5];  // Rearm truck from GM

// --- 6. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: GM_West_Germany.sqf Loaded.";
