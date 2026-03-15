/*
    Author: Theane / ChatGPT
    Function: MWF_fn_initGlobals
    Project: Military War Framework

    Description:
    Initializes shared global state and synchronizes campaign-persistent parameter values.
    Faction preset loading is handled by MWF_fn_presetManager.
*/

if (!isServer) exitWith {};

private _startSupplies = missionNamespace getVariable [
    "MWF_Locked_StartSupplies",
    ["MWF_Param_StartSupplies", 200] call BIS_fnc_getParamValue
];

private _startCivRep = missionNamespace getVariable [
    "MWF_Locked_CivReputation",
    ["MWF_Param_CivReputation", 0] call BIS_fnc_getParamValue
];

private _supplyTimer = missionNamespace getVariable [
    "MWF_Locked_SupplyTimer",
    ["MWF_Param_SupplyTimer", 10] call BIS_fnc_getParamValue
];

private _heatMult = missionNamespace getVariable [
    "MWF_Locked_NotorietyMultiplier",
    ["MWF_Param_NotorietyMultiplier", 1] call BIS_fnc_getParamValue
];

private _maxFOBs = missionNamespace getVariable [
    "MWF_Locked_MaxFOBs",
    ["MWF_Param_MaxFOBs", 5] call BIS_fnc_getParamValue
];

private _incomeMultiplier = missionNamespace getVariable [
    "MWF_Locked_IncomeMultiplier",
    ["MWF_Param_IncomeMultiplier", 1] call BIS_fnc_getParamValue
];

private _buildingMode = missionNamespace getVariable [
    "MWF_Locked_BuildingDamageMode",
    missionNamespace getVariable ["MWF_LockedBuildingMode", ["MWF_Param_BuildingDamageMode", 0] call BIS_fnc_getParamValue]
];

if (isNil { missionNamespace getVariable "MWF_Economy_Supplies" }) then {
    missionNamespace setVariable ["MWF_Economy_Supplies", _startSupplies, true];
};

if (isNil { missionNamespace getVariable "MWF_res_intel" }) then {
    missionNamespace setVariable ["MWF_res_intel", 0, true];
};

if (isNil { missionNamespace getVariable "MWF_res_notoriety" }) then {
    missionNamespace setVariable ["MWF_res_notoriety", 0, true];
};

if (isNil { missionNamespace getVariable "MWF_CivRep" }) then {
    missionNamespace setVariable ["MWF_CivRep", _startCivRep, true];
};

if (isNil { missionNamespace getVariable "MWF_ProductionBonus" }) then {
    missionNamespace setVariable ["MWF_ProductionBonus", 0, true];
};

if (isNil { missionNamespace getVariable "MWF_LoadedZoneSaveData" }) then {
    missionNamespace setVariable ["MWF_LoadedZoneSaveData", [], true];
};

if (isNil { missionNamespace getVariable "MWF_CapturedZoneCount" }) then {
    missionNamespace setVariable ["MWF_CapturedZoneCount", 0, true];
    missionNamespace setVariable ["MWF_CapturedTownCount", 0, true];
    missionNamespace setVariable ["MWF_CapturedCapitalCount", 0, true];
    missionNamespace setVariable ["MWF_CapturedFactoryCount", 0, true];
    missionNamespace setVariable ["MWF_CapturedMilitaryCount", 0, true];
    missionNamespace setVariable ["MWF_MapControlPercent", 0, true];
};

missionNamespace setVariable ["MWF_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", _startSupplies], true];
missionNamespace setVariable ["MWF_Intel", missionNamespace getVariable ["MWF_res_intel", 0], true];
missionNamespace setVariable ["MWF_Economy_SupplyInterval", _supplyTimer, true];
missionNamespace setVariable ["MWF_Economy_HeatMult", _heatMult, true];
missionNamespace setVariable ["MWF_Param_MaxFOBs", _maxFOBs, true];
missionNamespace setVariable ["MWF_Param_IncomeMultiplier", _incomeMultiplier, true];
missionNamespace setVariable ["MWF_Locked_BuildingDamageMode", _buildingMode, true];
missionNamespace setVariable ["MWF_LockedBuildingMode", _buildingMode, true];

diag_log "[MWF] Global state initialized.";
