/* Author: Theeane
    Description: 
    Economy settings for Operation Iron Mantle.
    Handles income, starting capital, and Tier-based pricing.
    
    Note: All values are subject to balancing during development.
*/

// --- 1. STARTING CAPITAL ---
// Resources available to BLUFOR at mission start.
GVAR_Economy_StartCredits  = 500;    // Personal funds (weapons, recruitment)
GVAR_Economy_StartSupplies = 200;    // Global resources (vehicles, base building)

// --- 2. SUPPLY LOGIC (Timing) ---
// Fetched from mission parameters (Lobby). Default is 15 minutes.
// Available options: 5, 10, 15, 20, 30 minutes.
GVAR_Economy_IncomeInterval = ["GVAR_Param_SupplyTime", 15] call BIS_fnc_getParamValue; 

// --- 3. PASSIVE INCOME ---
// Resources generated per income tick regardless of controlled zones.
GVAR_Economy_PassiveIncome_Credits  = 50;  
GVAR_Economy_PassiveIncome_Supplies = 20;  

// --- 4. ZONE BONUSES ---
// Resource production added per income tick based on controlled locations.
GVAR_Economy_ZoneBonus_Small = 10;   // Small villages, radio towers
GVAR_Economy_ZoneBonus_Large = 35;   // Large towns, cities
GVAR_Economy_ZoneBonus_Base  = 75;   // Military bases, airfields

// --- 5. TIER PRICING (Multipliers) ---
// Base prices for unit types. Final price = BasePrice * TierMultiplier.
GVAR_Economy_BasePrice_Infantry = 20;  
GVAR_Economy_BasePrice_Vehicle  = 150; 

GVAR_Economy_TierMultipliers = createHashMapFromArray [
    ["T1", 1.0],   // Standard pricing
    ["T2", 1.5],   // Enhanced equipment
    ["T3", 3.0],   // High quality assets
    ["T4", 6.0],   // Heavy/Elite assets
    ["T5", 12.0]   // End-game (MBTs/Planes)
];

// --- 6. REFUND SYSTEM ---
// Percentage of resources returned when a vehicle is recycled at a friendly base.
GVAR_Economy_RefundRate = 0.5; // 50% return

diag_log "[Iron Mantle] Economy Settings Initialized.";
