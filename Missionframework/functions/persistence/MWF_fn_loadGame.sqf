/*
    Author: Theane / ChatGPT
    Function: fn_loadGame
    Project: Military War Framework

    Description:
    Restores strategic campaign state and all campaign-persistent lobby params.
    Also restores saved rebel escalation state, damaged FOB timers, civilian casualty counters,
    and production bonus state.
*/

if (!isServer) exitWith {};

private _hasCampaignSave = profileNamespace getVariable ["MWF_Save_HasCampaign", false];
missionNamespace setVariable ["MWF_HasCampaignSave", _hasCampaignSave, true];

private _clampNumber = {
    params ["_value", "_min", "_max", "_fallback"];
    if !(_value isEqualType 0) exitWith { _fallback };
    (_value max _min) min _max
};

private _getPersistentValue = {
    params ["_saveKey", "_paramName", "_defaultValue", "_missionVar", "_min", "_max"];

    private _value = if (_hasCampaignSave) then {
        profileNamespace getVariable [_saveKey, _defaultValue]
    } else {
        [_paramName, _defaultValue] call BIS_fnc_getParamValue
    };

    _value = [_value, _min, _max, _defaultValue] call _clampNumber;

    missionNamespace setVariable [_missionVar, _value, true];
    profileNamespace setVariable [_saveKey, _value];

    _value
};

private _lockedStartSupplies = ["MWF_Save_StartSupplies", "MWF_Param_StartSupplies", 200, "MWF_Locked_StartSupplies", 0, 100000] call _getPersistentValue;
private _lockedSupplyTimer = ["MWF_Save_SupplyTimer", "MWF_Param_SupplyTimer", 10, "MWF_Locked_SupplyTimer", 1, 3600] call _getPersistentValue;
private _lockedCivRep = ["MWF_Save_CivReputation", "MWF_Param_CivReputation", 0, "MWF_Locked_CivReputation", -1000, 1000] call _getPersistentValue;
private _lockedNotorietyMult = ["MWF_Save_NotorietyMultiplier", "MWF_Param_NotorietyMultiplier", 1, "MWF_Locked_NotorietyMultiplier", 0, 100] call _getPersistentValue;
private _lockedBuildingMode = ["MWF_Save_BuildingMode", "MWF_Param_BuildingDamageMode", 0, "MWF_Locked_BuildingDamageMode", 0, 10] call _getPersistentValue;
private _lockedIncomeMultiplier = ["MWF_Save_IncomeMultiplier", "MWF_Param_IncomeMultiplier", 1, "MWF_Locked_IncomeMultiplier", 0, 100] call _getPersistentValue;
private _lockedMaxFOBs = ["MWF_Save_MaxFOBs", "MWF_Param_MaxFOBs", 5, "MWF_Locked_MaxFOBs", 0, 100] call _getPersistentValue;
private _lockedCompositionTypeChoice = ["MWF_Save_CompositionType", "MWF_Param_CompositionType", 0, "MWF_Locked_CompositionTypeChoice", 0, 3] call _getPersistentValue;

missionNamespace setVariable ["MWF_LockedBuildingMode", _lockedBuildingMode, true];
missionNamespace setVariable ["MWF_Param_MaxFOBs", _lockedMaxFOBs, true];
missionNamespace setVariable ["MWF_Param_IncomeMultiplier", _lockedIncomeMultiplier, true];
missionNamespace setVariable ["MWF_Param_CompositionType", _lockedCompositionTypeChoice, true];

private _compositionType = switch _lockedCompositionTypeChoice do {
    case 1: {"vietnam"};
    case 2: {"world_war_2"};
    case 3: {"global_mobilization"};
    default {"modern"};
};
missionNamespace setVariable ["MWF_CompositionType", _compositionType, true];

private _loadFactionLock = {
    params ["_prefix", "_sourceParam", "_defaultParam", "_customParam", "_defaultChoice"];

    private _source = if (_hasCampaignSave) then {
        profileNamespace getVariable [format ["MWF_Save_%1Source", _prefix], -1]
    } else {
        -1
    };

    private _choice = if (_hasCampaignSave) then {
        profileNamespace getVariable [format ["MWF_Save_%1Choice", _prefix], -9999]
    } else {
        -9999
    };

    if (_source < 0) then {
        _source = [_sourceParam, 0] call BIS_fnc_getParamValue;
    };
    _source = [_source, 0, 1, 0] call _clampNumber;

    if (_choice == -9999) then {
        _choice = if (_source == 0) then {
            [_defaultParam, _defaultChoice] call BIS_fnc_getParamValue
        } else {
            [_customParam, 1] call BIS_fnc_getParamValue
        };
    };

    _choice = [_choice, 0, 9999, _defaultChoice] call _clampNumber;

    missionNamespace setVariable [format ["MWF_Locked_%1Source", _prefix], _source, true];
    missionNamespace setVariable [format ["MWF_Locked_%1Choice", _prefix], _choice, true];

    profileNamespace setVariable [format ["MWF_Save_%1Source", _prefix], _source];
    profileNamespace setVariable [format ["MWF_Save_%1Choice", _prefix], _choice];
};

["Blufor", "MWF_Param_BluforSource", "MWF_Param_Blufor", "MWF_Param_CustomBlufor", 0] call _loadFactionLock;
["Opfor", "MWF_Param_OpforSource", "MWF_Param_Opfor", "MWF_Param_CustomOpfor", 0] call _loadFactionLock;
["Resistance", "MWF_Param_ResistanceSource", "MWF_Param_Resistance", "MWF_Param_CustomResistance", 0] call _loadFactionLock;
["Civs", "MWF_Param_CivsSource", "MWF_Param_Civs", "MWF_Param_CustomCivs", 0] call _loadFactionLock;

private _supplies = [profileNamespace getVariable ["MWF_Save_Supplies", _lockedStartSupplies], 0, 100000, _lockedStartSupplies] call _clampNumber;
private _intel = [profileNamespace getVariable ["MWF_Save_Intel", 0], 0, 50000, 0] call _clampNumber;
private _civRepState = [profileNamespace getVariable ["MWF_Save_CivRep_State", _lockedCivRep], -1000, 1000, _lockedCivRep] call _clampNumber;
private _notoriety = [profileNamespace getVariable ["MWF_Save_Notoriety_State", 0], 0, 1000, 0] call _clampNumber;

if (!isNil "MWF_fnc_syncEconomyState") then {
    [_supplies, _intel, _notoriety, true, false] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
    missionNamespace setVariable ["MWF_res_intel", _intel, true];
    missionNamespace setVariable ["MWF_res_notoriety", _notoriety, true];
    missionNamespace setVariable ["MWF_Supplies", _supplies, true];
    missionNamespace setVariable ["MWF_Intel", _intel, true];
    missionNamespace setVariable ["MWF_Supply", _supplies, true];
    missionNamespace setVariable ["MWF_Currency", _supplies + _intel, true];
};

missionNamespace setVariable ["MWF_CivRep", _civRepState, true];
missionNamespace setVariable ["MWF_ProductionBonus", [profileNamespace getVariable ["MWF_Save_ProductionBonus", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_RepPenaltyCount", [profileNamespace getVariable ["MWF_Save_RepPenalties", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CivilianCasualties", [profileNamespace getVariable ["MWF_Save_CivilianCasualties", 0], 0, 1000000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_DestroyedHQs", profileNamespace getVariable ["MWF_Save_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", profileNamespace getVariable ["MWF_Save_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", profileNamespace getVariable ["MWF_Save_FOBs", []], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", profileNamespace getVariable ["MWF_Save_FixedInfra", []], true];
missionNamespace setVariable ["MWF_PotentialBaseSites", profileNamespace getVariable ["MWF_Save_PotentialBaseSites", []], true];
missionNamespace setVariable ["MWF_FreeMainOpCharges", [profileNamespace getVariable ["MWF_Save_FreeMainOpCharges", 0], 0, 9999, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", +(profileNamespace getVariable ["MWF_Save_RevealedInfrastructureIDs", []]), true];
missionNamespace setVariable ["MWF_completedMissions", profileNamespace getVariable ["MWF_Save_Missions", []], true];
missionNamespace setVariable ["MWF_CurrentTier", [profileNamespace getVariable ["MWF_Save_Tier", 1], 1, 10, 1] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedZoneCount", [profileNamespace getVariable ["MWF_Save_CapturedZoneCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedTownCount", [profileNamespace getVariable ["MWF_Save_CapturedTownCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", [profileNamespace getVariable ["MWF_Save_CapturedCapitalCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", [profileNamespace getVariable ["MWF_Save_CapturedFactoryCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", [profileNamespace getVariable ["MWF_Save_CapturedMilitaryCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_MapControlPercent", [profileNamespace getVariable ["MWF_Save_MapControlPercent", 0], 0, 100, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_WorldTier", [profileNamespace getVariable ["MWF_Save_WorldTier", 1], 1, 5, 1] call _clampNumber, true];
missionNamespace setVariable ["MWF_WorldTierScore", [profileNamespace getVariable ["MWF_Save_WorldTierScore", 0], 0, 499, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_WorldTierProgress", [profileNamespace getVariable ["MWF_Save_WorldTierProgress", 0], 0, 100, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_WorldTierFloor", [profileNamespace getVariable ["MWF_Save_WorldTierFloor", 1], 1, 5, 1] call _clampNumber, true];
missionNamespace setVariable ["MWF_WorldTierHalfMapLock", profileNamespace getVariable ["MWF_Save_WorldTierHalfMapLock", false], true];
missionNamespace setVariable ["MWF_WorldTierProgressBlockedUntil", serverTime + ([profileNamespace getVariable ["MWF_Save_WorldTierProgressBlockedRemaining", 0], 0, 86400, 0] call _clampNumber), true];
missionNamespace setVariable ["MWF_TierFreeze_Active", profileNamespace getVariable ["MWF_Save_TierFreeze_Active", false], true];
missionNamespace setVariable ["MWF_TierFreeze_EndTime", serverTime + ([profileNamespace getVariable ["MWF_Save_TierFreeze_Remaining", 0], 0, 86400, 0] call _clampNumber), true];
missionNamespace setVariable ["MWF_GlobalThreatPercent", [profileNamespace getVariable ["MWF_Save_GlobalThreatPercent", 0], 0, 100, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_MainOpThreatProgressBlockedUntil", serverTime + ([profileNamespace getVariable ["MWF_Save_MainOpThreatBlockedRemaining", 0], 0, 86400, 0] call _clampNumber), true];
missionNamespace setVariable ["MWF_WorldTierBlockImmuneUntil", serverTime + ([profileNamespace getVariable ["MWF_Save_WorldTierBlockImmuneRemaining", 0], 0, 86400, 0] call _clampNumber), true];
missionNamespace setVariable ["MWF_ThreatHotZones", profileNamespace getVariable ["MWF_Save_ThreatHotZones", []], true];
missionNamespace setVariable ["MWF_LoadedZoneSaveData", profileNamespace getVariable ["MWF_Save_ZoneData", []], true];
missionNamespace setVariable ["MWF_PendingBoughtVehicles", profileNamespace getVariable ["MWF_Save_BoughtVehicles", []], true];
missionNamespace setVariable ["MWF_GarageStoredVehicles", profileNamespace getVariable ["MWF_Save_GarageStoredVehicles", []], true];
missionNamespace setVariable ["MWF_PendingActiveSideMissions", profileNamespace getVariable ["MWF_Save_ActiveSideMissions", []], true];
missionNamespace setVariable ["MWF_Campaign_Phase", profileNamespace getVariable ["MWF_Save_Campaign_Phase", "TUTORIAL"], true];
missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", profileNamespace getVariable ["MWF_Save_Tutorial_SupplyRunDone", false], true];
missionNamespace setVariable ["MWF_RebelLeaderSettlementCount", [profileNamespace getVariable ["MWF_Save_RebelLeaderSettlementCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_PendingRebelLeaderContext", profileNamespace getVariable ["MWF_Save_RebelLeaderContext", []], true];
missionNamespace setVariable ["MWF_PendingFOBAttackState", profileNamespace getVariable ["MWF_Save_FOBAttackState", []], true];
missionNamespace setVariable ["MWF_PendingRebelLeaderRespawnState", profileNamespace getVariable ["MWF_Save_RebelLeaderRespawnState", []], true];
missionNamespace setVariable ["MWF_PendingDamagedFOBs", profileNamespace getVariable ["MWF_Save_DamagedFOBs", []], true];
missionNamespace setVariable ["MWF_RebelLeaderEventActive", false, true];
missionNamespace setVariable ["MWF_ActiveRebelLeader", objNull, true];
missionNamespace setVariable ["MWF_RebelLeaderContext", [], true];
missionNamespace setVariable ["MWF_RebelLeaderRespawnState", [], true];
missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];
missionNamespace setVariable ["MWF_DamagedFOBs", [], true];
missionNamespace setVariable ["MWF_isUnderAttack", false, true];
missionNamespace setVariable ["MWF_SessionVehiclesRestored", false, true];
missionNamespace setVariable ["MWF_PendingActiveSideMissionsRestored", false, true];
missionNamespace setVariable ["MWF_Unlock_Heli", profileNamespace getVariable ["MWF_Save_Unlock_Heli", false], true];
missionNamespace setVariable ["MWF_Unlock_Jets", profileNamespace getVariable ["MWF_Save_Unlock_Jets", false], true];
missionNamespace setVariable ["MWF_Unlock_Armor", profileNamespace getVariable ["MWF_Save_Unlock_Armor", false], true];
missionNamespace setVariable ["MWF_Unlock_Tier5", profileNamespace getVariable ["MWF_Save_Unlock_Tier5", false], true];
missionNamespace setVariable ["MWF_Perk_HeliDiscount", [profileNamespace getVariable ["MWF_Save_Perk_HeliDiscount", 1], 0.01, 10, 1] call _clampNumber, true];
missionNamespace setVariable ["MWF_Campaign_Analytics", profileNamespace getVariable ["MWF_Save_CampaignAnalytics", []], true];
missionNamespace setVariable ["MWF_AuthenticatedPlayers", profileNamespace getVariable ["MWF_Save_AuthenticatedPlayers", []], true];
private _cooldownPairs = profileNamespace getVariable ["MWF_Save_MainOperationCooldowns", []];
private _cooldownMap = createHashMap;
{
    if (_x isEqualType [] && {count _x >= 2}) then {
        private _cooldownKey = _x param [0, "", [""]];
        private _cooldownRemaining = [_x param [1, 0, [0]], 0, 86400, 0] call _clampNumber;
        if (_cooldownKey isNotEqualTo "" && {_cooldownRemaining > 0}) then {
            _cooldownMap set [_cooldownKey, serverTime + _cooldownRemaining];
        };
    };
} forEach _cooldownPairs;
missionNamespace setVariable ["MWF_MainOperationCooldowns", _cooldownMap, true];

private _grandOperationState = profileNamespace getVariable ["MWF_Save_GrandOperationState", []];
missionNamespace setVariable ["MWF_PendingGrandOperationState", _grandOperationState, true];
if (_grandOperationState isEqualType [] && {count _grandOperationState >= 3}) then {
    missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", _grandOperationState param [0, "", [""]], true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _grandOperationState param [1, "", [""]], true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", + (_grandOperationState param [2, [], [[]]]), true];
} else {
    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
};

if ((missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isEqualTo "OPEN_WAR") then {
    missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
    missionNamespace setVariable ["MWF_current_stage", 3, true];
};

profileNamespace setVariable ["MWF_Save_HasCampaign", true];
saveProfileNamespace;

diag_log format [
    "[MWF] Campaign state restored. Phase: %1 | Pending saved zones: %2 | Pending vehicles: %3 | Pending missions: %4 | Pending leader: %5 | Pending attack: %6 | Pending damaged FOBs: %7.",
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    count (missionNamespace getVariable ["MWF_LoadedZoneSaveData", []]),
    count (missionNamespace getVariable ["MWF_PendingBoughtVehicles", []]),
    count (missionNamespace getVariable ["MWF_PendingActiveSideMissions", []]),
    count (missionNamespace getVariable ["MWF_PendingRebelLeaderContext", []]),
    count (missionNamespace getVariable ["MWF_PendingFOBAttackState", []]),
    count (missionNamespace getVariable ["MWF_PendingDamagedFOBs", []])
];
