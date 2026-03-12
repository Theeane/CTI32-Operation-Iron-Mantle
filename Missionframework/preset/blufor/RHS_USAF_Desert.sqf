/*
    Author: Theeane
    Function: Blufor Preset - RHS USAF (Desert)
    Description: Master Template for CTI32 Operation Iron Mantle.
    Note: Digital economy active. Requires RHS: USAF mod.

    Required Mods:
    - RHS: USAF (http://www.rhsmods.org/)

    Rules: 
    1. All names are fetched dynamically via displayName.
    2. Mandatory Mobile Respawn Truck first in Light Vehicles for 100 S.
    3. English comments and logs only.
*/

// --- 1. CORE SUPPORT UNITS ---
CTI32_FOB_Truck = "rhsusf_M1083A1P2_B_D_repair_fmtv_usarmy";       // M1083A1 Repair (Desert)
CTI32_FOB_Box = "B_Slingload_01_Cargo_F"; 
CTI32_Arsenal_Box = "B_supplyCrate_F";
CTI32_Respawn_Truck = "rhsusf_M1083A1P2_B_D_fmtv_usarmy";          // M1083A1 Transport as Respawn (Fixed 100 S)
CTI32_Crewman = "rhsusf_army_ocp_combatcrewman";                   // Default crew
CTI32_Pilot = "rhsusf_army_ocp_helipilot";                         // Default pilot

// --- 2. LOGISTICS & ECONOMY ---
// Digital Currency System Active.

// --- 3. NPC SUPPORT GROUPS (For Support UI Buttons 1-5) ---

// Button 1: Recon & Marksman Team
CTI32_Support_Group1 = [
    "rhsusf_m1025_w_m2",                // HMMWV M2
    [
        "rhsusf_army_ocp_teamleader",   // Leader
        "rhsusf_army_ocp_marksman",     // Marksman
        "rhsusf_army_ocp_rifleman"      // Scout
    ],
    150                                 
];

// Button 2: US Army Infantry Section
CTI32_Support_Group2 = [
    "rhsusf_M1083A1P2_D_open_fmtv_usarmy", 
    [
        "rhsusf_army_ocp_squadleader", 
        "rhsusf_army_ocp_autorifleman", 
        "rhsusf_army_ocp_autorifleman", 
        "rhsusf_army_ocp_riflemanat", 
        "rhsusf_army_ocp_medic"
    ],
    250                                 
];

// Button 3: Anti-Tank Squad (Javelin)
CTI32_Support_Group3 = [
    "rhsusf_m1167_w",                   // HMMWV TOW
    [
        "rhsusf_army_ocp_squadleader", 
        "rhsusf_army_ocp_javelin",      // Javelin Specialist
        "rhsusf_army_ocp_javelin",      // Javelin Specialist
        "rhsusf_army_ocp_medic"
    ],
    300                                 
];

// Button 4: Armored Support (Bradley)
CTI32_Support_Group4 = [
    "RHS_M2A2_BUSKI_D",                 // M2A2 Bradley
    [
        "rhsusf_army_ocp_squadleader", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_marksman", 
        "rhsusf_army_ocp_engineer"
    ],
    450                                 
];

// Button 5: Air Assault (Blackhawk)
CTI32_Support_Group5 = [
    "RHS_UH60M_d",                      // UH-60M Blackhawk
    [
        "rhsusf_army_ocp_teamleader", 
        "rhsusf_army_ocp_rifleman", 
        "rhsusf_army_ocp_riflemanat", 
        "rhsusf_army_ocp_marksman"
    ],
    600                                 
];

// --- 4. VEHICLE CATEGORIES [Classname, Cost] ---

CTI32_Preset_Light = [
    [CTI32_Respawn_Truck, 100],                                    
    ["rhsusf_m1025_d", 20],                                        
    ["rhsusf_m1025_d_m2", 45],                                     
    ["rhsusf_m1025_d_Mk19", 55],                                   
    ["rhsusf_M1083A1P2_D_fmtv_usarmy", 50]                         
];

CTI32_Preset_APC = [
    ["RHS_M2A2_BUSKI_D", 200],                                     // Bradley
    ["rhsusf_stryker_m1126_m2_d", 180]                             // Stryker
];

CTI32_Preset_Tanks = [
    ["rhsusf_m1a1aimd_usarmy", 450],                               // M1A1
    ["rhsusf_m1a2sep1tuskiid_usarmy", 550]                         // M1A2 TUSK II
];

CTI32_Preset_Helis = [
    ["RHS_UH60M_d", 220],                                          
    ["rhsusf_CH47F_10", 300]                                       
];

CTI32_Preset_Jets = [
    ["RHS_A10", 550]                                               // A-10 Thunderbolt II
];

// --- 5. MISSION UNLOCKS ---

// Grand Op 1: Helicopters
CTI32_Unlock_GrandOp1_Helis = [
    "RHS_AH64D_wd",                                                // Apache (Wd skin as D is often missing/separate)
    "RHS_AH6E_wd"                                                  // Little Bird
];

// Grand Op 2: Fixed Wing
CTI32_Unlock_GrandOp2_Jets = [
    "rhsusf_f22"                                                   // F-22 Raptor
];

// Side Op: Disrupt (Infrastructure/Roadblocks)
CTI32_Unlock_Disrupt = [
    "rhsusf_rg33_m2_d",                                            
    "rhsusf_m113d_usarmy"                                          
];

// Side Op: Supply (Logistics/FOB)
CTI32_Unlock_Supply = [
    CTI32_FOB_Truck,                                               
    "rhsusf_M1083A1P2_B_D_fuel_fmtv_usarmy",                      
    "rhsusf_M1083A1P2_B_D_repair_fmtv_usarmy"                     
];

// Side Op: Intel (Information/Command)
CTI32_Unlock_Intel = [
    "rhsusf_m1152_rsv_usarmy_d"                                     // RSV HMMWV
];

// --- 6. SYNC & BROADCAST ---
{ publicVariable _x; } forEach [
    "CTI32_FOB_Truck", "CTI32_FOB_Box", "CTI32_Arsenal_Box", "CTI32_Respawn_Truck", "CTI32_Crewman", "CTI32_Pilot",
    "CTI32_Support_Group1", "CTI32_Support_Group2", "CTI32_Support_Group3", "CTI32_Support_Group4", "CTI32_Support_Group5",
    "CTI32_Preset_Light", "CTI32_Preset_APC", "CTI32_Preset_Tanks", "CTI32_Preset_Helis", "CTI32_Preset_Jets",
    "CTI32_Unlock_GrandOp1_Helis", "CTI32_Unlock_GrandOp2_Jets", "CTI32_Unlock_Disrupt", "CTI32_Unlock_Supply", "CTI32_Unlock_Intel"
];

diag_log "[CTI32] Preset: RHS_USAF_Desert loaded successfully.";
