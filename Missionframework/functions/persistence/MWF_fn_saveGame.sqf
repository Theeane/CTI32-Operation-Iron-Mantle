/*
    Author: Theane / ChatGPT
    Function: fn_saveGame
    Project: Military War Framework

    Description:
    Saves strategic campaign state, normalized zone progression data, campaign-persistent
    lobby params, economy state, rebel escalation state, and damaged FOB timers.
*/

if (!isServer) exitWith {};
params [["_reason", "Auto Save", [""]]];

private _zoneSaveData = if (!isNil "MWF_fnc_getZoneSaveData") then {
    [] call MWF_fnc_getZoneSaveData
} else {
    []
};

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 200]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _civRep = missionNamespace getVariable ["MWF_CivRep", 0];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _productionBonus = missionNamespace getVariable ["MWF_ProductionBonus", 0];
private _buildingMode = missionNamespace getVariable ["MWF_Locked_BuildingDamageMode", missionNamespace getVariable ["MWF_LockedBuildingMode", 0]];

private _boughtVehicles = [];
{
    if (!isNull _x && {alive _x} && {_x getVariable ["MWF_isBought", false]}) then {
        _boughtVehicles pushBack [
            typeOf _x,
            getPosASL _x,
            vectorDir _x,
            vectorUp _x,
            damage _x,
            fuel _x,
            _x getVariable ["MWF_isMobileRespawn", false]
        ];
    };
} forEach vehicles;

private _activeSideMissions = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);
private _mainOperationCooldowns = missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap];
private _campaignAnalytics = + (missionNamespace getVariable ["MWF_Campaign_Analytics", []]);

private _leaderContext = if (missionNamespace getVariable ["MWF_RebelLeaderEventActive", false]) then {
    + (missionNamespace getVariable ["MWF_RebelLeaderContext", []])
} else {
    []
};

private _attackState = missionNamespace getVariable ["MWF_FOBAttackState", ["idle"]];
private _savedAttackState = [];
if ((_attackState param [0, "idle"]) isEqualTo "active") then {
    private _remaining = ((_attackState param [4, -1]) - diag_tickTime) max 0;
    if (_remaining > 0) then {
        _savedAttackState = [
            "active",
            _attackState param [1, []],
            _attackState param [2, ""],
            _attackState param [3, ""],
            _remaining
        ];
    };
};

private _respawnState = missionNamespace getVariable ["MWF_RebelLeaderRespawnState", []];
private _savedRespawnState = [];
if ((_respawnState param [0, "idle"]) isEqualTo "pending") then {
    private _remaining = ((_respawnState param [4, -1]) - diag_tickTime) max 0;
    if (_remaining > 0) then {
        _savedRespawnState = [
            "pending",
            _respawnState param [1, []],
            _respawnState param [2, ""],
            _respawnState param [3, ""],
            _remaining
        ];
    };
};

private _damagedFOBs = [];
{
    _x params [
        ["_posASL", [], [[]]],
        ["_displayName", "", [""]],
        ["_marker", "", [""]],
        ["_deadline", -1, [0]],
        ["_repairCost", 0, [0]],
        ["_originType", "TRUCK", [""]]
    ];

    private _remaining = (_deadline - diag_tickTime) max 0;
    if (_remaining > 0) then {
        _damagedFOBs pushBack [_posASL, _displayName, _marker, _remaining, _repairCost, _originType];
    };
} forEach (missionNamespace getVariable ["MWF_DamagedFOBs", []]);

profileNamespace setVariable ["MWF_Save_HasCampaign", true];
profileNamespace setVariable ["MWF_Save_ZoneData", _zoneSaveData];
profileNamespace setVariable ["MWF_Save_CapturedZoneCount", missionNamespace getVariable ["MWF_CapturedZoneCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedTownCount", missionNamespace getVariable ["MWF_CapturedTownCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]];
profileNamespace setVariable ["MWF_Save_MapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]];
profileNamespace setVariable ["MWF_Save_WorldTier", missionNamespace getVariable ["MWF_WorldTier", 1]];
profileNamespace setVariable ["MWF_Save_WorldTierScore", missionNamespace getVariable ["MWF_WorldTierScore", 0]];
profileNamespace setVariable ["MWF_Save_WorldTierProgress", missionNamespace getVariable ["MWF_WorldTierProgress", 0]];
profileNamespace setVariable ["MWF_Save_WorldTierFloor", missionNamespace getVariable ["MWF_WorldTierFloor", 1]];
profileNamespace setVariable ["MWF_Save_WorldTierHalfMapLock", missionNamespace getVariable ["MWF_WorldTierHalfMapLock", false]];
profileNamespace setVariable ["MWF_Save_WorldTierProgressBlockedRemaining", ((missionNamespace getVariable ["MWF_WorldTierProgressBlockedUntil", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_WorldTierBlockImmuneRemaining", ((missionNamespace getVariable ["MWF_WorldTierBlockImmuneUntil", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_TierFreeze_Active", missionNamespace getVariable ["MWF_TierFreeze_Active", false]];
profileNamespace setVariable ["MWF_Save_TierFreeze_Remaining", ((missionNamespace getVariable ["MWF_TierFreeze_EndTime", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_GlobalThreatPercent", missionNamespace getVariable ["MWF_GlobalThreatPercent", 0]];
profileNamespace setVariable ["MWF_Save_MainOpThreatBlockedRemaining", ((missionNamespace getVariable ["MWF_MainOpThreatProgressBlockedUntil", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_ThreatHotZones", missionNamespace getVariable ["MWF_ThreatHotZones", []]];
profileNamespace setVariable ["MWF_Save_Supplies", _supplies];
profileNamespace setVariable ["MWF_Save_Intel", _intel];
profileNamespace setVariable ["MWF_Save_CivRep_State", _civRep];
profileNamespace setVariable ["MWF_Save_Notoriety_State", _notoriety];
profileNamespace setVariable ["MWF_Save_ProductionBonus", _productionBonus];
profileNamespace setVariable ["MWF_Save_RepPenalties", missionNamespace getVariable ["MWF_RepPenaltyCount", 0]];
profileNamespace setVariable ["MWF_Save_CivilianCasualties", missionNamespace getVariable ["MWF_CivilianCasualties", 0]];
profileNamespace setVariable ["MWF_Save_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []]];
profileNamespace setVariable ["MWF_Save_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]];
profileNamespace setVariable ["MWF_Save_Tier", missionNamespace getVariable ["MWF_CurrentTier", 1]];
profileNamespace setVariable ["MWF_Save_FixedInfra", missionNamespace getVariable ["MWF_FixedInfrastructure", []]];
profileNamespace setVariable ["MWF_Save_FOBs", missionNamespace getVariable ["MWF_FOB_Positions", []]];
profileNamespace setVariable ["MWF_Save_Missions", missionNamespace getVariable ["MWF_completedMissions", []]];
profileNamespace setVariable ["MWF_Save_BoughtVehicles", _boughtVehicles];
profileNamespace setVariable ["MWF_Save_ActiveSideMissions", _activeSideMissions];
profileNamespace setVariable ["MWF_Save_MainOperationCooldowns", _mainOperationCooldowns];
profileNamespace setVariable ["MWF_Save_Campaign_Phase", missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]];
profileNamespace setVariable ["MWF_Save_Tutorial_SupplyRunDone", missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false]];
profileNamespace setVariable ["MWF_Save_GrandOperationActive", missionNamespace getVariable ["MWF_GrandOperationActive", false]];
profileNamespace setVariable ["MWF_Save_CurrentGrandOperation", missionNamespace getVariable ["MWF_CurrentGrandOperation", ""]];
profileNamespace setVariable ["MWF_Save_CurrentGrandOperationTitle", missionNamespace getVariable ["MWF_CurrentGrandOperationTitle", ""]];
profileNamespace setVariable ["MWF_Save_CurrentGrandOperationPlacement", missionNamespace getVariable ["MWF_CurrentGrandOperationPlacement", []]];
profileNamespace setVariable ["MWF_Save_Unlock_Heli", missionNamespace getVariable ["MWF_Unlock_Heli", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Jets", missionNamespace getVariable ["MWF_Unlock_Jets", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Armor", missionNamespace getVariable ["MWF_Unlock_Armor", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Tier5", missionNamespace getVariable ["MWF_Unlock_Tier5", false]];
profileNamespace setVariable ["MWF_Save_Perk_HeliDiscount", missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1]];
profileNamespace setVariable ["MWF_Save_CampaignAnalytics", _campaignAnalytics];
profileNamespace setVariable ["MWF_Save_RebelLeaderContext", _leaderContext];
profileNamespace setVariable ["MWF_Save_RebelLeaderSettlementCount", missionNamespace getVariable ["MWF_RebelLeaderSettlementCount", 0]];
profileNamespace setVariable ["MWF_Save_FOBAttackState", _savedAttackState];
profileNamespace setVariable ["MWF_Save_RebelLeaderRespawnState", _savedRespawnState];
profileNamespace setVariable ["MWF_Save_DamagedFOBs", _damagedFOBs];

profileNamespace setVariable ["MWF_Save_StartSupplies", missionNamespace getVariable ["MWF_Locked_StartSupplies", 200]];
profileNamespace setVariable ["MWF_Save_SupplyTimer", missionNamespace getVariable ["MWF_Locked_SupplyTimer", 10]];
profileNamespace setVariable ["MWF_Save_CivReputation", missionNamespace getVariable ["MWF_Locked_CivReputation", 0]];
profileNamespace setVariable ["MWF_Save_NotorietyMultiplier", missionNamespace getVariable ["MWF_Locked_NotorietyMultiplier", 1]];
profileNamespace setVariable ["MWF_Save_BuildingMode", _buildingMode];
profileNamespace setVariable ["MWF_Save_IncomeMultiplier", missionNamespace getVariable ["MWF_Locked_IncomeMultiplier", 1]];
profileNamespace setVariable ["MWF_Save_MaxFOBs", missionNamespace getVariable ["MWF_Locked_MaxFOBs", 5]];
profileNamespace setVariable ["MWF_Save_CompositionType", missionNamespace getVariable ["MWF_Locked_CompositionTypeChoice", 0]];

{
    private _prefix = _x;
    profileNamespace setVariable [format ["MWF_Save_%1Source", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Source", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1Choice", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Choice", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1ResolvedChoice", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1ResolvedChoice", _prefix], 0]];
    profileNamespace setVariable [format ["MWF_Save_%1Label", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1Label", _prefix], ""]];
    profileNamespace setVariable [format ["MWF_Save_%1File", _prefix], missionNamespace getVariable [format ["MWF_Locked_%1File", _prefix], ""]];
} forEach ["Blufor", "Opfor", "Resistance", "Civs"];

private _zoneCount = count _zoneSaveData;
private _vehicleCount = count _boughtVehicles;
private _missionCount = count _activeSideMissions;
private _estimatedTotalBytes = (count toArray str _zoneSaveData) + (count toArray str _boughtVehicles) + (count toArray str _activeSideMissions) + (count toArray str _damagedFOBs) + (count toArray str _leaderContext);

saveProfileNamespace;

diag_log format [
    "[MWF] Game saved (%1). Phase: %2 | Zones: %3 | Vehicles: %4 | Missions: %5 | Leader Active: %6 | Damaged FOBs: %7 | Est. Payload: ~%8KB.",
    _reason,
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    _zoneCount,
    _vehicleCount,
    _missionCount,
    !(_leaderContext isEqualTo []),
    count _damagedFOBs,
    round (_estimatedTotalBytes / 1024)
];
