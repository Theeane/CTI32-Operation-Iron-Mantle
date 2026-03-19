/*
    Author: Theane / ChatGPT
    Function: MWF_fn_initGlobals
    Project: Military War Framework

    Description:
    Initializes shared global state and synchronizes campaign-persistent parameter values.
    Faction preset loading is handled by MWF_fn_presetManager.

    Campaign phase model:
    - TUTORIAL   : FOB deployment gate
    - SUPPLY_RUN : initial logistics gate
    - OPEN_WAR   : sandbox campaign state, tutorial bypassed globally
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

private _sideMissionTemplateLimit = missionNamespace getVariable [
    "MWF_Locked_SideMissionTemplateLimit",
    ["MWF_Param_SideMissionTemplateLimit", 24] call BIS_fnc_getParamValue
];

private _initialFOBType = missionNamespace getVariable [
    "MWF_Locked_InitialFOBType",
    ["MWF_Param_InitialFOBType", 0] call BIS_fnc_getParamValue
];

private _incomeMultiplier = missionNamespace getVariable [
    "MWF_Locked_IncomeMultiplier",
    ["MWF_Param_IncomeMultiplier", 1] call BIS_fnc_getParamValue
];

private _compositionTypeChoice = missionNamespace getVariable [
    "MWF_Locked_CompositionTypeChoice",
    ["MWF_Param_CompositionType", 0] call BIS_fnc_getParamValue
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

if (isNil { missionNamespace getVariable "MWF_CivilianCasualties" }) then {
    missionNamespace setVariable ["MWF_CivilianCasualties", 0, true];
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

if (isNil { missionNamespace getVariable "MWF_Campaign_Phase" }) then {
    missionNamespace setVariable ["MWF_Campaign_Phase", "TUTORIAL", true];
};

if (isNil { missionNamespace getVariable "MWF_Tutorial_SupplyRunDone" }) then {
    missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", false, true];
};

/* Civilian reputation escalation / rebel leader defaults */
missionNamespace setVariable [
    "MWF_CivRep_Penalty_CivilianDeath",
    missionNamespace getVariable ["MWF_CivRep_Penalty_CivilianDeath", 2],
    true
];
missionNamespace setVariable [
    "MWF_CivRep_Threshold_Rebel",
    missionNamespace getVariable ["MWF_CivRep_Threshold_Rebel", -30],
    true
];
missionNamespace setVariable [
    "MWF_RebelLeaderCost_Base",
    missionNamespace getVariable ["MWF_RebelLeaderCost_Base", 30],
    true
];
missionNamespace setVariable [
    "MWF_RebelLeaderCost_Max",
    missionNamespace getVariable ["MWF_RebelLeaderCost_Max", 1000],
    true
];
missionNamespace setVariable [
    "MWF_FOBRepairCostPercent",
    missionNamespace getVariable ["MWF_FOBRepairCostPercent", 0.20],
    true
];
missionNamespace setVariable [
    "MWF_RebelLeaderAttackDuration",
    missionNamespace getVariable ["MWF_RebelLeaderAttackDuration", 900],
    true
];
missionNamespace setVariable [
    "MWF_FOBDespawnGraceSeconds",
    missionNamespace getVariable ["MWF_FOBDespawnGraceSeconds", 900],
    true
];

if (isNil { missionNamespace getVariable "MWF_RebelLeaderSettlementCount" }) then {
    missionNamespace setVariable ["MWF_RebelLeaderSettlementCount", 0, true];
};
if (isNil { missionNamespace getVariable "MWF_RebelLeaderEventActive" }) then {
    missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];
};
if (isNil { missionNamespace getVariable "MWF_ActiveRebelLeader" }) then {
    missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
};
if (isNil { missionNamespace getVariable "MWF_RebelLeaderContext" }) then {
    missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];
};
if (isNil { missionNamespace getVariable "MWF_FOBAttackState" }) then {
    missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];
};
if (isNil { missionNamespace getVariable "MWF_DamagedFOBs" }) then {
    missionNamespace setVariable ["MWF_DamagedFOBs", [], true];
};
if (isNil { missionNamespace getVariable "MWF_isUnderAttack" }) then {
    missionNamespace setVariable ["MWF_isUnderAttack", false, true];
};

if (isNil { missionNamespace getVariable "MWF_PendingRebelLeaderContext" }) then {
    missionNamespace setVariable ["MWF_PendingRebelLeaderContext", [], true];
};
if (isNil { missionNamespace getVariable "MWF_PendingFOBAttackState" }) then {
    missionNamespace setVariable ["MWF_PendingFOBAttackState", [], true];
};
if (isNil { missionNamespace getVariable "MWF_PendingDamagedFOBs" }) then {
    missionNamespace setVariable ["MWF_PendingDamagedFOBs", [], true];
};

private _resolvedSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", _startSupplies];
private _resolvedIntel = missionNamespace getVariable ["MWF_res_intel", 0];

missionNamespace setVariable ["MWF_Supplies", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Intel", _resolvedIntel, true];
missionNamespace setVariable ["MWF_Supply", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Currency", _resolvedSupplies + _resolvedIntel, true];
missionNamespace setVariable ["MWF_Economy_SupplyInterval", _supplyTimer, true];
missionNamespace setVariable ["MWF_Economy_HeatMult", _heatMult, true];
missionNamespace setVariable ["MWF_Param_MaxFOBs", _maxFOBs, true];
missionNamespace setVariable ["MWF_Param_SideMissionTemplateLimit", (_sideMissionTemplateLimit max 9) min 99, true];
missionNamespace setVariable ["MWF_Param_InitialFOBType", _initialFOBType, true];
missionNamespace setVariable ["MWF_Param_IncomeMultiplier", _incomeMultiplier, true];
missionNamespace setVariable ["MWF_Locked_BuildingDamageMode", _buildingMode, true];
missionNamespace setVariable ["MWF_LockedBuildingMode", _buildingMode, true];

if ((missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isEqualTo "OPEN_WAR") then {
    missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
    missionNamespace setVariable ["MWF_current_stage", 3, true];
};

diag_log format [
    "[MWF] Global state initialized. Campaign phase: %1 | Rebel threshold: %2 | Civilian penalty: -%3",
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    missionNamespace getVariable ["MWF_CivRep_Threshold_Rebel", -30],
    missionNamespace getVariable ["MWF_CivRep_Penalty_CivilianDeath", 2]
];
