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

if (missionNamespace getVariable ["MWF_DebugMode", false]) exitWith {
    diag_log format ["[MWF] Save skipped in debug mode (%1).", _reason];
};

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

private _activeSideMissions = [];

private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mainBasePos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
private _mobLabel = missionNamespace getVariable ["MWF_MOB_Name", "MOB"];
private _builtRegistry = + (missionNamespace getVariable ["MWF_BuiltUpgradeRegistry", []]);
private _builtUpgradeStructures = [];
private _cleanBuiltRegistry = [];
private _pushBuiltUpgradeRecord = {
    params [
        ["_upgradeId", "", [""]],
        ["_obj", objNull, [objNull]],
        ["_className", "", [""]],
        ["_baseKey", "", [""]],
        ["_baseType", "", [""]],
        ["_baseLabel", "", [""]]
    ];

    if (isNull _obj) exitWith {};

    if (_upgradeId isEqualTo "") then {
        _upgradeId = toUpper (_obj getVariable ["MWF_UpgradeId", ""]);
    } else {
        _upgradeId = toUpper _upgradeId;
    };

    if (_className isEqualTo "") then {
        _className = typeOf _obj;
    };

    if (_baseKey isEqualTo "") then {
        _baseKey = _obj getVariable ["MWF_BaseKey", "MOB"];
    };

    if (_baseType isEqualTo "") then {
        _baseType = _obj getVariable ["MWF_BaseType", if ((_baseKey find "FOB:") isEqualTo 0) then {"FOB"} else {"MOB"}];
    };

    if (_baseLabel isEqualTo "") then {
        _baseLabel = _obj getVariable [
            "MWF_BaseLabel",
            if (_baseType isEqualTo "FOB" && {(_baseKey find "FOB:") isEqualTo 0}) then {
                _baseKey select [4]
            } else {
                _mobLabel
            }
        ];
    };

    if (_upgradeId isEqualTo "" || {_className isEqualTo ""}) exitWith {};

    private _posASL = getPosASL _obj;
    private _existingIndex = _builtUpgradeStructures findIf {
        ((_x param [0, ""]) isEqualTo _upgradeId) &&
        {((_x param [6, ""]) isEqualTo _baseKey)} &&
        {((_x param [2, [0, 0, 0], [[]]]) distance _posASL) <= 1.5}
    };
    if (_existingIndex >= 0) exitWith {};

    _cleanBuiltRegistry pushBack [_upgradeId, _obj, _className, _baseKey, _baseType, _baseLabel];
    _builtUpgradeStructures pushBack [
        _upgradeId,
        _className,
        _posASL,
        vectorDir _obj,
        vectorUp _obj,
        damage _obj,
        _baseKey,
        _baseType,
        _baseLabel
    ];
};

{
    _x params [
        ["_upgradeId", "", [""]],
        ["_obj", objNull, [objNull]],
        ["_className", "", [""]],
        ["_baseKey", "", [""]],
        ["_baseType", "", [""]],
        ["_baseLabel", "", [""]]
    ];
    [_upgradeId, _obj, _className, _baseKey, _baseType, _baseLabel] call _pushBuiltUpgradeRecord;
} forEach _builtRegistry;

{
    private _garageObj = _x param [0, objNull];
    private _garageKey = _x param [1, "MOB", [""]];
    private _garageLabel = _x param [2, if (_garageKey isEqualTo "MOB") then {_mobLabel} else {"Garage"}, [""]];
    private _garageType = _x param [3, if ((_garageKey find "FOB:") isEqualTo 0) then {"FOB"} else {"MOB"}, [""]];
    ["GARAGE", _garageObj, typeOf _garageObj, _garageKey, _garageType, _garageLabel] call _pushBuiltUpgradeRecord;
} forEach (missionNamespace getVariable ["MWF_GarageRegistry", []]);

{
    _x params ["_upgradeId", "_structureClass"];
    if (_structureClass isNotEqualTo "") then {
        private _matches = nearestObjects [_mainBasePos, [_structureClass], 120];
        if !(_matches isEqualTo []) then {
            [_upgradeId, _matches # 0, _structureClass, "MOB", "MOB", _mobLabel] call _pushBuiltUpgradeRecord;
        };
    };
} forEach [
    ["HELI", missionNamespace getVariable ["MWF_Heli_Tower_Class", ""]],
    ["JET", missionNamespace getVariable ["MWF_Jet_Control_Class", ""]]
];

missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", _cleanBuiltRegistry, true];

private _blockRebelLeaderPersistence =
    (missionNamespace getVariable ["MWF_EndgameActive", false]) ||
    (missionNamespace getVariable ["MWF_EndgameCompleted", false]);

private _leaderContext = if (
    (missionNamespace getVariable ["MWF_RebelLeaderEventActive", false]) &&
    {!_blockRebelLeaderPersistence}
) then {
    + (missionNamespace getVariable ["MWF_RebelLeaderContext", []])
} else {
    []
};

private _attackState = missionNamespace getVariable ["MWF_FOBAttackState", ["idle"]];
private _savedAttackState = [];
if !(_blockRebelLeaderPersistence) then {
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
};

private _respawnState = missionNamespace getVariable ["MWF_RebelLeaderRespawnState", []];
private _savedLeaderRespawnState = [];
if !(_blockRebelLeaderPersistence) then {
    if ((_respawnState param [0, ""]) isEqualTo "pending") then {
        private _remaining = ((_respawnState param [4, -1]) - diag_tickTime) max 0;
        if (_remaining > 0) then {
            _savedLeaderRespawnState = [
                "pending",
                _respawnState param [1, []],
                _respawnState param [2, ""],
                _respawnState param [3, ""],
                _remaining
            ];
        };
    };
};

private _mainOperationState = [];
private _revealedInfrastructureIds = + (missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
private _infrastructureRegistry = + (missionNamespace getVariable ["MWF_InfrastructureRegistry", []]);
private _destroyedHQs = + (missionNamespace getVariable ["MWF_DestroyedHQs", []]);
private _destroyedRoadblocks = + (missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]);
private _revealedInfrastructureSites = [];
{
    if (_x isEqualType [] && {count _x >= 4}) then {
        _x params [
            ["_infraId", "", [""]],
            ["_infraType", "ROADBLOCK", [""]],
            ["_object", objNull, [objNull]],
            ["_storedPos", [0, 0, 0], [[]]]
        ];

        if (_infraId in _revealedInfrastructureIds) then {
            private _normalizedType = toUpper _infraType;
            private _pos = if (!isNull _object) then { getPosATL _object } else { +_storedPos };
            private _destroyedRegistry = if (_normalizedType isEqualTo "HQ") then { _destroyedHQs } else { _destroyedRoadblocks };

            if (
                (_normalizedType in ["HQ", "ROADBLOCK"]) &&
                {_pos isEqualType []} &&
                {(count _pos) >= 2} &&
                {(_destroyedRegistry findIf { _x distance2D _pos < 35 }) < 0}
            ) then {
                private _existingIndex = _revealedInfrastructureSites findIf {
                    ((_x param [0, ""]) isEqualTo _infraId) ||
                    (((_x param [1, ""]) isEqualTo _normalizedType) && {((_x param [2, [0, 0, 0], [[]]]) distance2D _pos) < 35})
                };
                if (_existingIndex < 0) then {
                    _revealedInfrastructureSites pushBack [_infraId, _normalizedType, _pos];
                };
            };
        };
    };
} forEach _infrastructureRegistry;

private _damagedFOBs = [];
if !(_blockRebelLeaderPersistence) then {
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
};

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
profileNamespace setVariable ["MWF_Save_TierFreeze_Active", missionNamespace getVariable ["MWF_TierFreeze_Active", false]];
profileNamespace setVariable ["MWF_Save_TierFreeze_Remaining", ((missionNamespace getVariable ["MWF_TierFreeze_EndTime", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_GlobalThreatPercent", missionNamespace getVariable ["MWF_GlobalThreatPercent", 0]];
profileNamespace setVariable ["MWF_Save_MainOpThreatBlockedRemaining", ((missionNamespace getVariable ["MWF_MainOpThreatProgressBlockedUntil", 0]) - serverTime) max 0];
profileNamespace setVariable ["MWF_Save_WorldTierBlockImmuneRemaining", ((missionNamespace getVariable ["MWF_WorldTierBlockImmuneUntil", 0]) - serverTime) max 0];
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
profileNamespace setVariable ["MWF_Save_FixedInfra", []];
profileNamespace setVariable ["MWF_Save_PotentialBaseSites", []];
profileNamespace setVariable ["MWF_Save_FreeMainOpCharges", missionNamespace getVariable ["MWF_FreeMainOpCharges", 0]];
profileNamespace setVariable ["MWF_Save_RevealedInfrastructureIDs", missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]];
profileNamespace setVariable ["MWF_Save_RevealedInfrastructureSites", _revealedInfrastructureSites];
profileNamespace setVariable ["MWF_Save_FOBs", missionNamespace getVariable ["MWF_FOB_Positions", []]];
profileNamespace setVariable ["MWF_Save_Missions", missionNamespace getVariable ["MWF_completedMissions", []]];
profileNamespace setVariable ["MWF_Save_BoughtVehicles", _boughtVehicles];
profileNamespace setVariable ["MWF_Save_GarageStoredVehicles", + (missionNamespace getVariable ["MWF_GarageStoredVehicles", []])];
profileNamespace setVariable ["MWF_Save_BuiltUpgradeStructures", _builtUpgradeStructures];
private _endgameCompleted = missionNamespace getVariable ["MWF_EndgameCompleted", false];
profileNamespace setVariable ["MWF_Save_EndgameActive", false];
profileNamespace setVariable ["MWF_Save_EndgameCompleted", _endgameCompleted];
profileNamespace setVariable ["MWF_Save_EndgameOutcome", missionNamespace getVariable ["MWF_EndgameOutcome", ""]];
profileNamespace setVariable ["MWF_Save_EndgameReservedZoneId", ""];
profileNamespace setVariable ["MWF_Save_EndgameState", []];
profileNamespace setVariable ["MWF_Save_ActiveSideMissions", []];
profileNamespace setVariable ["MWF_Save_Campaign_Phase", missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]];
profileNamespace setVariable ["MWF_Save_Tutorial_SupplyRunDone", missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false]];
profileNamespace setVariable ["MWF_Save_RebelLeaderContext", _leaderContext];
profileNamespace setVariable ["MWF_Save_RebelLeaderSettlementCount", missionNamespace getVariable ["MWF_RebelLeaderSettlementCount", 0]];
profileNamespace setVariable ["MWF_Save_FOBAttackState", _savedAttackState];
profileNamespace setVariable ["MWF_Save_RebelLeaderRespawnState", _savedLeaderRespawnState];
profileNamespace setVariable ["MWF_Save_DamagedFOBs", _damagedFOBs];
profileNamespace setVariable ["MWF_Save_Unlock_Heli", missionNamespace getVariable ["MWF_Unlock_Heli", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Jets", missionNamespace getVariable ["MWF_Unlock_Jets", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Armor", missionNamespace getVariable ["MWF_Unlock_Armor", false]];
profileNamespace setVariable ["MWF_Save_Unlock_Tier5", missionNamespace getVariable ["MWF_Unlock_Tier5", false]];
profileNamespace setVariable ["MWF_Save_Perk_HeliDiscount", missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1]];
profileNamespace setVariable ["MWF_Save_GrandOperationState", []];
profileNamespace setVariable ["MWF_Save_CampaignAnalytics", + (missionNamespace getVariable ["MWF_Campaign_Analytics", []])];
profileNamespace setVariable ["MWF_Save_AuthenticatedPlayers", + (missionNamespace getVariable ["MWF_AuthenticatedPlayers", []])];
private _cooldownMap = missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap];
private _cooldownPairs = [];
if (_cooldownMap isEqualType createHashMap) then {
    {
        private _remainingCooldown = ((_cooldownMap getOrDefault [_x, 0]) - serverTime) max 0;
        if (_remainingCooldown > 0) then {
            _cooldownPairs pushBack [_x, _remainingCooldown];
        };
    } forEach keys _cooldownMap;
};
profileNamespace setVariable ["MWF_Save_MainOperationCooldowns", _cooldownPairs];
profileNamespace setVariable ["MWF_Save_CompletedMainOperations", +(missionNamespace getVariable ["MWF_CompletedMainOperations", []])];

profileNamespace setVariable ["MWF_Save_StartSupplies", missionNamespace getVariable ["MWF_Locked_StartSupplies", 200]];
profileNamespace setVariable ["MWF_Save_SupplyTimer", missionNamespace getVariable ["MWF_Locked_SupplyTimer", 10]];
profileNamespace setVariable ["MWF_Save_CivReputation", missionNamespace getVariable ["MWF_Locked_CivReputation", 0]];
profileNamespace setVariable ["MWF_Save_ThreatGainMultiplier", missionNamespace getVariable ["MWF_Locked_ThreatGainMultiplier", missionNamespace getVariable ["MWF_ThreatGainMultiplier", 1]]];
profileNamespace setVariable ["MWF_Save_ThreatDecayMultiplier", missionNamespace getVariable ["MWF_Locked_ThreatDecayMultiplier", missionNamespace getVariable ["MWF_ThreatDecayMultiplier", 1]]];
profileNamespace setVariable ["MWF_Save_WorldTierMultiplier", missionNamespace getVariable ["MWF_Locked_WorldTierMultiplier", missionNamespace getVariable ["MWF_WorldTierMultiplier", 1]]];
profileNamespace setVariable ["MWF_Save_EndgameMapControl", missionNamespace getVariable ["MWF_Locked_EndgameMapControlRequired", missionNamespace getVariable ["MWF_EndgameMapControlRequired", 75]]];
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
private _garageVehicleCount = 0;
{
    if (_x isEqualType [] && {count _x >= 2}) then {
        _garageVehicleCount = _garageVehicleCount + count (_x param [1, [], [[]]]);
    };
} forEach (missionNamespace getVariable ["MWF_GarageStoredVehicles", []]);
private _missionCount = 0;
private _builtUpgradeCount = count _builtUpgradeStructures;
private _estimatedTotalBytes = (count toArray str _zoneSaveData) + (count toArray str _boughtVehicles) + (count toArray str (missionNamespace getVariable ["MWF_GarageStoredVehicles", []])) + (count toArray str _builtUpgradeStructures) + (count toArray str _revealedInfrastructureSites) + (count toArray str _damagedFOBs) + (count toArray str _leaderContext);

saveProfileNamespace;

diag_log format [
    "[MWF] Game saved (%1). Phase: %2 | Zones: %3 | Vehicles: %4 | Garage Stored: %5 | Built Upgrades: %6 | Missions: %7 | Leader Active: %8 | Damaged FOBs: %9 | Est. Payload: ~%10KB.",
    _reason,
    missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"],
    _zoneCount,
    _vehicleCount,
    _garageVehicleCount,
    _builtUpgradeCount,
    _missionCount,
    !(_leaderContext isEqualTo []),
    count _damagedFOBs,
    round (_estimatedTotalBytes / 1024)
];
