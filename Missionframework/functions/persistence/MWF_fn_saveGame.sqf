/*
    Author: Theane / ChatGPT
    Function: fn_saveGame
    Project: Military War Framework

    Description:
    Saves strategic campaign state, normalized zone progression data, and all campaign-persistent
    lobby params / faction selections.
    Also persists the global campaign phase used for tutorial bypass.
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
private _productionBonus = missionNamespace getVariable ["MWF_ProductionBonus", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
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

profileNamespace setVariable ["MWF_Save_HasCampaign", true];
profileNamespace setVariable ["MWF_Save_ZoneData", _zoneSaveData];
profileNamespace setVariable ["MWF_Save_CapturedZoneCount", missionNamespace getVariable ["MWF_CapturedZoneCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedTownCount", missionNamespace getVariable ["MWF_CapturedTownCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]];
profileNamespace setVariable ["MWF_Save_MapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]];
profileNamespace setVariable ["MWF_Save_Supplies", _supplies];
profileNamespace setVariable ["MWF_Save_Intel", _intel];
profileNamespace setVariable ["MWF_Save_CivRep_State", _civRep];
profileNamespace setVariable ["MWF_Save_Notoriety_State", _notoriety];
profileNamespace setVariable ["MWF_Save_ProductionBonus", _productionBonus];
profileNamespace setVariable ["MWF_Save_RepPenalties", missionNamespace getVariable ["MWF_RepPenaltyCount", 0]];
profileNamespace setVariable ["MWF_Save_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []]];
profileNamespace setVariable ["MWF_Save_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]];
profileNamespace setVariable ["MWF_Save_Tier", missionNamespace getVariable ["MWF_CurrentTier", 1]];
profileNamespace setVariable ["MWF_Save_FixedInfra", missionNamespace getVariable ["MWF_FixedInfrastructure", []]];
profileNamespace setVariable ["MWF_Save_FOBs", missionNamespace getVariable ["MWF_FOB_Positions", []]];
profileNamespace setVariable ["MWF_Save_Missions", missionNamespace getVariable ["MWF_completedMissions", []]];
profileNamespace setVariable ["MWF_Save_BoughtVehicles", _boughtVehicles];
profileNamespace setVariable ["MWF_Save_ActiveSideMissions", _activeSideMissions];
profileNamespace setVariable ["MWF_Save_Campaign_Phase", missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]];
profileNamespace setVariable ["MWF_Save_Tutorial_SupplyRunDone", missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false]];

/* Persistent lobby params */
profileNamespace setVariable ["MWF_Save_StartSupplies", missionNamespace getVariable ["MWF_Locked_StartSupplies", 200]];
profileNamespace setVariable ["MWF_Save_SupplyTimer", missionNamespace getVariable ["MWF_Locked_SupplyTimer", 10]];
profileNamespace setVariable ["MWF_Save_CivReputation", missionNamespace getVariable ["MWF_Locked_CivReputation", 0]];
profileNamespace setVariable ["MWF_Save_NotorietyMultiplier", missionNamespace getVariable ["MWF_Locked_NotorietyMultiplier", 1]];
profileNamespace setVariable ["MWF_Save_BuildingMode", _buildingMode];
profileNamespace setVariable ["MWF_Save_IncomeMultiplier", missionNamespace getVariable ["MWF_Locked_IncomeMultiplier", 1]];
profileNamespace setVariable ["MWF_Save_MaxFOBs", missionNamespace getVariable ["MWF_Locked_MaxFOBs", 5]];

/* Faction locks */
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

private _zoneBytes = count toArray str _zoneSaveData;
private _vehicleBytes = count toArray str _boughtVehicles;
private _missionBytes = count toArray str _activeSideMissions;
private _estimatedTotalBytes = _zoneBytes + _vehicleBytes + _missionBytes;

saveProfileNamespace;

diag_log format [
    "[MWF] Game saved (%1). Phase: %2 | Zones: %3 (~%4KB) | Vehicles: %5 (~%6KB) | Active Missions: %7 (~%8KB) | Est. Payload: ~%9KB.",
    _reason,
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    _zoneCount,
    round (_zoneBytes / 1024),
    _vehicleCount,
    round (_vehicleBytes / 1024),
    _missionCount,
    round (_missionBytes / 1024),
    round (_estimatedTotalBytes / 1024)
];

if (_estimatedTotalBytes > 1000000) then {
    diag_log format ["[MWF Save] WARNING: Estimated save payload exceeds 1MB (~%1KB).", round (_estimatedTotalBytes / 1024)];
};
