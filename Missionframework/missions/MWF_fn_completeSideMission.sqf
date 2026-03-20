/*
    Author: Theane / ChatGPT
    Function: fn_completeSideMission
    Project: Military War Framework

    Description:
    Authoritative helper to finish a generated side mission, apply per-mission
    fixed rewards/impact from the active mission definition when available,
    and update the active mission registry.

    Parameters:
    0: missionKey <STRING>
    1: wasUndercover <BOOL>
    2: note <STRING>
*/

if (!isServer) exitWith {false};

params [
    ["_missionKey", "", [""]],
    ["_wasUndercover", false, [false]],
    ["_note", "", [""]]
];

if (_missionKey isEqualTo "") exitWith {false};

private _activeMissions = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);
private _missionIndex = _activeMissions findIf { (_x # 0) isEqualTo _missionKey };
if (_missionIndex < 0) exitWith {false};

private _mission = + (_activeMissions # _missionIndex);
_mission params [
    ["_resolvedMissionKey", "", [""]],
    ["_slotIndex", -1, [0]],
    ["_taskId", "", [""]],
    ["_startedAt", 0, [0]],
    ["_position", [0,0,0], [[]]],
    ["_zoneId", "", [""]],
    ["_zoneName", "Unknown Area", [""]],
    ["_category", "disrupt", [""]],
    ["_difficulty", "easy", [""]],
    ["_missionId", 0, [0]],
    ["_state", "active", [""]],
    ["_missionDefinition", [], [[]]],
    ["_domain", "land", [""]]
];

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    if !(_definition isEqualType []) exitWith {_default};
    private _index = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };
    if (_index < 0) exitWith { _default };
    (_definition # _index) # 1
};

private _usedPerMissionDefinition = false;
private _suppliesReward = 0;
private _intelAward = 0;
private _appliedThreat = 0;
private _appliedTier = 0;
private _fallbackUsed = false;

if (_missionDefinition isEqualType [] && {count _missionDefinition > 0} && {!isNil "MWF_fnc_applyMissionImpact"}) then {
    private _rewardSupplies = [_missionDefinition, "rewardSupplies", -1] call _getDefinitionValue;
    private _rewardIntel = [_missionDefinition, "rewardIntel", -1] call _getDefinitionValue;
    private _rewardThreat = [_missionDefinition, "rewardThreat", 0] call _getDefinitionValue;
    private _rewardTier = [_missionDefinition, "rewardTier", 0] call _getDefinitionValue;
    private _rewardThreatUndercover = [_missionDefinition, "rewardThreatUndercover", 0] call _getDefinitionValue;
    private _fallbackSupplies = [_missionDefinition, "fallbackSupplies", 0] call _getDefinitionValue;
    private _fallbackIntel = [_missionDefinition, "fallbackIntel", 0] call _getDefinitionValue;

    if (_rewardSupplies >= 0 && {_rewardIntel >= 0}) then {
        private _profile = createHashMapFromArray [
            ["kind", "side"],
            ["id", _resolvedMissionKey],
            ["supplies", _rewardSupplies],
            ["intel", _rewardIntel],
            ["threatDelta", if (_wasUndercover) then {_rewardThreatUndercover} else {_rewardThreat}],
            ["tierDelta", _rewardTier],
            ["fallbackSupplies", _fallbackSupplies],
            ["fallbackIntel", _fallbackIntel],
            ["note", _note]
        ];

        private _result = [_profile, createHashMapFromArray [
            ["zoneId", _zoneId],
            ["loud", !_wasUndercover]
        ]] call MWF_fnc_applyMissionImpact;

        _suppliesReward = _result getOrDefault ["suppliesGranted", _rewardSupplies];
        _intelAward = _result getOrDefault ["intelGranted", _rewardIntel];
        _appliedThreat = _result getOrDefault ["threatApplied", 0];
        _appliedTier = _result getOrDefault ["tierApplied", 0];
        _fallbackUsed = _result getOrDefault ["fallbackUsed", false];
        _usedPerMissionDefinition = true;
    };
};

if (!_usedPerMissionDefinition) then {
    private _profile = [_category, _difficulty] call MWF_fnc_getSideMissionRewardProfile;
    _profile params ["_legacySuppliesReward", "_legacyIntelReward", "_legacyThreatSeverity", "_legacyBonusIntelIfUndercover"];

    _suppliesReward = _legacySuppliesReward;
    _intelAward = _legacyIntelReward;

    if (_wasUndercover) then {
        _intelAward = _intelAward + _legacyBonusIntelIfUndercover;
    } else {
        _appliedThreat = _legacyThreatSeverity;
        ["side_mission_loud", _zoneId, _legacyThreatSeverity, _resolvedMissionKey] call MWF_fnc_registerThreatIncident;
    };

    if (_suppliesReward > 0) then { [_suppliesReward, "SUPPLIES"] call MWF_fnc_addResource; };
    if (_intelAward > 0) then { [_intelAward, "INTEL"] call MWF_fnc_addResource; };
};

if (_taskId != "") then {
    [_taskId, "SUCCEEDED", true] call BIS_fnc_taskSetState;
};

_activeMissions deleteAt _missionIndex;
missionNamespace setVariable ["MWF_ActiveSideMissions", _activeMissions, true];
if (!isNil "MWF_fnc_sideMissionRuntime") then {
    ["CLEANUP", _resolvedMissionKey] call MWF_fnc_sideMissionRuntime;
};

private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
private _slotEntryIndex = _boardSlots findIf { (_x # 4) isEqualTo _resolvedMissionKey };
if (_slotEntryIndex >= 0) then {
    private _slotData = + (_boardSlots # _slotEntryIndex);
    _slotData set [9, "completed"];
    _boardSlots set [_slotEntryIndex, _slotData];
    missionNamespace setVariable ["MWF_MissionBoardSlots", _boardSlots, true];
};

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

diag_log format [
    "[MWF Missions] Side mission completed | Key: %1 | Domain: %2 | Category: %3 | Difficulty: %4 | Supplies: +%5 | Intel: +%6 | ThreatApplied: %7 | TierApplied: %8 | Undercover: %9 | PerMissionDefinition: %10 | FallbackUsed: %11 | Note: %12",
    _resolvedMissionKey,
    _domain,
    _category,
    _difficulty,
    _suppliesReward,
    _intelAward,
    _appliedThreat,
    _appliedTier,
    _wasUndercover,
    _usedPerMissionDefinition,
    _fallbackUsed,
    _note
];

true
