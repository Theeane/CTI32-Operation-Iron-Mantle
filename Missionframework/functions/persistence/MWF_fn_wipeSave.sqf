/*
    Author: Theane / ChatGPT
    Function: fn_wipeSave
    Project: Military War Framework

    Description:
    Handles wipe save for the persistence system, including campaign-persistent lobby params,
    locked faction selections, rebel escalation state, and damaged FOB timers.
*/

if (!isServer) exitWith {};

private _keys = [
    "MWF_Save_HasCampaign",
    "MWF_Save_ZoneData",
    "MWF_Save_CapturedZoneCount",
    "MWF_Save_CapturedTownCount",
    "MWF_Save_CapturedCapitalCount",
    "MWF_Save_CapturedFactoryCount",
    "MWF_Save_CapturedMilitaryCount",
    "MWF_Save_MapControlPercent",
    "MWF_Save_WorldTier",
    "MWF_Save_WorldTierScore",
    "MWF_Save_WorldTierProgress",
    "MWF_Save_WorldTierFloor",
    "MWF_Save_WorldTierHalfMapLock",
    "MWF_Save_WorldTierProgressBlockedRemaining",
    "MWF_Save_WorldTierBlockImmuneRemaining",
    "MWF_Save_TierFreeze_Active",
    "MWF_Save_TierFreeze_Remaining",
    "MWF_Save_GlobalThreatPercent",
    "MWF_Save_MainOpThreatBlockedRemaining",
    "MWF_Save_ThreatHotZones",
    "MWF_Save_Supplies",
    "MWF_Save_Intel",
    "MWF_Save_CivRep_State",
    "MWF_Save_Notoriety_State",
    "MWF_Save_ProductionBonus",
    "MWF_Save_RepPenalties",
    "MWF_Save_CivilianCasualties",
    "MWF_Save_DestroyedHQs",
    "MWF_Save_DestroyedRoadblocks",
    "MWF_Save_FixedInfra",
    "MWF_Save_PotentialBaseSites",
    "MWF_Save_FOBs",
    "MWF_Save_Tier",
    "MWF_Save_Missions",
    "MWF_Save_BoughtVehicles",
    "MWF_Save_GarageStoredVehicles",
    "MWF_Save_BuiltUpgradeStructures",
    "MWF_Save_ActiveSideMissions",
    "MWF_Save_Campaign_Phase",
    "MWF_Save_Tutorial_SupplyRunDone",
    "MWF_Save_RebelLeaderContext",
    "MWF_Save_RebelLeaderSettlementCount",
    "MWF_Save_FOBAttackState",
    "MWF_Save_RebelLeaderRespawnState",
    "MWF_Save_DamagedFOBs",
    "MWF_Save_CampaignAnalytics",
    "MWF_Save_AuthenticatedPlayers",
    "MWF_Save_StartSupplies",
    "MWF_Save_SupplyTimer",
    "MWF_Save_CivReputation",
    "MWF_Save_ThreatGainMultiplier",
    "MWF_Save_ThreatDecayMultiplier",
    "MWF_Save_WorldTierMultiplier",
    "MWF_Save_EndgameMapControl",
    "MWF_Save_NotorietyMultiplier",
    "MWF_Save_BuildingMode",
    "MWF_Save_IncomeMultiplier",
    "MWF_Save_MaxFOBs",
    "MWF_Save_MainOperationCooldowns",
    "MWF_Save_Unlock_Heli",
    "MWF_Save_Unlock_Jets",
    "MWF_Save_Unlock_Armor",
    "MWF_Save_Unlock_Tier5",
    "MWF_Save_Perk_HeliDiscount",
    "MWF_Save_GrandOperationState",
    "MWF_Save_FreeMainOpCharges",
    "MWF_Save_RevealedInfrastructureIDs",
    "MWF_Save_RevealedInfrastructureSites",
    "MWF_Save_CompositionType",
    "MWF_Save_CompletedMainOperations",
    "MWF_Save_EndgameActive",
    "MWF_Save_EndgameCompleted",
    "MWF_Save_EndgameOutcome",
    "MWF_Save_EndgameReservedZoneId",
    "MWF_Save_EndgameState"
];

{
    profileNamespace setVariable [_x, nil];
} forEach _keys;

{
    private _prefix = _x;
    {
        profileNamespace setVariable [format ["MWF_Save_%1%2", _prefix, _x], nil];
    } forEach ["Source", "Choice", "ResolvedChoice", "Label", "File"];
} forEach ["Blufor", "Opfor", "Resistance", "Civs"];

saveProfileNamespace;

profileNamespace setVariable ["MWF_SavedRespawnProfile", nil];
saveProfileNamespace;
[] remoteExecCall ["MWF_fnc_clearRespawnLoadoutProfile", 0];

{
    if (!isNull _x && {_x getVariable ["MWF_isBought", false]}) then {
        deleteVehicle _x;
    };
} forEach (vehicles + allDead);

{
    private _terminal = _x param [1, objNull];
    if (!isNull _terminal) then {
        deleteVehicle _terminal;
    };
    private _anchor = _x param [4, objNull];
    if (!isNull _anchor) then {
        deleteVehicle _anchor;
    };
} forEach (missionNamespace getVariable ["MWF_FOB_Registry", []]);

{
    private _obj = _x param [1, objNull];
    if (!isNull _obj) then {
        deleteVehicle _obj;
    };
} forEach (missionNamespace getVariable ["MWF_BuiltUpgradeRegistry", []]);

{
    private _garageObj = _x param [0, objNull];
    if (!isNull _garageObj) then {
        deleteVehicle _garageObj;
    };
} forEach (missionNamespace getVariable ["MWF_GarageRegistry", []]);

missionNamespace setVariable ["MWF_HasCampaignSave", false, true];
missionNamespace setVariable ["MWF_FOB_Positions", [], true];
missionNamespace setVariable ["MWF_FOB_Registry", [], true];
missionNamespace setVariable ["MWF_HUD_AnchorRegistry", [], true];
missionNamespace setVariable ["MWF_PendingBoughtVehicles", [], true];
missionNamespace setVariable ["MWF_PendingBuiltUpgradeStructures", [], true];
missionNamespace setVariable ["MWF_GarageStoredVehicles", [], true];
missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", [], true];
missionNamespace setVariable ["MWF_GarageRegistry", [], true];
missionNamespace setVariable ["MWF_PendingFOBAttackState", [], true];
missionNamespace setVariable ["MWF_DamagedFOBs", [], true];
missionNamespace setVariable ["MWF_PendingDamagedFOBs", [], true];
missionNamespace setVariable ["MWF_FOBsRestored", false, true];
missionNamespace setVariable ["MWF_SessionVehiclesRestored", false, true];
missionNamespace setVariable ["MWF_BuiltUpgradeStructuresRestored", false, true];
missionNamespace setVariable ["MWF_InitialFOBAssetRef", objNull, true];

diag_log "[MWF PERSISTENCE] All campaign data has been wiped. Bought vehicles, FOB registry, garage registry, and saved profiles were cleared for a fresh start.";
["Campaign data reset. Restart mission/server for a clean new campaign."] remoteExec ["systemChat", 0];
