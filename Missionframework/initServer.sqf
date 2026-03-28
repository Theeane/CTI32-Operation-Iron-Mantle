/*
    Author: OpenAI / Operation Iron Mantle
    File: initServer.sqf
    Project: Military War Framework (MWF)

    Description:
    Function-first server boot.
    Brings up the minimum viable world before clients continue:
    presets -> core globals/systems -> MOB assets -> zones.
    Every step runs in an isolated script so one runtime error does not abort the rest
    of the boot chain.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ServerBootRunning", false]) exitWith {};

missionNamespace setVariable ["MWF_ServerBootRunning", true, true];
missionNamespace setVariable ["MWF_ServerInitialized", false, true];
missionNamespace setVariable ["MWF_ServerBootStage", "BOOT_START", true];
missionNamespace setVariable ["MWF_ServerPostBootStage", "IDLE", true];
missionNamespace setVariable ["MWF_ServerSubsystemsReady", false, true];
missionNamespace setVariable ["MWF_ServerReady", false, true];
missionNamespace setVariable ["MWF_ServerEssentialsReady", false, true];

private _setBootStage = {
    params ["_stage"];
    missionNamespace setVariable ["MWF_ServerBootStage", _stage, true];
    diag_log format ["[MWF] BOOT: %1", _stage];
};

private _stepKey = {
    params ["_label"];
    format ["MWF_BootStep_%1_OK", _label]
};

private _runStep = {
    params ["_label", "_code"];

    [_label] call _setBootStage;
    diag_log format ["[MWF] STEP START: %1", _label];

    private _okKey = [_label] call _stepKey;
    missionNamespace setVariable [_okKey, false];

    private _handle = [_label, _code, _okKey] spawn {
        params ["_label", "_code", "_okKey"];
        call _code;
        missionNamespace setVariable [_okKey, true];
    };

    waitUntil {
        uiSleep 0.1;
        scriptDone _handle
    };

    private _ok = missionNamespace getVariable [_okKey, false];
    if (_ok) then {
        diag_log format ["[MWF] STEP END: %1", _label];
    } else {
        diag_log format ["[MWF] ERROR: Step %1 aborted before completion. Boot will continue.", _label];
    };

    _ok
};

private _spawnPostStep = {
    params ["_label", "_code"];
    [_label, _code] spawn {
        params ["_localLabel", "_localCode"];
        missionNamespace setVariable ["MWF_ServerPostBootStage", _localLabel, true];
        diag_log format ["[MWF] POST STEP START: %1", _localLabel];

        private _ok = true;
        private _handle = [_localCode] spawn {
            params ["_localCode"];
            call _localCode;
        };

        waitUntil {
            uiSleep 0.1;
            scriptDone _handle
        };

        diag_log format ["[MWF] POST STEP END: %1", _localLabel];
    };
};

["INIT_GLOBALS", { [] call MWF_fnc_initGlobals; }] call _runStep;

private _mobObject = missionNamespace getVariable ["MWF_MOB", objNull];
missionNamespace setVariable ["MWF_MainBase", _mobObject, true];
missionNamespace setVariable ["MWF_MOB_Object", _mobObject, true];

private _mobRespawnAnchor = missionNamespace getVariable ["MWF_MOB_RespawnAnchor", objNull];
if (isNull _mobRespawnAnchor && {!isNil "MWF_MOB_RespawnAnchor"}) then {
    _mobRespawnAnchor = MWF_MOB_RespawnAnchor;
};
missionNamespace setVariable ["MWF_MOB_RespawnAnchor", _mobRespawnAnchor, true];

private _mobAssetAnchor = missionNamespace getVariable ["MWF_MOB_AssetAnchor", objNull];
if (isNull _mobAssetAnchor && {!isNil "MWF_MOB_AssetAnchor"}) then {
    _mobAssetAnchor = MWF_MOB_AssetAnchor;
};
missionNamespace setVariable ["MWF_MOB_AssetAnchor", _mobAssetAnchor, true];

private _mobPad = missionNamespace getVariable ["MWF_MOB_FobPad", missionNamespace getVariable ["MWF_FOB_Box_Spawn", objNull]];
if (isNull _mobPad) then {
    private _searchOrigin = if (!isNull _mobAssetAnchor) then {
        getPosATL _mobAssetAnchor
    } else {
        if (!isNull _mobObject) then { getPosATL _mobObject } else { getMarkerPos "MWF_MOB_Marker" }
    };
    if (_searchOrigin isEqualTo [0, 0, 0]) then {
        _searchOrigin = getMarkerPos "respawn_west";
    };
    private _pads = nearestObjects [_searchOrigin, ["Land_HelipadEmpty_F", "Land_HelipadSquare_F", "Land_HelipadCircle_F"], 75, true];
    _pads = _pads select { !isNull _x && {_x != _mobRespawnAnchor} && {_x != _mobAssetAnchor} };
    if !(_pads isEqualTo []) then {
        _mobPad = _pads # 0;
    };
};
missionNamespace setVariable ["MWF_MOB_FobPad", _mobPad, true];

private _deployPad = missionNamespace getVariable ["MWF_MOB_DeployPad", missionNamespace getVariable ["mob_deploy_pad", objNull]];
if (isNull _deployPad && {!isNull _mobRespawnAnchor}) then {
    _deployPad = _mobRespawnAnchor;
};
if (isNull _deployPad) then {
    private _searchOrigin = if (!isNull _mobRespawnAnchor) then {
        getPosATL _mobRespawnAnchor
    } else {
        if (!isNull _mobObject) then { getPosATL _mobObject } else { getMarkerPos "MWF_MOB_Marker" }
    };
    if (_searchOrigin isEqualTo [0, 0, 0]) then {
        _searchOrigin = getMarkerPos "respawn_west";
    };
    private _pads = nearestObjects [_searchOrigin, ["Land_HelipadEmpty_F", "Land_HelipadSquare_F", "Land_HelipadCircle_F"], 75, true];
    _pads = _pads select { !isNull _x && {_x != _mobPad} && {_x != _mobAssetAnchor} };
    if !(_pads isEqualTo []) then {
        _deployPad = _pads # 0;
    };
};
missionNamespace setVariable ["MWF_MOB_DeployPad", _deployPad, true];

private _mainRespawnMarker = "";
if (markerColor "MWF_MOB_Marker" isNotEqualTo "") then {
    _mainRespawnMarker = "MWF_MOB_Marker";
} else {
    if (markerColor "respawn_west" isNotEqualTo "") then {
        _mainRespawnMarker = "respawn_west";
    };
};

private _existingMainRespawnId = missionNamespace getVariable ["MWF_MainRespawnPositionId", -1];
if (_existingMainRespawnId isEqualType 0 && {_existingMainRespawnId >= 0}) then {
    [west, _existingMainRespawnId] call BIS_fnc_removeRespawnPosition;
};

if (markerColor "respawn_west" isNotEqualTo "") then {
    missionNamespace setVariable ["MWF_MainRespawnPositionId", -1, true];
    diag_log "[MWF] Native respawn_west/MenuPosition detected. Skipping scripted MOB respawn registration to avoid duplicate deploy entries.";
} else {
    private _mobRespawnTarget = objNull;
    if (!isNull _mobRespawnAnchor) then {
        _mobRespawnTarget = _mobRespawnAnchor;
    } else {
        if (_mainRespawnMarker isNotEqualTo "") then {
            _mobRespawnTarget = _mainRespawnMarker;
        };
    };

    if !(_mobRespawnTarget isEqualTo objNull && {_mainRespawnMarker isEqualTo ""}) then {
        private _mainRespawnId = [west, _mobRespawnTarget, missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"]] call BIS_fnc_addRespawnPosition;
        missionNamespace setVariable ["MWF_MainRespawnPositionId", _mainRespawnId, true];
        diag_log format ["[MWF] Main Operating Base respawn registered on %1.", _mobRespawnTarget];
    } else {
        missionNamespace setVariable ["MWF_MainRespawnPositionId", -1, true];
        diag_log "[MWF] WARNING: No valid Main Operating Base respawn target was found during server init.";
    };
};

private _presetOk = ["PRESET_MANAGER", { [] call MWF_fnc_presetManager; }] call _runStep;
private _systemsOk = ["INIT_SYSTEMS", { [] call MWF_fnc_initSystems; }] call _runStep;
private _mobAssetsOk = false;
if (!isNil "MWF_fnc_initMOBAssets") then {
    _mobAssetsOk = ["INIT_MOB_ASSETS", { [] call MWF_fnc_initMOBAssets; }] call _runStep;
};
private _zoneOk = ["ZONE_MANAGER", { [] call MWF_fnc_zoneManager; }] call _runStep;

missionNamespace setVariable [
    "MWF_ServerEssentialsStatus",
    [
        ["PRESET_MANAGER", _presetOk],
        ["INIT_SYSTEMS", _systemsOk],
        ["INIT_MOB_ASSETS", _mobAssetsOk],
        ["ZONE_MANAGER", _zoneOk]
    ],
    true
];

missionNamespace setVariable ["MWF_ServerInitialized", true, true];
missionNamespace setVariable ["MWF_ServerBootRunning", false, true];
missionNamespace setVariable ["MWF_ServerBootStage", "ESSENTIALS_READY", true];
missionNamespace setVariable ["MWF_ServerReady", true, true];
missionNamespace setVariable ["MWF_ServerEssentialsReady", true, true];
diag_log format ["[MWF] SUCCESS: Essentials released. Presets=%1 Systems=%2 MOBAssets=%3 Zones=%4", _presetOk, _systemsOk, _mobAssetsOk, _zoneOk];

["INIT_PERSISTENCE", { [] call MWF_fnc_initPersistence; }] call _spawnPostStep;
["LOAD_GAME", { [] call MWF_fnc_loadGame; }] call _spawnPostStep;
["INIT_ANALYTICS", { [] call MWF_fnc_initCampaignAnalytics; }] call _spawnPostStep;
["WORLD_MANAGER", { [] call MWF_fnc_worldManager; }] call _spawnPostStep;
["THREAT_MANAGER", { [] call MWF_fnc_threatManager; }] call _spawnPostStep;

if (!isNil "MWF_fnc_opforFobPatrolSystem") then {
    ["OPFOR_FOB_PATROLS", { ["INIT"] call MWF_fnc_opforFobPatrolSystem; }] call _spawnPostStep;
};

["ECONOMY", { [] spawn MWF_fnc_economy; }] call _spawnPostStep;
["MISSION_SYSTEM", { [] call MWF_fnc_initMissionSystem; }] call _spawnPostStep;
["RESTORE_SESSION", { [] call MWF_fnc_restoreSession; }] call _spawnPostStep;
["RESTORE_FOBS", { [] call MWF_fnc_restoreFOBs; }] call _spawnPostStep;

if (!isNil "MWF_fnc_restoreBuiltUpgradeStructures") then {
    ["RESTORE_BUILT_UPGRADES", { [] call MWF_fnc_restoreBuiltUpgradeStructures; }] call _spawnPostStep;
};

["INITIAL_FOB_ASSET", {
    private _deadline = diag_tickTime + 15;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_FOBsRestored", false]) || {diag_tickTime >= _deadline}
    };
    [] call MWF_fnc_spawnInitialFOBAsset;
}] call _spawnPostStep;

["TUTORIAL_BOOTSTRAP", {
    private _campaignPhase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
    private _tutorialStage = missionNamespace getVariable ["MWF_current_stage", 0];
    private _supplyRunDone = missionNamespace getVariable ["MWF_Tutorial_SupplyRunDone", false];

    if (_campaignPhase isEqualTo "TUTORIAL" && {_tutorialStage < 1}) then {
        [1] call MWF_fnc_generateInitialMission;
        diag_log "[MWF] Tutorial bootstrap: seeded Stage 1 task during server init.";
    };

    if (_campaignPhase isEqualTo "SUPPLY_RUN" && {!_supplyRunDone} && {_tutorialStage < 2}) then {
        [2] call MWF_fnc_generateInitialMission;
        diag_log "[MWF] Tutorial bootstrap: seeded Stage 2 task during server init.";
    };
}] call _spawnPostStep;

if (!isNil "MWF_fnc_infrastructureManager") then {
    ["INFRASTRUCTURE_MANAGER", { ["INIT"] call MWF_fnc_infrastructureManager; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_spawnManager") then {
    ["SPAWN_MANAGER", { ["BOOTSTRAP"] spawn MWF_fnc_spawnManager; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_cityMonitor") then {
    ["CITY_MONITOR", { [] spawn MWF_fnc_cityMonitor; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_civRepSupport") then {
    ["CIVREP_SUPPORT", { ["SYNC_RELATIONS"] call MWF_fnc_civRepSupport; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_civRepInformant") then {
    ["CIVREP_INFORMANT", { ["INIT"] call MWF_fnc_civRepInformant; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_endgameManager") then {
    ["ENDGAME_MANAGER", { ["INIT"] spawn MWF_fnc_endgameManager; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_rebelLeaderSystem") then {
    ["REBEL_LEADER_RESTORE", { ["RESTORE_PENDING"] call MWF_fnc_rebelLeaderSystem; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_fobAttackSystem") then {
    ["FOB_ATTACK_RESTORE", { ["RESTORE_PENDING"] call MWF_fnc_fobAttackSystem; }] call _spawnPostStep;
};
if (!isNil "MWF_fnc_fobDespawnSystem") then {
    ["FOB_DESPAWN_RESTORE", { ["RESTORE_PENDING"] call MWF_fnc_fobDespawnSystem; }] call _spawnPostStep;
};

[] spawn {
    private _deadline = diag_tickTime + 180;
    waitUntil {
        uiSleep 1;
        (
            missionNamespace getVariable ["MWF_ZoneSystemReady", false] &&
            missionNamespace getVariable ["MWF_WorldSystemReady", false] &&
            missionNamespace getVariable ["MWF_ThreatSystemReady", false]
        ) || {diag_tickTime >= _deadline}
    };

    if (!(missionNamespace getVariable ["MWF_ZoneSystemReady", false])) then {
        diag_log format ["[MWF] WARNING: Zone system not fully ready before subsystem monitor timeout. Stage=%1", missionNamespace getVariable ["MWF_ZoneManagerStage", "UNKNOWN"]];
    };
    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
        diag_log "[MWF] WARNING: World system not fully ready before subsystem monitor timeout.";
    };
    if (!(missionNamespace getVariable ["MWF_ThreatSystemReady", false])) then {
        diag_log "[MWF] WARNING: Threat system not fully ready before subsystem monitor timeout.";
    };

    missionNamespace setVariable ["MWF_ServerSubsystemsReady", true, true];
    missionNamespace setVariable ["MWF_ServerPostBootStage", "POST_BOOT_COMPLETE", true];
    diag_log "[MWF] SUCCESS: Background subsystem monitor complete.";
};
