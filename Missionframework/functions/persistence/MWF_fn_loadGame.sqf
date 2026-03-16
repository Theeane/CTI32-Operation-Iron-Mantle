/*
    Author: Theane / ChatGPT
    Function: fn_loadGame
    Project: Military War Framework

    Description:
    Restores strategic campaign state and all campaign-persistent lobby params.
    The locked values are initialized from lobby params on a fresh campaign and then
    persisted immediately so server restarts cannot drift them.
*/

if (!isServer) exitWith {};

private _hasCampaignSave = profileNamespace getVariable ["MWF_Save_HasCampaign", false];
missionNamespace setVariable ["MWF_HasCampaignSave", _hasCampaignSave, true];

private _getPersistentValue = {
    params ["_saveKey", "_paramName", "_defaultValue", "_missionVar"];

    private _value = if (_hasCampaignSave) then {
        profileNamespace getVariable [_saveKey, _defaultValue]
    } else {
        [_paramName, _defaultValue] call BIS_fnc_getParamValue
    };

    missionNamespace setVariable [_missionVar, _value, true];
    profileNamespace setVariable [_saveKey, _value];

    _value
};

private _lockedStartSupplies = ["MWF_Save_StartSupplies", "MWF_Param_StartSupplies", 200, "MWF_Locked_StartSupplies"] call _getPersistentValue;
private _lockedSupplyTimer = ["MWF_Save_SupplyTimer", "MWF_Param_SupplyTimer", 10, "MWF_Locked_SupplyTimer"] call _getPersistentValue;
private _lockedCivRep = ["MWF_Save_CivReputation", "MWF_Param_CivReputation", 0, "MWF_Locked_CivReputation"] call _getPersistentValue;
private _lockedNotorietyMult = ["MWF_Save_NotorietyMultiplier", "MWF_Param_NotorietyMultiplier", 1, "MWF_Locked_NotorietyMultiplier"] call _getPersistentValue;
private _lockedBuildingMode = ["MWF_Save_BuildingMode", "MWF_Param_BuildingDamageMode", 0, "MWF_Locked_BuildingDamageMode"] call _getPersistentValue;
private _lockedIncomeMultiplier = ["MWF_Save_IncomeMultiplier", "MWF_Param_IncomeMultiplier", 1, "MWF_Locked_IncomeMultiplier"] call _getPersistentValue;
private _lockedMaxFOBs = ["MWF_Save_MaxFOBs", "MWF_Param_MaxFOBs", 5, "MWF_Locked_MaxFOBs"] call _getPersistentValue;

/* Backward-compatible alias used by existing systems */
missionNamespace setVariable ["MWF_LockedBuildingMode", _lockedBuildingMode, true];
missionNamespace setVariable ["MWF_Param_MaxFOBs", _lockedMaxFOBs, true];
missionNamespace setVariable ["MWF_Param_IncomeMultiplier", _lockedIncomeMultiplier, true];

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

    if (_choice == -9999) then {
        _choice = if (_source == 0) then {
            [_defaultParam, _defaultChoice] call BIS_fnc_getParamValue
        } else {
            [_customParam, 1] call BIS_fnc_getParamValue
        };
    };

    missionNamespace setVariable [format ["MWF_Locked_%1Source", _prefix], _source, true];
    missionNamespace setVariable [format ["MWF_Locked_%1Choice", _prefix], _choice, true];

    profileNamespace setVariable [format ["MWF_Save_%1Source", _prefix], _source];
    profileNamespace setVariable [format ["MWF_Save_%1Choice", _prefix], _choice];
};

["Blufor", "MWF_Param_BluforSource", "MWF_Param_Blufor", "MWF_Param_CustomBlufor", 0] call _loadFactionLock;
["Opfor", "MWF_Param_OpforSource", "MWF_Param_Opfor", "MWF_Param_CustomOpfor", 0] call _loadFactionLock;
["Resistance", "MWF_Param_ResistanceSource", "MWF_Param_Resistance", "MWF_Param_CustomResistance", 0] call _loadFactionLock;
["Civs", "MWF_Param_CivsSource", "MWF_Param_Civs", "MWF_Param_CustomCivs", 0] call _loadFactionLock;

private _supplies = profileNamespace getVariable ["MWF_Save_Supplies", _lockedStartSupplies];
private _intel = profileNamespace getVariable ["MWF_Save_Intel", 0];
private _civRepState = profileNamespace getVariable ["MWF_Save_CivRep_State", _lockedCivRep];
private _notoriety = profileNamespace getVariable ["MWF_Save_Notoriety_State", 0];

[_supplies, _intel, _notoriety, true, false] call MWF_fnc_syncEconomyState;
missionNamespace setVariable ["MWF_CivRep", _civRepState, true];
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

profileNamespace setVariable ["MWF_Save_HasCampaign", true];
saveProfileNamespace;

diag_log format ["[MWF] Campaign state restored. Pending saved zones: %1. Existing campaign save: %2.", count (missionNamespace getVariable ["MWF_LoadedZoneSaveData", []]), _hasCampaignSave];
