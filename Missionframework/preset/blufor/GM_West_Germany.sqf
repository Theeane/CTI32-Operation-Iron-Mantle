/*
    Author: Theane / ChatGPT
    Function: Preset - GM_West_Germany
    Project: Military War Framework

    Description:
    Defines the blufor preset configuration for GM West Germany.
*/

// --- 1. CORE SUPPORT UNITS ---
MWF_FOB_Truck = "gm_ge_army_u1300l_repair";                      // Unimog Repair
MWF_FOB_Box = "B_Slingload_01_Cargo_F"; 
MWF_Arsenal_Box = "B_supplyCrate_F";
MWF_Respawn_Truck = "gm_ge_army_kat1_451_reargo";                // KAT1 5t Reammo (Fixed 100 S)
MWF_Crewman = "gm_ge_army_conscript_80_oli";                     // Default crew
MWF_Pilot = "gm_ge_army_pilot_p1_80_oli";                        // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon Team
MWF_Support_Group1 = [
    "gm_ge_army_iltis_m2",              // Iltis (M2)
    [
        "gm_ge_army_conscript_80_sl",   // Leader
        "gm_ge_army_conscript_80_ls",   // Marksman/Scout
        "gm_ge_army_conscript_80_rif"   // Rifleman
    ],
    150                                 
];

// Button 2: Infantry Section
MWF_Support_Group2 = [
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
MWF_Support_Group3 = [
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
MWF_Support_Group4 = [
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
MWF_Support_Group5 = [
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

MWF_Preset_Light = [
    [MWF_Respawn_Truck, 100],                                    
    ["gm_ge_army_iltis_cargo", 15],                                
    ["gm_ge_army_iltis_m2", 40],                                   
    ["gm_ge_army_iltis_milan", 60],                                
    ["gm_ge_army_u1300l_cargo", 50]                                
];

MWF_Preset_APC = [
    ["gm_ge_army_m113a1g_apc", 160],                               // M113
    ["gm_ge_army_marder1a1a_oli", 220]                             // Marder IFV
];

MWF_Preset_Tanks = [
    ["gm_ge_army_leap1a5", 480]                                    // Leopard 1A5
];

MWF_Preset_Helis = [
    ["gm_ge_army_bo105m_vbh", 180],                                // Bo 105
    ["gm_ge_army_ch53g", 280]                                      // CH-53G
];

MWF_Preset_Jets = [
    // GM lacks fixed-wing in core, using vanilla/placeholder if needed
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
MWF_Unlock_GrandOp1_Helis = [
    "gm_ge_army_bo105p_pah1a1",                                    // Bo 105 (Anti-Tank)
    "gm_ge_army_bo105p_pah1"                                       // Bo 105 (Armed)
];

// Grand Op 2: Fixed Wing
MWF_Unlock_GrandOp2_Jets = [
    // Placeholder for community/mod additions
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
MWF_Unlock_Disrupt = [
    "gm_ge_army_luchsa1",                                          // Luchs A1 Recon
    "gm_ge_army_luchsa2"                                           // Luchs A2 Recon
];

// Side Op: Supply (Logistics/FOB)
MWF_Unlock_Supply = [
    MWF_FOB_Truck,                                               
    "gm_ge_army_kat1_451_refuel",                                  // KAT1 Fuel
    "gm_ge_army_u1300l_repair"                                     // Unimog Repair
];

// Side Op: Intel (Information/Command)
MWF_Unlock_Intel = [
    "gm_ge_army_m113a1g_command"                                   // M113 Command
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "MWF_FOB_Truck", "MWF_FOB_Box", "MWF_Arsenal_Box", "MWF_Respawn_Truck", "MWF_Crewman", "MWF_Pilot",
    "MWF_Support_Group1", "MWF_Support_Group2", "MWF_Support_Group3", "MWF_Support_Group4", "MWF_Support_Group5",
    "MWF_Preset_Light", "MWF_Preset_APC", "MWF_Preset_Tanks", "MWF_Preset_Helis", "MWF_Preset_Jets",
    "MWF_Unlock_GrandOp1_Helis", "MWF_Unlock_GrandOp2_Jets", "MWF_Unlock_Disrupt", "MWF_Unlock_Supply", "MWF_Unlock_Intel"
];

diag_log "[CTI32] Preset: GM_West_Germany loaded successfully.";
