/*
    Author: Theane / ChatGPT
    Function: Preset - RHS_USAF_Desert
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for RHS USAF Desert.
*/

// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";



// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "rhsusf_M1083A1P2_B_D_repair_fmtv_usarmy";       // M1083A1 Repair (Desert)
MWF_FOB_Box = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box = "B_supplyCrate_F";                             // Standard Arsenal box
MWF_Respawn_Truck = "rhsusf_M1083A1P2_B_D_fmtv_usarmy";          // M1083A1 Transport as Respawn (Fixed 100 S)
MWF_Respawn_Heli   = "rhsusf_CH53E"; 
MWF_Virtual_Garage = "Land_HelipadSquare_F"; 

MWF_Crewman = "rhsusf_army_ocp_combatcrewman";                   // Default crew
MWF_Pilot = "rhsusf_army_ocp_helipilot";                         // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Physical Intel (Laptops/Officers) rules apply.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
// Group Type: Recon Squad
MWF_Support_Group1 = [
    "rhsusf_m1025_w_m2",                // HMMWV M2
    [
        "rhsusf_army_ocp_teamleader",   // Leader
        "rhsusf_army_ocp_marksman",     // Marksman
        "rhsusf_army_ocp_rifleman"      // Rifleman
    ],
    150, 2
];

// Button 2: Transport Team
// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "rhsusf_M1083A1P2_B_D_transport_fmtv_usarmy",  // M1083 Transport Truck
    [
        "rhsusf_army_ocp_teamleader", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_medic", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_soldierlat"
    ],
    250, 3
];

// Button 3: Armored Support
// Group Type: AT Team
MWF_Support_Group3 = [
    "rhsusf_M2A3_Abrams",  // M2A3 Abrams
    [
        "rhsusf_army_ocp_teamleader", 
        "rhsusf_army_ocp_gunner", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_engineer"
    ],
    350, 4
];

// Button 4: Tank Support
// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "rhsusf_M1A2_Abrams",  // M1A2 Abrams
    [
        "rhsusf_army_ocp_teamleader", 
        "rhsusf_army_ocp_gunner", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_soldierlat"
    ],
    500, 5
];

// Button 5: Helicopter Support
// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "rhsusf_CH53E",  // Helicopter from RHS
    [
        "rhsusf_army_ocp_pilot", 
        "rhsusf_army_ocp_rifleman"
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

// --- 4. VEHICLE CATEGORIES [Classname, Cost, MinTier] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100, 1], 
    ["rhsusf_M1083A1P2_B_D_fmtv_usarmy", 50, 1],  // Transport truck from RHS
    ["rhsusf_M1025_w_M2", 40, 2]  // HMMWV with M2 from RHS
];

MWF_Preset_APC = [
    ["rhsusf_M2A3_Abrams", 350, 4],  // M2A3 Abrams from RHS
    ["rhsusf_M1A2_Abrams", 450, 5]   // M1A2 Abrams from RHS
];

MWF_Preset_Tanks = [
    ["rhsusf_M1A2_Abrams", 550, 5]  // M1A2 tank from RHS
];

MWF_Preset_Helis = [
    [MWF_Respawn_Heli, 150, 3],
    ["rhsusf_CH53E", 300, 5],  // CH-53E from RHS
    ["rhsusf_UH60M", 250, 3]   // UH-60M from RHS
];

MWF_Preset_Jets = [
    ["rhsusf_F16C", 700, 5]  // F16 from RHS
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
MWF_Rearm_Truck = ["rhsusf_M1083A1P2_B_D_repair_fmtv_usarmy", 300, 5];  // Rearm truck from RHS

// --- 6. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Respawn_Heli", "MWF_Virtual_Garage", "MWF_Crewman", "MWF_Pilot", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Preset_Light_T5", "MWF_Preset_Armor_T5", "MWF_Preset_Helis_T5", "MWF_Preset_Jets_T5", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: RHS_USAF_Desert.sqf Loaded.";
