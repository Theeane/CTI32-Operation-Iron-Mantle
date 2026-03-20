/*
    Author: Theane / ChatGPT
    Function: Preset - LDF_Contact
    Project: Military War Framework

    Description:
    Defines the BLUFOR preset configuration for LDF Contact.
*/

// --- 1A. FOB ASSET CONFIGURATION ---
MWF_FOB_Asset_Roof = "";
MWF_FOB_Asset_Table = "Land_CampingTable_small_F";
MWF_FOB_Asset_Terminal = "Land_Laptop_unfolded_F";
MWF_FOB_Asset_Siren = "Land_Loudspeakers_F";
MWF_FOB_Asset_Lamp = "Land_Camping_Light_F";



// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "I_E_Truck_02_Medical_F";                        // Zamak Medical (Contact)
MWF_FOB_Box = "B_Slingload_01_Cargo_F";                         // FOB construction container
MWF_Arsenal_Box = "B_supplyCrate_F";                            // Portable virtual arsenal crate
MWF_Respawn_Truck = "I_E_Truck_02_Ammo_F";                       // Mobile Respawn vehicle (Fixed 100 S)
MWF_Respawn_Heli   = "I_E_Heli_Light_01_F"; 
MWF_Virtual_Garage = "Land_HelipadSquare_F"; 

MWF_Crewman = "I_E_Crew_F";                                      // LDF Crew
MWF_Pilot = "I_E_Helipilot_F";                                   // LDF Pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active. Physical Intel (Laptops/Officers) rules apply.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
// Group Type: Recon Squad
MWF_Support_Group1 = [
    "I_E_LSV_01_armed_F",  // Armed light support vehicle from LDF Contact
    ["I_E_Soldier_SL_F", "I_E_Soldier_M_F", "I_E_Soldier_AR_F"], 
    150, 2
];

// Button 2: Transport Team
// Group Type: Rifle Squad
MWF_Support_Group2 = [
    "I_E_Truck_02_transport_F",  // Transport truck from LDF Contact
    ["I_E_Soldier_SL_F", "I_E_Soldier_AR_F", "I_E_Soldier_LAT_F", "I_E_Soldier_Medic_F"], 
    250, 3
];

// Button 3: Armored Support
// Group Type: AT Team
MWF_Support_Group3 = [
    "I_E_LSV_01_AT_F",  // Anti-tank light support vehicle from LDF Contact
    ["I_E_Soldier_SL_F", "I_E_Soldier_AT_F", "I_E_Soldier_AT_F", "I_E_Soldier_Medic_F"], 
    300, 4
];

// Button 4: APC Support
// Group Type: Mechanized Squad
MWF_Support_Group4 = [
    "I_E_APC_Wheeled_01_F",  // APC from LDF Contact
    ["I_E_Soldier_SL_F", "I_E_Soldier_F_F", "I_E_Soldier_M_F", "I_E_Soldier_Engineer_F"], 
    450, 5
];

// Button 5: Helicopter Support
// Group Type: Air Assault Team
MWF_Support_Group5 = [
    "I_E_Heli_Transport_01_F",  // Transport helicopter from LDF Contact
    ["I_E_Soldier_TL_F", "I_E_Soldier_F_F", "I_E_Soldier_LAT_F", "I_E_Soldier_M_F"], 
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
    ["I_E_LSV_01_unarmed_F", 20, 1],  // Unarmed LSV from LDF
    ["I_E_LSV_01_armed_F", 45, 2],  // Armed LSV from LDF
    ["I_E_MRAP_01_F", 60, 2]  // MRAP vehicle from LDF
];

MWF_Preset_APC = [
    ["I_E_APC_Wheeled_01_F", 180, 3],  // APC from LDF
    ["I_E_AFV_Wheeled_01_F", 250, 4]  // AFV from LDF
];

MWF_Preset_Tanks = [
    ["I_E_MBT_01_cannon_F", 450, 5],  // Main battle tank from LDF
    ["I_E_MBT_01_TUSK_F", 500, 5]  // TUSK variant from LDF
];

MWF_Preset_Helis = [
    [MWF_Respawn_Heli, 150, 3],
    ["I_E_Heli_Light_01_F", 150, 3],  // Light helicopter from LDF
    ["I_E_Heli_Transport_01_F", 250, 4],  // Transport helicopter from LDF
    ["I_E_Heli_Transport_03_unarmed_F", 280, 5]  // Unarmed transport helicopter from LDF
];

MWF_Preset_Jets = [
    ["I_E_Plane_CAS_01_dynamicLoadout_F", 550, 4],  // CAS jet from LDF
    ["I_E_Plane_Fighter_01_F", 700, 5]  // Fighter jet from LDF
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
MWF_Rearm_Truck = ["I_E_Truck_02_Medical_F", 300, 5];  // Rearm truck from LDF

// --- 6. SYNC & BROADCAST ---
private _allVars = [
    "MWF_FOB_Terminal_Class", "MWF_Heli_Tower_Class", "MWF_Jet_Control_Class", "MWF_Tent_Backpack", "MWF_Tent_Object", "MWF_Tent_Price", "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Respawn_Heli", "MWF_Virtual_Garage", "MWF_Crewman", "MWF_Pilot", "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5", "MWF_Support_GroupMeta", "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets", "MWF_Preset_Light_T5", "MWF_Preset_Armor_T5", "MWF_Preset_Helis_T5", "MWF_Preset_Jets_T5", "MWF_Rearm_Truck", "MWF_FOB_Asset_Roof", "MWF_FOB_Asset_Table", "MWF_FOB_Asset_Terminal", "MWF_FOB_Asset_Siren", "MWF_FOB_Asset_Lamp"
];

{ publicVariable _x; } forEach _allVars;

diag_log "[MWF] Preset: LDF_Contact.sqf Loaded.";
