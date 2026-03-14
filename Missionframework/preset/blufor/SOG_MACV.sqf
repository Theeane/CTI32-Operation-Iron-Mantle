/*
    Author: Theane / ChatGPT
    Function: Preset - SOG_MACV
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for SOG MACV.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "vn_b_wheeled_m54_repair";                      // M54 Repair Truck
MWF_FOB_Box = "vn_b_static_m45_01"; 
MWF_Arsenal_Box = "vn_b_ammobox_supply_05";
MWF_Respawn_Truck = "vn_b_wheeled_m54_ammo";                    // M54 Ammo (Fixed 100 S)
MWF_Crewman = "vn_b_m_69_01";
MWF_Pilot = "vn_b_m_43_01";

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: MACV-SOG Recon Team
MWF_Support_Group1 = [
    "vn_b_wheeled_m151_mg_01", 
    [
        "vn_b_is_army_07",              // Team Leader
        "vn_b_is_army_08",              // Marksman
        "vn_b_is_army_01"               // Scout
    ],
    150                                 
];

// Button 2: US Army Squad
MWF_Support_Group2 = [
    "vn_b_wheeled_m54_01", 
    [
        "vn_b_is_army_07", 
        "vn_b_is_army_06", 
        "vn_b_is_army_02", 
        "vn_b_is_army_01", 
        "vn_b_is_army_09"
    ],
    250                                 
];

// Button 3: AT / Recoilless Support
MWF_Support_Group3 = [
    "vn_b_wheeled_m151_mg_03",          // M151 M40
    [
        "vn_b_is_army_07", 
        "vn_b_is_army_05",              // AT Specialist
        "vn_b_is_army_05", 
        "vn_b_is_army_09"
    ],
    300                                 
];

// Button 4: Cavalry Support (M113 ACAV)
MWF_Support_Group4 = [
    "vn_b_armored_m113_acav_01", 
    [
        "vn_b_is_army_07", 
        "vn_b_is_army_01", 
        "vn_b_is_army_08", 
        "vn_b_is_army_12"
    ],
    450                                 
];

// Button 5: Air Assault (Huey)
MWF_Support_Group5 = [
    "vn_b_air_uh1d_02_01", 
    [
        "vn_b_is_army_07", 
        "vn_b_is_army_01", 
        "vn_b_is_army_02", 
        "vn_b_is_army_08"
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    
    ["vn_b_wheeled_m151_01", 15],                                  
    ["vn_b_wheeled_m151_mg_01", 40],                               
    ["vn_b_wheeled_m151_mg_03", 60],                               
    ["vn_b_wheeled_m54_02", 50]                                    
];

MWF_Preset_APC = [
    ["vn_b_armored_m113_acav_01", 180],                            
    ["vn_b_armored_m113_acav_03", 220]                             
];

MWF_Preset_Tanks = [
    ["vn_b_armor_m41_01_01", 400],                                 // M41 Bulldog
    ["uns_m48a3", 500],                                            // M48 Patton (Unsung Redux Support)
    ["uns_m551", 450]                                              // M551 Sheridan (Unsung Redux Support)
];

MWF_Preset_Helis = [
    ["vn_b_air_uh1d_02_01", 200],                                  
    ["vn_b_air_ch34_01_01", 250]                                   
];

MWF_Preset_Jets = [
    ["uns_f4e_cas", 550],                                          // F-4 Phantom (Unsung Redux)
    ["vn_b_air_f4c_cas", 580]                                       // F-4C Phantom (SOG PF)
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "vn_b_air_ah1g_01",                                            // Cobra
    "vn_b_air_uh1c_02_01"                                          // Huey Gunship
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    "uns_f100_cas",                                                // F-100 Super Sabre
    "vn_b_air_f4c_cap"                                             // F-4C Phantom (Intercept)
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "vn_b_wheeled_m151_mg_04",                                     // M151 TOW
    "vn_b_armored_m125_01"                                         // M125 Mortar
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               
    "vn_b_wheeled_m54_fuel",                                       
    "vn_b_wheeled_m54_repair"                                      
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "vn_b_wheeled_m151_02"                                         // M151 Command
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: SOG_MACV loaded successfully.";
