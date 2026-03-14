/*
    Author: Theane / ChatGPT
    Function: fn_loadGame
    Project: Military War Framework

    Description:
    Restores strategic campaign state and stages saved zone data for the zone manager to apply after registry creation.
*/

if (!isServer) exitWith {};

private _supplies = profileNamespace getVariable ["MWF_Save_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 200]];
private _intel = profileNamespace getVariable ["MWF_Save_Intel", missionNamespace getVariable ["MWF_res_intel", 0]];
private _civRep = profileNamespace getVariable ["MWF_Save_CivRep", missionNamespace getVariable ["MWF_CivRep", 0]];
private _notoriety = profileNamespace getVariable ["MWF_Save_Notoriety", missionNamespace getVariable ["MWF_res_notoriety", 0]];

missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_res_intel", _intel, true];
missionNamespace setVariable ["MWF_CivRep", _civRep, true];
missionNamespace setVariable ["MWF_res_notoriety", _notoriety, true];
missionNamespace setVariable ["MWF_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_Intel", _intel, true];
missionNamespace setVariable ["MWF_RepPenaltyCount", profileNamespace getVariable ["MWF_Save_RepPenalties", 0], true];
missionNamespace setVariable ["MWF_DestroyedHQs", profileNamespace getVariable ["MWF_Save_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", profileNamespace getVariable ["MWF_Save_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", profileNamespace getVariable ["MWF_Save_FOBs", []], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", profileNamespace getVariable ["MWF_Save_FixedInfra", []], true];
missionNamespace setVariable ["MWF_completedMissions", profileNamespace getVariable ["MWF_Save_Missions", []], true];
missionNamespace setVariable ["MWF_CurrentTier", profileNamespace getVariable ["MWF_Save_Tier", 1], true];
missionNamespace setVariable ["MWF_CapturedZoneCount", profileNamespace getVariable ["MWF_Save_CapturedZoneCount", 0], true];
missionNamespace setVariable ["MWF_CapturedTownCount", profileNamespace getVariable ["MWF_Save_CapturedTownCount", 0], true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", profileNamespace getVariable ["MWF_Save_CapturedCapitalCount", 0], true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", profileNamespace getVariable ["MWF_Save_CapturedFactoryCount", 0], true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", profileNamespace getVariable ["MWF_Save_CapturedMilitaryCount", 0], true];
missionNamespace setVariable ["MWF_MapControlPercent", profileNamespace getVariable ["MWF_Save_MapControlPercent", 0], true];
missionNamespace setVariable ["MWF_LoadedZoneSaveData", profileNamespace getVariable ["MWF_Save_ZoneData", []], true];

private _savedBuildingMode = profileNamespace getVariable ["MWF_Save_BuildingMode", -1];
if (_savedBuildingMode == -1) then {
    missionNamespace setVariable ["MWF_LockedBuildingMode", ["MWF_Param_BuildingDamageMode", 0] call BIS_fnc_getParamValue, true];
} else {
    missionNamespace setVariable ["MWF_LockedBuildingMode", _savedBuildingMode, true];
};

diag_log format ["[MWF] Campaign state restored. Pending saved zones: %1.", count (missionNamespace getVariable ["MWF_LoadedZoneSaveData", []])];
