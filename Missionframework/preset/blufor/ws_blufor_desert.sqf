/*
    Author: Theane / ChatGPT
    Function: Preset - ws_blufor_desert
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for WS BLUFOR Desert.
*/

// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";



// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "B_D_Truck_01_Repair_F";                        // HEMTT Repair (Desert)
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "B_D_Truck_01_ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
MWF_Crewman = "B_D_crew_F";                                      // Default crew for armored vehicles
MWF_Pilot = "B_D_Helipilot_F";                                   // Default pilot for helis and jets

// --- 2. LOGISTICS & ECONOMY ---
// Supply and Intel are digital currencies. 

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team (Zubr Patrol)
// Group Type: Recon Squad
MWF_Support_Group1 = [
    "B_D_LSV_01_armed_F",              // Zubr armed patrol vehicle (Desert)
    [
        "B_D_Soldier_SL_F",             // Team Leader
        "B_D_Soldier_M_F",              // Marksman
        "B_D_Soldier_AR_F"              // Automatic Rifleman
    ],
    150, 2
];

// Button 2: Transport Team (Logistics)
// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "B_D_Truck_01_transport_F",        // Transport truck (Desert)
    [
        "B_D_Soldier_SL_F", 
        "B_D_Soldier_AR_F", 
        "B_D_Soldier_AR_F", 
        "B_D_Soldier_LAT_F", 
        "B_D_Soldier_Medic_F"
    ],
    250, 3
];

// Button 3: Armored Team (Desert APC)
// Group Type: AT Team
MWF_Support_Group3 = [
    "B_D_APC_Wheeled_01_F",            // APC from WS
    [
        "B_D_Soldier_SL_F", 
        "B_D_Soldier_F_F", 
        "B_D_Soldier_M_F", 
        "B_D_Soldier_Engineer_F"
    ],
    350, 4
];

// Button 4: Tank Support
// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "B_D_MBT_01_cannon_F",             // Main Battle Tank (Desert)
    [
        "B_D_Soldier_SL_F", 
        "B_D_Soldier_F_F", 
        "B_D_Soldier_M_F", 
        "B_D_Soldier_LAT_F"
    ],
    500, 5
];

// Button 5: Helicopter Support
// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "B_D_Heli_Transport_01_F",         // Transport helicopter (Desert)
    [
        "B_D_Soldier_TL_F", 
        "B_D_Soldier_F_F", 
        "B_D_Soldier_LAT_F", 
        "B_D_Soldier_M_F"
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
    ["B_D_Quadbike_01_F", 5, 1],        // Quadbike from WS (Desert)
    ["B_D_LSV_01_unarmed_F", 20, 1],   // Unarmed LSV from WS (Desert)
    ["B_D_LSV_01_armed_F", 45, 2],     // Armed LSV from WS (Desert)
    ["B_D_MRAP_01_F", 60, 2]           // MRAP vehicle from WS (Desert)
];

MWF_Preset_APC = [
    ["B_D_APC_Wheeled_01_F", 180, 3],  // APC from WS (Desert)
    ["B_D_AFV_Wheeled_01_cannon_F", 250, 4]  // AFV from WS (Desert)
];

MWF_Preset_Tanks = [
    ["B_D_MBT_01_cannon_F", 450, 5],   // Main battle tank from WS (Desert)
    ["B_D_MBT_01_TUSK_F", 500, 5],     // TUSK variant tank from WS (Desert)
    ["B_D_MBT_01_arty_F", 650, 5]      // Artillery tank from WS (Desert)
];

MWF_Preset_Helis = [
    ["B_D_Heli_Light_01_F", 150, 3],   // Light helicopter from WS (Desert)
    ["B_D_Heli_Transport_01_F", 250, 4],  // Transport helicopter from WS (Desert)
    ["B_D_Heli_Transport_03_unarmed_F", 280, 5]  // Unarmed transport helicopter from WS (Desert)
];

MWF_Preset_Jets = [
    ["B_D_Plane_CAS_01_dynamicLoadout_F", 550, 4],  // CAS jet from WS (Desert)
    ["B_D_Plane_Fighter_01_F", 700, 5]   // Fighter jet from WS (Desert)
];

// --- 5. SPECIAL ASSETS ---
MWF_Rearm_Truck = ["B_D_Truck_01_Repair_F", 300, 5];  // Rearm truck from WS (Desert)

// --- 6. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: ws_blufor_desert.sqf Loaded.";
