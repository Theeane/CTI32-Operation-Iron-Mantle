/*
    Author: Theane / ChatGPT
    Function: MWF_Economy_Settings
    Project: Military War Framework

    Description:
    Defines economy configuration values used by the framework.
*/

// --- 1. INCOME MULTIPLIER (Lobby Parameter) ---
// 0 = Low (0.5x), 1 = Medium (1.0x), 2 = High (2.0x)
private _incomeParam = ["MWF_Param_IncomeMultiplier", 1] call BIS_fnc_getParamValue;
private _incomeMult = 1.0;

switch (_incomeParam) do {
    case 0: { _incomeMult = 0.5; }; // Hardcore / Scarcity
    case 1: { _incomeMult = 1.0; }; // Default Experience (Balanced)
    case 2: { _incomeMult = 2.0; }; // High Resource Flow
};

// --- 2. STARTING CAPITAL ---
// Initial resources granted to players at mission start.
MWF_Economy_StartSupplies = 200;    // Logistics for vehicles/buildings
MWF_Economy_StartIntel    = 0;      // Intelligence for missions/recon

// --- 3. INCOME INTERVAL (Timing) ---
// Frequency of resource distribution in minutes.
// Param options: 5, 10, 15, 20, 30.
MWF_Economy_IncomeInterval = ["MWF_Param_SupplyTime", 15] call BIS_fnc_getParamValue; 

// --- 4. PASSIVE INCOME (Scaled by Multiplier) ---
// Base resources generated per income tick regardless of territory control.
MWF_Economy_PassiveIncome_Supplies = (20 * _incomeMult);  
MWF_Economy_PassiveIncome_Intel    = (2 * _incomeMult);  

// --- 5. ZONE REWARD VALUES (Scaled by Multiplier) ---
// Resources added to the income tick per controlled sector.
MWF_Economy_ZoneBonus_Small = (10 * _incomeMult);   // Radio towers, outposts
MWF_Economy_ZoneBonus_Large = (35 * _incomeMult);   // Towns, urban centers
MWF_Economy_ZoneBonus_Base  = (75 * _incomeMult);   // Military bases, airports

// --- 6. INTEL GATHERING VALUES ---
// Rewards for specific actions on the battlefield.
MWF_Economy_Intel_CapturedOfficer = 50;  
MWF_Economy_Intel_DataTerminal    = 25;  
MWF_Economy_Intel_EnemySoldier    = 1;   
MWF_Economy_Intel_CivilianTalk    = 5;   

// --- 7. INTEL SCALING LOGIC (Diminishing Returns) ---
// This function calculates the probability of finding intel/informants 
// based on current reserves. Higher intel = lower find chance.
MWF_Economy_fnc_getIntelChance = {
    params ["_currentIntel"];
    
    private _baseChance = 100; // Starting chance at 0 Intel
    private _softCap = 500;    // Amount where gathering becomes harder
    private _minChance = 5;    // Minimum floor (never 0%)
    
    private _calculatedChance = _baseChance - (_currentIntel / (_softCap / 100));
    
    if (_calculatedChance < _minChance) then { _calculatedChance = _minChance };
    
    _calculatedChance
};

// --- 8. VEHICLE PRICING (Tier-Based) ---
// Final price = BasePrice * TierMultiplier.
MWF_Economy_BasePrice_Vehicle = 150; 

MWF_Economy_TierMultipliers = createHashMapFromArray [
    ["T1", 1.0],   // Logistics / Unarmed
    ["T2", 2.0],   // Light Armed (HMG/GMG)
    ["T3", 4.5],   // IFVs / APCs
    ["T4", 8.0],   // MBTs / Heavy AA
    ["T5", 15.0]   // Strategic Assets (Jets/Attack Helis)
];

// --- 9. MOB UPGRADES ---
// Costs for expanding Mobile Operations Base capabilities.
MWF_Economy_Cost_MOB_Repair   = 100;
MWF_Economy_Cost_MOB_Rearm    = 150;
MWF_Economy_Cost_MOB_Refuel   = 100;
MWF_Economy_Cost_MOB_Garage   = 300; 

// --- 10. RESOURCE RECOVERY ---
// Percentage of Supplies returned when recycling assets.
MWF_Economy_RefundRate = 0.5;

diag_log format ["[Iron Mantle] Economy Settings Initialized. Mode: %1 (Multiplier: %2x)", _incomeParam, _incomeMult];
