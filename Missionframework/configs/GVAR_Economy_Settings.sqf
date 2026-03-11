/* Author: Theeane
    Description: 
    Main economy and resource configuration for Operation Iron Mantle.
    Focuses on Supplies and Intel. Infantry and gear are free of charge.
    
    Income multiplier is based on the 'Medium' default experience.
*/

// --- 1. INCOME MULTIPLIER (Lobby Parameter) ---
// 0 = Low (0.5x), 1 = Medium (1.0x), 2 = High (2.0x)
private _incomeParam = ["GVAR_Param_IncomeMultiplier", 1] call BIS_fnc_getParamValue;
private _incomeMult = 1.0;

switch (_incomeParam) do {
    case 0: { _incomeMult = 0.5; }; // Hardcore / Scarcity
    case 1: { _incomeMult = 1.0; }; // Default Experience (Balanced)
    case 2: { _incomeMult = 2.0; }; // High Resource Flow
};

// --- 2. STARTING CAPITAL ---
GVAR_Economy_StartSupplies = 200;    
GVAR_Economy_StartIntel    = 0;      

// --- 3. INCOME INTERVAL ---
GVAR_Economy_IncomeInterval = ["GVAR_Param_SupplyTime", 15] call BIS_fnc_getParamValue; 

// --- 4. PASSIVE INCOME (Scaled) ---
GVAR_Economy_PassiveIncome_Supplies = (20 * _incomeMult);  
GVAR_Economy_PassiveIncome_Intel    = (2 * _incomeMult);  

// --- 5. ZONE REWARD VALUES (Scaled) ---
// Values added to each income tick per controlled sector.
GVAR_Economy_ZoneBonus_Small = (10 * _incomeMult);   // Outposts
GVAR_Economy_ZoneBonus_Large = (35 * _incomeMult);   // Cities
GVAR_Economy_ZoneBonus_Base  = (75 * _incomeMult);   // Military Bases

// --- 6. INTEL GATHERING ---
// Static rewards for battlefield actions.
GVAR_Economy_Intel_CapturedOfficer = 50;  
GVAR_Economy_Intel_DataTerminal    = 25;  
GVAR_Economy_Intel_EnemySoldier    = 1;   
GVAR_Economy_Intel_CivilianTalk    = 5;   

// --- 7. VEHICLE PRICING (Tier-Based) ---
// Final price = BasePrice * TierMultiplier.
GVAR_Economy_BasePrice_Vehicle = 150; 

GVAR_Economy_TierMultipliers = createHashMapFromArray [
    ["T1", 1.0],   // Logistics / Unarmed
    ["T2", 2.0],   // Light Armed (HMG/GMG)
    ["T3", 4.5],   // IFVs / APCs
    ["T4", 8.0],   // MBTs / Heavy AA
    ["T5", 15.0]   // Strategic Assets (Jets/Attack Helis)
];

// --- 8. MOB UPGRADES ---
GVAR_Economy_Cost_MOB_Repair   = 100;
GVAR_Economy_Cost_MOB_Rearm    = 150;
GVAR_Economy_Cost_MOB_Refuel   = 100;
GVAR_Economy_Cost_MOB_Garage   = 300; 

// --- 9. RECYCLING ---
GVAR_Economy_RefundRate = 0.5;

diag_log format ["[Iron Mantle] Economy Initialized. Mode: %1 (Multiplier: %2x)", _incomeParam, _incomeMult];
