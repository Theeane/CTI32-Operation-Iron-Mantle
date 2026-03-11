/* PRESET: RHS USAF (Desert)
    Author: Theane using Gemini
*/

// --- Tier 1: Basic Logistics ---
GVAR_BLUFOR_T1 = [
    ["rhsusf_m1025_d", 150, 0],                  // Humvee (Unarmed)
    ["rhsusf_M1078A1P2_B_D_fmtv_usarmy", 300, 0], // FMTV Transport
    ["rhsusf_M1083A1P2_B_D_fmtv_usarmy", 400, 0]  // MTV Transport
];

// --- Tier 2: Motorized & MRAP ---
GVAR_BLUFOR_T2 = [
    ["rhsusf_m1025_d_m2", 500, 0],               // Humvee (M2)
    ["rhsusf_m1151_m2cws_usarmy_d", 650, 0],      // M1151 (CWS)
    ["rhsusf_m1240a1_m2_usmc_d", 850, 0],         // M-ATV (HMG)
    ["rhsusf_m1230a1_usarmy_d", 1000, 0]          // MaxxPro
];

// --- Tier 3: IFVs & Medium Armor ---
GVAR_BLUFOR_T3 = [
    ["RHS_M2A2_BUSKI_EK_Desert", 2200, 0],        // Bradley
    ["rhsusf_m113d_usarmy", 1500, 0],             // M113A3
    ["rhsusf_stryker_m1126_m2_d", 1800, 0]        // Stryker
];

// --- Tier 4: Heavy Armor ---
GVAR_BLUFOR_T4 = [
    ["rhs_m1a1aim_tuski_d", 4500, 0],             // M1A1 Abrams
    ["rhs_m1a2sep1tuski_d", 5500, 0],             // M1A2 Abrams TUSK
    ["RHS_M6_wd", 3800, 0]                        // Linebacker (AA)
];

// --- Tier 5: Air Support ---
GVAR_BLUFOR_T5_Heli = [
    ["RHS_UH60M_d", 2500, 1],                     // Blackhawk
    ["RHS_AH64D_wd", 6500, 1]                     // Apache
];
GVAR_BLUFOR_T5_Plane = [
    ["RHS_A10", 7000, 2],                         // A-10 Thunderbolt II
    ["rhsusf_f22", 9000, 2]                       // F-22 Raptor
];
