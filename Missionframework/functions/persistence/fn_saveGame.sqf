/*
    Author: Theane / ChatGPT
    Function: fn_saveGame
    Project: Military War Framework

    Description:
    Saves strategic campaign state with normalized zone progression data.
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

profileNamespace setVariable ["MWF_Save_ZoneData", _zoneSaveData];
profileNamespace setVariable ["MWF_Save_CapturedZoneCount", missionNamespace getVariable ["MWF_CapturedZoneCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedTownCount", missionNamespace getVariable ["MWF_CapturedTownCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedCapitalCount", missionNamespace getVariable ["MWF_CapturedCapitalCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedFactoryCount", missionNamespace getVariable ["MWF_CapturedFactoryCount", 0]];
profileNamespace setVariable ["MWF_Save_CapturedMilitaryCount", missionNamespace getVariable ["MWF_CapturedMilitaryCount", 0]];
profileNamespace setVariable ["MWF_Save_MapControlPercent", missionNamespace getVariable ["MWF_MapControlPercent", 0]];
profileNamespace setVariable ["MWF_Save_Supplies", _supplies];
profileNamespace setVariable ["MWF_Save_Intel", _intel];
profileNamespace setVariable ["MWF_Save_CivRep", _civRep];
profileNamespace setVariable ["MWF_Save_Notoriety", _notoriety];
profileNamespace setVariable ["MWF_Save_RepPenalties", missionNamespace getVariable ["MWF_RepPenaltyCount", 0]];
profileNamespace setVariable ["MWF_Save_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []]];
profileNamespace setVariable ["MWF_Save_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]];
profileNamespace setVariable ["MWF_Save_Tier", missionNamespace getVariable ["MWF_CurrentTier", 1]];
profileNamespace setVariable ["MWF_Save_FixedInfra", missionNamespace getVariable ["MWF_FixedInfrastructure", []]];
profileNamespace setVariable ["MWF_Save_FOBs", missionNamespace getVariable ["MWF_FOB_Positions", []]];
profileNamespace setVariable ["MWF_Save_BuildingMode", missionNamespace getVariable ["MWF_LockedBuildingMode", -1]];
profileNamespace setVariable ["MWF_Save_Missions", missionNamespace getVariable ["MWF_completedMissions", []]];

saveProfileNamespace;

diag_log format ["[MWF] Game saved (%1). Zones saved: %2.", _reason, count _zoneSaveData];
