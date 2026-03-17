/*
    Author: Theane / ChatGPT
    Function: fn_loadGame
    Project: Military War Framework

    Description:
    Restores strategic campaign state and all campaign-persistent lobby params.
    The locked values are initialized from lobby params on a fresh campaign and then
    persisted immediately so server restarts cannot drift them.

    Cleanup hardening:
    - Clamp key economy values into sane ranges during load
    - Clamp locked params into defensive ranges
    - Keep pending restore arrays intact for later restore passes
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
    diag_log "[MWF Persistence] syncEconomyState unavailable during loadGame. Applied direct economy fallback state.";
};

missionNamespace setVariable ["MWF_CivRep", _civRepState, true];
missionNamespace setVariable ["MWF_RepPenaltyCount", [profileNamespace getVariable ["MWF_Save_RepPenalties", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_DestroyedHQs", profileNamespace getVariable ["MWF_Save_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", profileNamespace getVariable ["MWF_Save_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", profileNamespace getVariable ["MWF_Save_FOBs", []], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", profileNamespace getVariable ["MWF_Save_FixedInfra", []], true];
missionNamespace setVariable ["MWF_completedMissions", profileNamespace getVariable ["MWF_Save_Missions", []], true];
missionNamespace setVariable ["MWF_CurrentTier", [profileNamespace getVariable ["MWF_Save_Tier", 1], 1, 10, 1] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedZoneCount", [profileNamespace getVariable ["MWF_Save_CapturedZoneCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedTownCount", [profileNamespace getVariable ["MWF_Save_CapturedTownCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", [profileNamespace getVariable ["MWF_Save_CapturedCapitalCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", [profileNamespace getVariable ["MWF_Save_CapturedFactoryCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", [profileNamespace getVariable ["MWF_Save_CapturedMilitaryCount", 0], 0, 100000, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_MapControlPercent", [profileNamespace getVariable ["MWF_Save_MapControlPercent", 0], 0, 100, 0] call _clampNumber, true];
missionNamespace setVariable ["MWF_LoadedZoneSaveData", profileNamespace getVariable ["MWF_Save_ZoneData", []], true];
missionNamespace setVariable ["MWF_PendingBoughtVehicles", profileNamespace getVariable ["MWF_Save_BoughtVehicles", []], true];
missionNamespace setVariable ["MWF_PendingActiveSideMissions", profileNamespace getVariable ["MWF_Save_ActiveSideMissions", []], true];
missionNamespace setVariable ["MWF_SessionVehiclesRestored", false, true];
missionNamespace setVariable ["MWF_PendingActiveSideMissionsRestored", false, true];

profileNamespace setVariable ["MWF_Save_HasCampaign", true];
saveProfileNamespace;

diag_log format ["[MWF] Campaign state restored. Pending saved zones: %1 | Pending vehicles: %2 | Pending active missions: %3 | Existing campaign save: %4.", count (missionNamespace getVariable ["MWF_LoadedZoneSaveData", []]), count (missionNamespace getVariable ["MWF_PendingBoughtVehicles", []]), count (missionNamespace getVariable ["MWF_PendingActiveSideMissions", []]), _hasCampaignSave];
