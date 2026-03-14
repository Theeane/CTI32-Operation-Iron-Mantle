/*
    Author: Theane / ChatGPT
    Function: MWF_Economy_Settings
    Project: Military War Framework

    Description:
    Defines economy configuration values used by the framework.
    Campaign-persistent lobby params are read from the locked missionNamespace values.
*/

// --- 1. INCOME MULTIPLIER (Campaign-persistent) ---
// 0 = Low (0.5x), 1 = Medium (1.0x), 2 = High (2.0x)
private _incomeParam = missionNamespace getVariable ["MWF_Locked_IncomeMultiplier", ["MWF_Param_IncomeMultiplier", 1] call BIS_fnc_getParamValue];
private _incomeMult = 1.0;

switch (_incomeParam) do {
    case 0: { _incomeMult = 0.5; };
    case 1: { _incomeMult = 1.0; };
    case 2: { _incomeMult = 2.0; };
};

// --- 2. STARTING CAPITAL (Campaign-persistent) ---
MWF_Economy_StartSupplies = missionNamespace getVariable ["MWF_Locked_StartSupplies", 200];
MWF_Economy_StartIntel    = 0;

// --- 3. INCOME INTERVAL (Campaign-persistent) ---
MWF_Economy_IncomeInterval = missionNamespace getVariable ["MWF_Locked_SupplyTimer", ["MWF_Param_SupplyTimer", 10] call BIS_fnc_getParamValue];

// --- 4. PASSIVE INCOME (Scaled by Multiplier) ---
MWF_Economy_PassiveIncome_Supplies = (20 * _incomeMult);
MWF_Economy_PassiveIncome_Intel    = (2 * _incomeMult);

// --- 5. ZONE REWARD VALUES (Scaled by Multiplier) ---
MWF_Economy_ZoneBonus_Small = (10 * _incomeMult);
MWF_Economy_ZoneBonus_Large = (35 * _incomeMult);
MWF_Economy_ZoneBonus_Base  = (75 * _incomeMult);

// --- 6. INTEL GATHERING VALUES ---
MWF_Economy_Intel_CapturedOfficer = 50;
MWF_Economy_Intel_DataTerminal    = 25;
MWF_Economy_Intel_EnemySoldier    = 1;
MWF_Economy_Intel_CivilianTalk    = 5;

// --- 7. INTEL SCALING LOGIC (Diminishing Returns) ---
MWF_Economy_fnc_getIntelChance = {
    params ["_currentIntel"];

    private _baseChance = 100;
    private _softCap = 500;
    private _minChance = 5;

    private _calculatedChance = _baseChance - (_currentIntel / (_softCap / 100));

    if (_calculatedChance < _minChance) then { _calculatedChance = _minChance };

    _calculatedChance
};

// --- 8. VEHICLE PRICING (Tier-Based) ---
MWF_Economy_BasePrice_Vehicle = 150;

MWF_Economy_TierMultipliers = createHashMapFromArray [
    ["T1", 1.0],
    ["T2", 2.0],
    ["T3", 4.5],
    ["T4", 8.0],
    ["T5", 15.0]
];

// --- 9. MOB UPGRADES ---
MWF_Economy_Cost_MOB_Repair   = 100;
MWF_Economy_Cost_MOB_Rearm    = 150;
MWF_Economy_Cost_MOB_Refuel   = 100;
MWF_Economy_Cost_MOB_Garage   = 300;

// --- 10. RESOURCE RECOVERY ---
MWF_Economy_RefundRate = 0.5;

diag_log format ["[Iron Mantle] Economy Settings Initialized. Mode: %1 (Multiplier: %2x)", _incomeParam, _incomeMult];
