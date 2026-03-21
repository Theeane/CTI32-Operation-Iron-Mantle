/*
    Author: Theane / ChatGPT
    Function: MWF_fn_initSystems
    Project: Military War Framework

    Description:
    Initializes core runtime state that must exist before background systems start.
*/

if (!isServer) exitWith {};

missionNamespace setVariable ["MWF_CoreVersion", "1.0", true];
missionNamespace setVariable ["MWF_isWiping", false, true];
missionNamespace setVariable ["MWF_systems_ready", false, true];

missionNamespace setVariable ["MWF_all_mission_zones", missionNamespace getVariable ["MWF_all_mission_zones", []], true];
missionNamespace setVariable ["MWF_ActiveZones", missionNamespace getVariable ["MWF_ActiveZones", []], true];
missionNamespace setVariable ["MWF_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", missionNamespace getVariable ["MWF_FOB_Positions", []], true];
missionNamespace setVariable ["MWF_FOB_Registry", missionNamespace getVariable ["MWF_FOB_Registry", []], true];
missionNamespace setVariable ["MWF_FOBsRestored", missionNamespace getVariable ["MWF_FOBsRestored", false], true];
missionNamespace setVariable ["MWF_GarageRegistry", missionNamespace getVariable ["MWF_GarageRegistry", []], true];
missionNamespace setVariable ["MWF_GarageStoredVehicles", missionNamespace getVariable ["MWF_GarageStoredVehicles", []], true];
missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", missionNamespace getVariable ["MWF_BuiltUpgradeRegistry", []], true];
missionNamespace setVariable ["MWF_PendingBuiltUpgradeStructures", missionNamespace getVariable ["MWF_PendingBuiltUpgradeStructures", []], true];
missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", missionNamespace getVariable ["MWF_BuiltUpgradeStructuresRestored", false], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", missionNamespace getVariable ["MWF_FixedInfrastructure", []], true];
missionNamespace setVariable ["MWF_PotentialBaseSites", missionNamespace getVariable ["MWF_PotentialBaseSites", []], true];
missionNamespace setVariable ["MWF_HQSiteRegistry", missionNamespace getVariable ["MWF_HQSiteRegistry", []], true];
missionNamespace setVariable ["MWF_RoadblockSiteRegistry", missionNamespace getVariable ["MWF_RoadblockSiteRegistry", []], true];
missionNamespace setVariable ["MWF_InfrastructureRegistry", missionNamespace getVariable ["MWF_InfrastructureRegistry", []], true];
missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []], true];
missionNamespace setVariable ["MWF_InfrastructureBootstrapped", missionNamespace getVariable ["MWF_InfrastructureBootstrapped", false], true];
missionNamespace setVariable ["MWF_NextInfrastructureId", missionNamespace getVariable ["MWF_NextInfrastructureId", 0], true];
missionNamespace setVariable ["MWF_FreeMainOpCharges", missionNamespace getVariable ["MWF_FreeMainOpCharges", 0], true];
missionNamespace setVariable ["MWF_completedMissions", missionNamespace getVariable ["MWF_completedMissions", []], true];
missionNamespace setVariable ["MWF_RepPenaltyCount", missionNamespace getVariable ["MWF_RepPenaltyCount", 0], true];
missionNamespace setVariable ["MWF_CurrentTier", missionNamespace getVariable ["MWF_CurrentTier", 1], true];
missionNamespace setVariable ["MWF_AuthenticatedPlayers", missionNamespace getVariable ["MWF_AuthenticatedPlayers", []], true];
missionNamespace setVariable ["MWF_Campaign_Analytics", missionNamespace getVariable ["MWF_Campaign_Analytics", []], true];
missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false], true];

missionNamespace setVariable ["MWF_WorldTier", missionNamespace getVariable ["MWF_WorldTier", 1], true];
missionNamespace setVariable ["MWF_WorldTierScore", missionNamespace getVariable ["MWF_WorldTierScore", 0], true];
missionNamespace setVariable ["MWF_WorldTierProgress", missionNamespace getVariable ["MWF_WorldTierProgress", 0], true];
missionNamespace setVariable ["MWF_WorldTierFloor", missionNamespace getVariable ["MWF_WorldTierFloor", 1], true];
missionNamespace setVariable ["MWF_WorldTierHalfMapLock", missionNamespace getVariable ["MWF_WorldTierHalfMapLock", false], true];
missionNamespace setVariable ["MWF_WorldTierProgressBlockedUntil", missionNamespace getVariable ["MWF_WorldTierProgressBlockedUntil", 0], true];
missionNamespace setVariable ["MWF_TierFreeze_Active", missionNamespace getVariable ["MWF_TierFreeze_Active", false], true];
missionNamespace setVariable ["MWF_TierFreeze_EndTime", missionNamespace getVariable ["MWF_TierFreeze_EndTime", 0], true];
missionNamespace setVariable ["MWF_ProgressionState", missionNamespace getVariable ["MWF_ProgressionState", "opening"], true];
missionNamespace setVariable ["MWF_WorldZoneCountTotal", missionNamespace getVariable ["MWF_WorldZoneCountTotal", 0], true];
missionNamespace setVariable ["MWF_CapturedZoneCount", missionNamespace getVariable ["MWF_CapturedZoneCount", 0], true];
missionNamespace setVariable ["MWF_CapturedTownCount", missionNamespace getVariable ["MWF_CapturedTownCount", 0], true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0], true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0], true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0], true];
missionNamespace setVariable ["MWF_MapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0], true];
missionNamespace setVariable ["MWF_ContestedZoneCount", missionNamespace getVariable ["MWF_ContestedZoneCount", 0], true];
missionNamespace setVariable ["MWF_UnderAttackZoneCount", missionNamespace getVariable ["MWF_UnderAttackZoneCount", 0], true];
missionNamespace setVariable ["MWF_CapturedZoneIDs", missionNamespace getVariable ["MWF_CapturedZoneIDs", []], true];
missionNamespace setVariable ["MWF_ProgressionMilestonesArray", missionNamespace getVariable ["MWF_ProgressionMilestonesArray", []], true];
missionNamespace setVariable ["MWF_WorldStateVersion", missionNamespace getVariable ["MWF_WorldStateVersion", 0], true];
missionNamespace setVariable ["MWF_WorldSystemReady", missionNamespace getVariable ["MWF_WorldSystemReady", false], true];
missionNamespace setVariable ["MWF_WorldManagerStarted", missionNamespace getVariable ["MWF_WorldManagerStarted", false], true];
missionNamespace setVariable ["MWF_WorldSnapshot", missionNamespace getVariable ["MWF_WorldSnapshot", createHashMap], false];
missionNamespace setVariable ["MWF_ProgressionMilestones", missionNamespace getVariable ["MWF_ProgressionMilestones", createHashMap], false];
missionNamespace setVariable ["MWF_WorldStateDirty", missionNamespace getVariable ["MWF_WorldStateDirty", true], false];
missionNamespace setVariable ["MWF_WorldRecalcRunning", missionNamespace getVariable ["MWF_WorldRecalcRunning", false], false];
missionNamespace setVariable ["MWF_WorldLastRecalcAt", missionNamespace getVariable ["MWF_WorldLastRecalcAt", -1], false];

missionNamespace setVariable ["MWF_GlobalThreatLevel", missionNamespace getVariable ["MWF_GlobalThreatLevel", 0], true];
missionNamespace setVariable ["MWF_GlobalThreatPercent", missionNamespace getVariable ["MWF_GlobalThreatPercent", 0], true];
missionNamespace setVariable ["MWF_GlobalThreatState", missionNamespace getVariable ["MWF_GlobalThreatState", "low"], true];
missionNamespace setVariable ["MWF_MainOpThreatProgressBlockedUntil", missionNamespace getVariable ["MWF_MainOpThreatProgressBlockedUntil", 0], true];
missionNamespace setVariable ["MWF_WorldTierBlockImmuneUntil", missionNamespace getVariable ["MWF_WorldTierBlockImmuneUntil", 0], true];
missionNamespace setVariable ["MWF_ThreatDecayPerMinute", missionNamespace getVariable ["MWF_ThreatDecayPerMinute", 2], true];
missionNamespace setVariable ["MWF_ThreatHotZones", missionNamespace getVariable ["MWF_ThreatHotZones", []], true];
missionNamespace setVariable ["MWF_ThreatHotspotDuration", missionNamespace getVariable ["MWF_ThreatHotspotDuration", 900], true];
missionNamespace setVariable ["MWF_ThreatLastDecayAt", missionNamespace getVariable ["MWF_ThreatLastDecayAt", -1], true];
missionNamespace setVariable ["MWF_ThreatPressureScore", missionNamespace getVariable ["MWF_ThreatPressureScore", 0], true];
missionNamespace setVariable ["MWF_HighThreatZoneIDs", missionNamespace getVariable ["MWF_HighThreatZoneIDs", []], true];
missionNamespace setVariable ["MWF_CriticalThreatZoneIDs", missionNamespace getVariable ["MWF_CriticalThreatZoneIDs", []], true];
missionNamespace setVariable ["MWF_ThreatPriorityZoneIDs", missionNamespace getVariable ["MWF_ThreatPriorityZoneIDs", []], true];
missionNamespace setVariable ["MWF_ZoneThreatSummary", missionNamespace getVariable ["MWF_ZoneThreatSummary", []], true];
missionNamespace setVariable ["MWF_ThreatDirectiveArray", missionNamespace getVariable ["MWF_ThreatDirectiveArray", []], true];
missionNamespace setVariable ["MWF_ThreatResponseQueueArray", missionNamespace getVariable ["MWF_ThreatResponseQueueArray", []], true];
missionNamespace setVariable ["MWF_ThreatIncidentLog", missionNamespace getVariable ["MWF_ThreatIncidentLog", []], true];
missionNamespace setVariable ["MWF_ThreatBasePressure", missionNamespace getVariable ["MWF_ThreatBasePressure", 0], true];
missionNamespace setVariable ["MWF_ThreatBaseAttackState", missionNamespace getVariable ["MWF_ThreatBaseAttackState", "idle"], true];
missionNamespace setVariable ["MWF_ThreatRoadblockPressure", missionNamespace getVariable ["MWF_ThreatRoadblockPressure", 0], true];
missionNamespace setVariable ["MWF_ThreatHQPressure", missionNamespace getVariable ["MWF_ThreatHQPressure", 0], true];
missionNamespace setVariable ["MWF_ThreatPatrolDensity", missionNamespace getVariable ["MWF_ThreatPatrolDensity", 0.2], true];
missionNamespace setVariable ["MWF_ThreatQRFInterval", missionNamespace getVariable ["MWF_ThreatQRFInterval", 900], true];
missionNamespace setVariable ["MWF_ThreatMissionEscalation", missionNamespace getVariable ["MWF_ThreatMissionEscalation", "low"], true];
missionNamespace setVariable ["MWF_ThreatStateVersion", missionNamespace getVariable ["MWF_ThreatStateVersion", 0], true];
missionNamespace setVariable ["MWF_ThreatSystemReady", missionNamespace getVariable ["MWF_ThreatSystemReady", false], true];
missionNamespace setVariable ["MWF_ThreatManagerStarted", missionNamespace getVariable ["MWF_ThreatManagerStarted", false], true];
missionNamespace setVariable ["MWF_ZoneThreatIndex", missionNamespace getVariable ["MWF_ZoneThreatIndex", createHashMap], false];
missionNamespace setVariable ["MWF_ThreatDirectives", missionNamespace getVariable ["MWF_ThreatDirectives", createHashMap], false];
missionNamespace setVariable ["MWF_ThreatResponseQueue", missionNamespace getVariable ["MWF_ThreatResponseQueue", []], false];
missionNamespace setVariable ["MWF_ThreatPriorityTargets", missionNamespace getVariable ["MWF_ThreatPriorityTargets", []], false];
missionNamespace setVariable ["MWF_ThreatSnapshot", missionNamespace getVariable ["MWF_ThreatSnapshot", createHashMap], false];
missionNamespace setVariable ["MWF_ThreatStateDirty", missionNamespace getVariable ["MWF_ThreatStateDirty", true], false];
missionNamespace setVariable ["MWF_ThreatRecalcRunning", missionNamespace getVariable ["MWF_ThreatRecalcRunning", false], false];
missionNamespace setVariable ["MWF_ThreatLastRecalcAt", missionNamespace getVariable ["MWF_ThreatLastRecalcAt", -1], false];

missionNamespace setVariable ["MWF_MissionTemplateRegistry", missionNamespace getVariable ["MWF_MissionTemplateRegistry", []], true];
missionNamespace setVariable ["MWF_MissionSessionPlacements", missionNamespace getVariable ["MWF_MissionSessionPlacements", []], true];
missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", missionNamespace getVariable ["MWF_GrandOperationSessionPlacements", []], true];
missionNamespace setVariable ["MWF_MissionBoardSlots", missionNamespace getVariable ["MWF_MissionBoardSlots", []], true];
missionNamespace setVariable ["MWF_MissionBoardCreatedAt", missionNamespace getVariable ["MWF_MissionBoardCreatedAt", 0], true];
missionNamespace setVariable ["MWF_MissionBoardExpiresAt", missionNamespace getVariable ["MWF_MissionBoardExpiresAt", 0], true];
missionNamespace setVariable ["MWF_ActiveSideMissions", missionNamespace getVariable ["MWF_ActiveSideMissions", []], true];
missionNamespace setVariable ["MWF_MissionSystemReady", missionNamespace getVariable ["MWF_MissionSystemReady", false], true];
missionNamespace setVariable ["MWF_MissionSystemStarted", missionNamespace getVariable ["MWF_MissionSystemStarted", false], true];
missionNamespace setVariable ["MWF_MainOperationCooldowns", missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap], true];
missionNamespace setVariable ["MWF_GrandOperationActive", missionNamespace getVariable ["MWF_GrandOperationActive", false], true];
missionNamespace setVariable ["MWF_CurrentGrandOperation", missionNamespace getVariable ["MWF_CurrentGrandOperation", ""], true];
missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", missionNamespace getVariable ["MWF_CurrentGrandOperationTitle", ""], true];
missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", missionNamespace getVariable ["MWF_CurrentGrandOperationPlacement", []], true];
missionNamespace setVariable ["MWF_PendingGrandOperationState", missionNamespace getVariable ["MWF_PendingGrandOperationState", []], true];
missionNamespace setVariable ["MWF_MainOperationRuntime", missionNamespace getVariable ["MWF_MainOperationRuntime", createHashMap], true];
missionNamespace setVariable ["MWF_Unlock_Heli", missionNamespace getVariable ["MWF_Unlock_Heli", false], true];
missionNamespace setVariable ["MWF_Unlock_Jets", missionNamespace getVariable ["MWF_Unlock_Jets", false], true];
missionNamespace setVariable ["MWF_Unlock_Armor", missionNamespace getVariable ["MWF_Unlock_Armor", false], true];
missionNamespace setVariable ["MWF_Unlock_Tier5", missionNamespace getVariable ["MWF_Unlock_Tier5", false], true];
missionNamespace setVariable ["MWF_Perk_HeliDiscount", missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1], true];

missionNamespace setVariable ["MWF_CivilianCasualties", missionNamespace getVariable ["MWF_CivilianCasualties", 0], true];
missionNamespace setVariable ["MWF_RebelLeaderSettlementCount", missionNamespace getVariable ["MWF_RebelLeaderSettlementCount", 0], true];
missionNamespace setVariable ["MWF_RebelLeaderEventActive", missionNamespace getVariable ["MWF_RebelLeaderEventActive", false], true];
missionNamespace setVariable ["MWF_ActiveRebelLeader", missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull], true];
missionNamespace setVariable ["MWF_RebelLeaderContext", missionNamespace getVariable ["MWF_RebelLeaderContext", []], true];
missionNamespace setVariable ["MWF_FOBAttackState", missionNamespace getVariable ["MWF_FOBAttackState", ["idle"]], true];
missionNamespace setVariable ["MWF_RebelLeaderRespawnState", missionNamespace getVariable ["MWF_RebelLeaderRespawnState", []], true];
missionNamespace setVariable ["MWF_DamagedFOBs", missionNamespace getVariable ["MWF_DamagedFOBs", []], true];
missionNamespace setVariable ["MWF_PendingRebelLeaderContext", missionNamespace getVariable ["MWF_PendingRebelLeaderContext", []], true];
missionNamespace setVariable ["MWF_PendingFOBAttackState", missionNamespace getVariable ["MWF_PendingFOBAttackState", []], true];
missionNamespace setVariable ["MWF_PendingRebelLeaderRespawnState", missionNamespace getVariable ["MWF_PendingRebelLeaderRespawnState", []], true];
missionNamespace setVariable ["MWF_PendingDamagedFOBs", missionNamespace getVariable ["MWF_PendingDamagedFOBs", []], true];
missionNamespace setVariable ["MWF_isUnderAttack", missionNamespace getVariable ["MWF_isUnderAttack", false], true];
missionNamespace setVariable ["MWF_Campaign_Analytics", missionNamespace getVariable ["MWF_Campaign_Analytics", []], true];

setTimeMultiplier (["MWF_Param_TimeMultiplier", 1] call BIS_fnc_getParamValue);

private _wipeRequested = ["MWF_Param_WipeSave", 0] call BIS_fnc_getParamValue;
private _wipeConfirmed = ["MWF_Param_ConfirmWipe", 0] call BIS_fnc_getParamValue;

if (_wipeRequested == 1 && _wipeConfirmed == 1) then {
    missionNamespace setVariable ["MWF_isWiping", true, true];

    if (!isNil "MWF_fnc_wipeSave") then {
        [] call MWF_fnc_wipeSave;
    };

    diag_log "[MWF] Save wipe requested by lobby parameters.";
};

missionNamespace setVariable ["MWF_systems_ready", true, true];
diag_log "[MWF] Core systems initialized.";
