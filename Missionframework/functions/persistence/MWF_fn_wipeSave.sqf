/*
    Author: Theane / ChatGPT
    Function: fn_wipeSave
    Project: Military War Framework

    Description:
    Handles wipe save for the persistence system, including campaign-persistent lobby params,
    locked faction selections, rebel escalation state, damaged FOB timers, and
    per-operation main operation cooldowns.
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
    "MWF_Save_TierFreeze_Active",
    "MWF_Save_TierFreeze_Remaining",
    "MWF_Save_GlobalThreatPercent",
    "MWF_Save_MainOpThreatBlockedRemaining",
    "MWF_Save_MainOperationCooldowns",
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
    "MWF_Save_FOBs",
    "MWF_Save_Tier",
    "MWF_Save_Missions",
    "MWF_Save_BoughtVehicles",
    "MWF_Save_ActiveSideMissions",
    "MWF_Save_Campaign_Phase",
    "MWF_Save_Tutorial_SupplyRunDone",
    "MWF_Save_RebelLeaderContext",
    "MWF_Save_RebelLeaderSettlementCount",
    "MWF_Save_FOBAttackState",
    "MWF_Save_DamagedFOBs",
    "MWF_Save_StartSupplies",
    "MWF_Save_SupplyTimer",
    "MWF_Save_CivReputation",
    "MWF_Save_NotorietyMultiplier",
    "MWF_Save_BuildingMode",
    "MWF_Save_IncomeMultiplier",
    "MWF_Save_MaxFOBs"
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

diag_log "[MWF PERSISTENCE] All campaign data has been wiped. A fresh start is ready.";
["Campaign data reset. Please restart the mission for a clean slate.", "systemChat"] remoteExec ["bis_fnc_guiMessage", 0];
