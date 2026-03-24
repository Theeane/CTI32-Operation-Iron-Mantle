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

private _threatGainMultiplier = missionNamespace getVariable [
    "MWF_Locked_ThreatGainMultiplier",
    ["MWF_Param_ThreatGainMultiplier", 1] call BIS_fnc_getParamValue
];

private _threatDecayMultiplier = missionNamespace getVariable [
    "MWF_Locked_ThreatDecayMultiplier",
    ["MWF_Param_ThreatDecayMultiplier", 1] call BIS_fnc_getParamValue
];

private _worldTierMultiplier = missionNamespace getVariable [
    "MWF_Locked_WorldTierMultiplier",
    ["MWF_Param_WorldTierMultiplier", 1] call BIS_fnc_getParamValue
];

private _endgameMapControlRequired = missionNamespace getVariable [
    "MWF_Locked_EndgameMapControlRequired",
    ["MWF_Param_EndgameMapControl", 75] call BIS_fnc_getParamValue
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

missionNamespace setVariable ["MWF_Feature_LandEnabled", missionNamespace getVariable ["MWF_Feature_LandEnabled", true], true];
missionNamespace setVariable ["MWF_Feature_NavalEnabled", missionNamespace getVariable ["MWF_Feature_NavalEnabled", false], true];
missionNamespace setVariable ["MWF_Feature_AirEnabled", missionNamespace getVariable ["MWF_Feature_AirEnabled", false], true];

if (isNil { missionNamespace getVariable "MWF_FreeMainOpCharges" }) then {
    missionNamespace setVariable ["MWF_FreeMainOpCharges", 0, true];
};
if (isNil { missionNamespace getVariable "MWF_RevealedInfrastructureIDs" }) then {
    missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", [], true];
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
    missionNamespace getVariable ["MWF_CivRep_Threshold_Rebel", -25],
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
    "MWF_RebelLeaderRespawnDelay",
    missionNamespace getVariable ["MWF_RebelLeaderRespawnDelay", 900],
    true
];
missionNamespace setVariable [
    "MWF_FOBDespawnGraceSeconds",
    missionNamespace getVariable ["MWF_FOBDespawnGraceSeconds", 900],
    true
];
missionNamespace setVariable [
    "MWF_CivRep_PositiveSupportThreshold",
    missionNamespace getVariable ["MWF_CivRep_PositiveSupportThreshold", 25],
    true
];
missionNamespace setVariable [
    "MWF_CivRep_NegativeSupportThreshold",
    missionNamespace getVariable ["MWF_CivRep_NegativeSupportThreshold", -25],
    true
];
missionNamespace setVariable [
    "MWF_CivRep_InformantCooldown",
    missionNamespace getVariable ["MWF_CivRep_InformantCooldown", 1800],
    true
];
if (isNil { missionNamespace getVariable "MWF_CivRep_InformantNextAllowed" }) then {
    missionNamespace setVariable ["MWF_CivRep_InformantNextAllowed", 0, true];
};
if (isNil { missionNamespace getVariable "MWF_CivRepSupportCooldowns" }) then {
    missionNamespace setVariable ["MWF_CivRepSupportCooldowns", createHashMap, true];
};
if (isNil { missionNamespace getVariable "MWF_ActiveInformant" }) then {
    missionNamespace setVariable ["MWF_ActiveInformant", objNull, true];
};
if (isNil { missionNamespace getVariable "MWF_ActiveInformantGroup" }) then {
    missionNamespace setVariable ["MWF_ActiveInformantGroup", grpNull, true];
};
if (isNil { missionNamespace getVariable "MWF_ActiveInformantZoneName" }) then {
    missionNamespace setVariable ["MWF_ActiveInformantZoneName", "", true];
};
if (isNil { missionNamespace getVariable "MWF_LegacyZoneInformantsEnabled" }) then {
    missionNamespace setVariable ["MWF_LegacyZoneInformantsEnabled", false, true];
};
if (isNil { missionNamespace getVariable "MWF_CompletedMainOperations" }) then {
    missionNamespace setVariable ["MWF_CompletedMainOperations", [], true];
};
missionNamespace setVariable ["MWF_EndgameMapControlRequired", _endgameMapControlRequired, true];
missionNamespace setVariable ["MWF_EndgameRequiredDestroyedHQs", missionNamespace getVariable ["MWF_EndgameRequiredDestroyedHQs", 1], true];
missionNamespace setVariable ["MWF_EndgameRequiredDestroyedRoadblocks", missionNamespace getVariable ["MWF_EndgameRequiredDestroyedRoadblocks", 1], true];
missionNamespace setVariable ["MWF_EndgameRequiredCompletedMainOps", missionNamespace getVariable ["MWF_EndgameRequiredCompletedMainOps", 1], true];
missionNamespace setVariable ["MWF_EndgameMusicClass", missionNamespace getVariable ["MWF_EndgameMusicClass", ""], true];
missionNamespace setVariable ["MWF_DeployMusicClass", missionNamespace getVariable ["MWF_DeployMusicClass", ""], true];
missionNamespace setVariable ["MWF_EndgameLeader_RedBeret", missionNamespace getVariable ["MWF_EndgameLeader_RedBeret", "H_Beret_Colonel"], true];
missionNamespace setVariable ["MWF_EndgameLeader_VanillaFaces", missionNamespace getVariable ["MWF_EndgameLeader_VanillaFaces", ["WhiteHead_01", "WhiteHead_02", "WhiteHead_15"]], true];
missionNamespace setVariable ["MWF_EndgameLeader_ASCZFaces", missionNamespace getVariable ["MWF_EndgameLeader_ASCZFaces", ["asczHead_price_A3", "asczHead_beardy_A3", "asczHead_mctavish_A3"]], true];
missionNamespace setVariable ["MWF_EndgameLeader_Beards", missionNamespace getVariable ["MWF_EndgameLeader_Beards", ["SFG_Tac_BeardD", "SFG_Tac_BeardO", "SFG_Tac_chinlessbO"]], true];
if (isNil { missionNamespace getVariable "MWF_EndgameActive" }) then {
    missionNamespace setVariable ["MWF_EndgameActive", false, true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameCompleted" }) then {
    missionNamespace setVariable ["MWF_EndgameCompleted", false, true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameOutcome" }) then {
    missionNamespace setVariable ["MWF_EndgameOutcome", "", true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameLeader" }) then {
    missionNamespace setVariable ["MWF_EndgameLeader", objNull, true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameLeaderGroup" }) then {
    missionNamespace setVariable ["MWF_EndgameLeaderGroup", grpNull, true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameRebelContact" }) then {
    missionNamespace setVariable ["MWF_EndgameRebelContact", objNull, true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameReservedZoneId" }) then {
    missionNamespace setVariable ["MWF_EndgameReservedZoneId", "", true];
};
if (isNil { missionNamespace getVariable "MWF_EndgameState" }) then {
    missionNamespace setVariable ["MWF_EndgameState", [], true];
};

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
if (isNil { missionNamespace getVariable "MWF_RebelLeaderRespawnState" }) then {
    missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
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
if (isNil { missionNamespace getVariable "MWF_PendingRebelLeaderRespawnState" }) then {
    missionNamespace setVariable ["MWF_PendingRebelLeaderRespawnState", [], true];
};
if (isNil { missionNamespace getVariable "MWF_PendingDamagedFOBs" }) then {
    missionNamespace setVariable ["MWF_PendingDamagedFOBs", [], true];
};

private _sessionSpawnDistance = ["MWF_Param_SpawnDistance", 1200] call BIS_fnc_getParamValue;
private _sessionScalingBracket = ["MWF_Param_PlayerScalingBracket", 1] call BIS_fnc_getParamValue;
private _sessionUnitCap = ["MWF_Param_UnitCap", 100] call BIS_fnc_getParamValue;
private _sessionDebugMode = (["MWF_Param_DebugMode", 0] call BIS_fnc_getParamValue) > 0;
private _scalingLabel = switch (_sessionScalingBracket) do {
    case 0: {"1-8 Players (Small Group)"};
    case 2: {"17-24 Players (Large Group)"};
    case 3: {"25-32 Players (Full Scale)"};
    default {"9-16 Players (Medium Group)"};
};

private _resolvedSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", _startSupplies];
private _resolvedIntel = missionNamespace getVariable ["MWF_res_intel", 0];

if (_sessionDebugMode) then {
    _resolvedSupplies = 9999;
    _resolvedIntel = 9999;
};

missionNamespace setVariable ["MWF_Supplies", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Intel", _resolvedIntel, true];
missionNamespace setVariable ["MWF_Supply", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Currency", _resolvedSupplies + _resolvedIntel, true];
missionNamespace setVariable ["MWF_Economy_SupplyInterval", _supplyTimer, true];
missionNamespace setVariable ["MWF_Economy_HeatMult", missionNamespace getVariable ["MWF_Economy_HeatMult", 1], true];
missionNamespace setVariable ["MWF_ThreatGainMultiplier", _threatGainMultiplier, true];
missionNamespace setVariable ["MWF_ThreatDecayMultiplier", _threatDecayMultiplier, true];
missionNamespace setVariable ["MWF_ThreatDecayPerMinute", 2 * (_threatDecayMultiplier max 0), true];
missionNamespace setVariable ["MWF_WorldTierMultiplier", _worldTierMultiplier, true];
missionNamespace setVariable ["MWF_Locked_ThreatGainMultiplier", _threatGainMultiplier, true];
missionNamespace setVariable ["MWF_Locked_ThreatDecayMultiplier", _threatDecayMultiplier, true];
missionNamespace setVariable ["MWF_Locked_WorldTierMultiplier", _worldTierMultiplier, true];
missionNamespace setVariable ["MWF_Locked_EndgameMapControlRequired", _endgameMapControlRequired, true];
missionNamespace setVariable ["MWF_Param_MaxFOBs", _maxFOBs, true];
missionNamespace setVariable ["MWF_Param_SideMissionTemplateLimit", (_sideMissionTemplateLimit max 9) min 99, true];
missionNamespace setVariable ["MWF_Param_InitialFOBType", _initialFOBType, true];
missionNamespace setVariable ["MWF_Param_IncomeMultiplier", _incomeMultiplier, true];
missionNamespace setVariable ["MWF_Locked_BuildingDamageMode", _buildingMode, true];
missionNamespace setVariable ["MWF_LockedBuildingMode", _buildingMode, true];
missionNamespace setVariable ["MWF_SpawnDistance", _sessionSpawnDistance, true];
missionNamespace setVariable ["MWF_PlayerScalingBracket", _sessionScalingBracket, true];
missionNamespace setVariable ["MWF_PlayerScalingLabel", _scalingLabel, true];
missionNamespace setVariable ["MWF_UndercoverRedDecaySeconds", missionNamespace getVariable ["MWF_UndercoverRedDecaySeconds", 45], true];
missionNamespace setVariable ["MWF_DynamicUnitCap", _sessionUnitCap, true];
missionNamespace setVariable ["MWF_DebugMode", _sessionDebugMode, true];

if (_sessionDebugMode && {isServer}) then {
    missionNamespace setVariable ["MWF_DebugCommanderGuardStarted", missionNamespace getVariable ["MWF_DebugCommanderGuardStarted", false], true];
    if !(missionNamespace getVariable ["MWF_DebugCommanderGuardStarted", false]) then {
        missionNamespace setVariable ["MWF_DebugCommanderGuardStarted", true, true];
        [] spawn {
            while {missionNamespace getVariable ["MWF_DebugMode", false]} do {
                private _commander = missionNamespace getVariable ["MWF_Commander", objNull];
                if (!isNull _commander && {alive _commander}) then {
                    _commander allowDamage false;
                    _commander setDamage 0;
                };
                uiSleep 2;
            };
            missionNamespace setVariable ["MWF_DebugCommanderGuardStarted", false, true];
        };
    };
    diag_log "[MWF Debug] Debug mode active. Supplies/Intel forced to 9999 and commander invulnerability guard enabled.";
};

if ((missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isEqualTo "OPEN_WAR") then {
    missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
    missionNamespace setVariable ["MWF_current_stage", 3, true];
};

diag_log format [
    "[MWF] Global state initialized. Campaign phase: %1 | Rebel threshold: %2 | Civilian penalty: -%3 | Scaling: %4 | Unit cap: %5",
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    missionNamespace getVariable ["MWF_CivRep_Threshold_Rebel", -25],
    missionNamespace getVariable ["MWF_CivRep_Penalty_CivilianDeath", 2],
    missionNamespace getVariable ["MWF_PlayerScalingLabel", "9-16 Players (Medium Group)"],
    missionNamespace getVariable ["MWF_DynamicUnitCap", 100]
];
