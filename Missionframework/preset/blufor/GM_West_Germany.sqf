/*
    Author: Theeane
    Function: Blufor Preset - Global Mobilization (West Germany)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy (Supply/Intel). Cold War era assets.

    Required DLC: 
    - Global Mobilization (Creator DLC)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
    3. English comments and logs only.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "gm_ge_army_u1300l_repair";                      // Unimog Repair
CTI32_FOB_Box = "B_Slingload_01_Cargo_F"; 
CTI32_Arsenal_Box = "B_supplyCrate_F";
CTI32_Respawn_Truck = "gm_ge_army_kat1_451_reargo";                // KAT1 5t Reammo (Fixed 100 S)
CTI32_Crewman = "gm_ge_army_conscript_80_oli";                     // Default crew
CTI32_Pilot = "gm_ge_army_pilot_p1_80_oli";                        // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
CTI32_Support_Group1 = [
    "gm_ge_army_iltis_m2",              // Iltis (M2)
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_ls",   // Marksman/Scout
        "gm_ge_army_conscript_80_rif"   // Rifleman
    ],
    150                                 
];

// Button 2: Infantry Section
CTI32_Support_Group2 = [
    "gm_ge_army_kat1_451_container",    // KAT1 Transport
    [
        "gm_ge_army_conscript_80_sl",   // Squad Leader
        "gm_ge_army_conscript_80_mg3",  // Auto Rifleman
        "gm_ge_army_conscript_80_mg3",  // Auto Rifleman
        "gm_ge_army_conscript_80_at_pzf3", // AT Specialist
        "gm_ge_army_conscript_80_med"   // Medic
    ],
    250                                 
];

// Button 3: Anti-Tank Squad
CTI32_Support_Group3 = [
    "gm_ge_army_iltis_milan",           // Iltis (Milan ATGM)
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_at_pzf3", // AT
        "gm_ge_army_conscript_80_at_pzf3", // AT
        "gm_ge_army_conscript_80_med"   // Medic
    ],
    300                                 
];

// Button 4: Armored Support
CTI32_Support_Group4 = [
    "gm_ge_army_marder1a1a_oli",        // Marder 1A1
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_rif",  // Rifleman
        "gm_ge_army_conscript_80_ls",   // Marksman
        "gm_ge_army_conscript_80_rif"   // Engineer (Rifleman placeholder)
    ],
    450                                 
];

// Button 5: Air Assault
CTI32_Support_Group5 = [
    "gm_ge_army_ch53g",                 // CH-53G Transport
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_rif",  // Rifleman
        "gm_ge_army_conscript_80_at_pzf3", // AT
        "gm_ge_army_conscript_80_mg3"   // MG
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["gm_ge_army_iltis_cargo", 15],                                
    ["gm_ge_army_iltis_m2", 40],                                   
    ["gm_ge_army_iltis_milan", 60],                                
    ["gm_ge_army_u1300l_cargo", 50]                                
];

CTI32_Preset_APC = [
    ["gm_ge_army_m113a1g_apc", 160],                               // M113
    ["gm_ge_army_marder1a1a_oli", 220]                             // Marder IFV
];

CTI32_Preset_Tanks = [
    ["gm_ge_army_leap1a5", 480]                                    // Leopard 1A5
];

CTI32_Preset_Helis = [
    ["gm_ge_army_bo105m_vbh", 180],                                // Bo 105
    ["gm_ge_army_ch53g", 280]                                      // CH-53G
];

CTI32_Preset_Jets = [
    // GM lacks fixed-wing in core, using vanilla/placeholder if needed
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "gm_ge_army_bo105p_pah1a1",                                    // Bo 105 (Anti-Tank)
    "gm_ge_army_bo105p_pah1"                                       // Bo 105 (Armed)
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    // Placeholder for community/mod additions
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "gm_ge_army_luchsa1",                                          // Luchs A1 Recon
    "gm_ge_army_luchsa2"                                           // Luchs A2 Recon
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "gm_ge_army_kat1_451_refuel",                                  // KAT1 Fuel
    "gm_ge_army_u1300l_repair"                                     // Unimog Repair
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "gm_ge_army_m113a1g_command"                                   // M113 Command
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: GM_West_Germany loaded successfully.";
