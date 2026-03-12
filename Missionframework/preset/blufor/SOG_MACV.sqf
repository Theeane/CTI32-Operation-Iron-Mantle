/*
    Author: Theeane
    Function: Blufor Preset - SOG Prairie Fire (MACV-SOG)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy active. SOG PF Base with Unsung Redux vehicle support.

    Required DLC: 
    - SOG Prairie Fire (CDLC)
    Required Mods:
    - Unsung Redux (For expanded vehicle pool)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "vn_b_wheeled_m54_repair";                      // M54 Repair Truck
CTI32_FOB_Box = "vn_b_static_m45_01"; 
CTI32_Arsenal_Box = "vn_b_ammobox_supply_05";
CTI32_Respawn_Truck = "vn_b_wheeled_m54_ammo";                    // M54 Ammo (Fixed 100 S)
CTI32_Crewman = "vn_b_m_69_01";
CTI32_Pilot = "vn_b_m_43_01";

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: MACV-SOG Recon Team
CTI32_Support_Group1 = [
    "vn_b_wheeled_m151_mg_01", 
    [
        "vn_b_is_army_07",              // Team Leader
        "vn_b_is_army_08",              // Marksman
        "vn_b_is_army_01"               // Scout
    ],
    150                                 
];

// Button 2: US Army Squad
CTI32_Support_Group2 = [
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
CTI32_Support_Group3 = [
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
CTI32_Support_Group4 = [
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
CTI32_Support_Group5 = [
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

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["vn_b_wheeled_m151_01", 15],                                  
    ["vn_b_wheeled_m151_mg_01", 40],                               
    ["vn_b_wheeled_m151_mg_03", 60],                               
    ["vn_b_wheeled_m54_02", 50]                                    
];

CTI32_Preset_APC = [
    ["vn_b_armored_m113_acav_01", 180],                            
    ["vn_b_armored_m113_acav_03", 220]                             
];

CTI32_Preset_Tanks = [
    ["vn_b_armor_m41_01_01", 400],                                 // M41 Bulldog
    ["uns_m48a3", 500],                                            // M48 Patton (Unsung Redux Support)
    ["uns_m551", 450]                                              // M551 Sheridan (Unsung Redux Support)
];

CTI32_Preset_Helis = [
    ["vn_b_air_uh1d_02_01", 200],                                  
    ["vn_b_air_ch34_01_01", 250]                                   
];

CTI32_Preset_Jets = [
    ["uns_f4e_cas", 550],                                          // F-4 Phantom (Unsung Redux)
    ["vn_b_air_f4c_cas", 580]                                       // F-4C Phantom (SOG PF)
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "vn_b_air_ah1g_01",                                            // Cobra
    "vn_b_air_uh1c_02_01"                                          // Huey Gunship
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "uns_f100_cas",                                                // F-100 Super Sabre
    "vn_b_air_f4c_cap"                                             // F-4C Phantom (Intercept)
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "vn_b_wheeled_m151_mg_04",                                     // M151 TOW
    "vn_b_armored_m125_01"                                         // M125 Mortar
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "vn_b_wheeled_m54_fuel",                                       
    "vn_b_wheeled_m54_repair"                                      
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "vn_b_wheeled_m151_02"                                         // M151 Command
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: SOG_MACV loaded successfully.";
