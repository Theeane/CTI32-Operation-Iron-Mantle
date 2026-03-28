/*
    Author: OpenAI / Operation Iron Mantle
    File: initServer.sqf
    Project: Military War Framework (MWF)

    Description:
    Fail-closed essentials boot.
    Brings up the minimum viable world before clients continue:
    presets -> core globals/systems -> MOB assets -> zones.
    Every essential step is isolated and then verified with aggressive fallback
    rebuilds for MOB assets and zones so the world exists before clients wake up.
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
missionNamespace setVariable ["MWF_ServerEssentialsFailed", false, true];
missionNamespace setVariable ["MWF_ServerReadyReason", "BOOTING", true];

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
        diag_log format ["[MWF] ERROR: Step %1 aborted before completion.", _label];
    };

    _ok
};

private _spawnPostStep = {
    params ["_label", "_code"];
    [_label, _code] spawn {
        params ["_localLabel", "_localCode"];
        missionNamespace setVariable ["MWF_ServerPostBootStage", _localLabel, true];
        diag_log format ["[MWF] POST STEP START: %1", _localLabel];
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

private _ensureMissionRef = {
    params ["_varName"];
    private _value = missionNamespace getVariable [_varName, objNull];
    if (isNull _value && {!isNil _varName}) then {
        _value = call compile _varName;
    };
    missionNamespace setVariable [_varName, _value, true];
    _value
};

["INIT_GLOBALS", { [] call MWF_fnc_initGlobals; }] call _runStep;

private _mobObject = ["MWF_MOB"] call _ensureMissionRef;
missionNamespace setVariable ["MWF_MainBase", _mobObject, true];
missionNamespace setVariable ["MWF_MOB_Object", _mobObject, true];

private _mobRespawnAnchor = ["MWF_MOB_RespawnAnchor"] call _ensureMissionRef;
private _mobAssetAnchor = ["MWF_MOB_AssetAnchor"] call _ensureMissionRef;

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

private _ensureMobAssets = {
    private _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
    if (!isNull _terminal) exitWith { true };
    if (isNil "MWF_fnc_initMOBAssets") exitWith { false };

    private _ok = false;
    for "_i" from 1 to 3 do {
        diag_log format ["[MWF] EMERGENCY: MOB asset retry %1", _i];
        private _spawned = [] call MWF_fnc_initMOBAssets;
        _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
        if (isNull _terminal && {!isNull _spawned}) then {
            _terminal = _spawned;
            missionNamespace setVariable ["MWF_Intel_Center", _spawned, true];
        };
        if (!isNull _terminal) exitWith {
            _ok = true;
        };
        uiSleep 0.25;
    };
    _ok
};

private _ensureZones = {
    private _existing = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select {!isNull _x};
    if ((count _existing) > 0) exitWith { true };

    diag_log "[MWF] EMERGENCY: rebuilding zone registry directly from mission data.";

    private _manualZones = [];
    if (!isNil "MWF_fnc_loadManualZones") then {
        _manualZones = [] call MWF_fnc_loadManualZones;
    };
    if (_manualZones isEqualTo [] && {!isNil "MWF_fnc_scanZones"}) then {
        _manualZones = [] call MWF_fnc_scanZones;
    };

    private _allZones = [];
    {
        private _zone = _x;
        if (!isNull _zone) then {
            private _registered = if (!isNil "MWF_fnc_registerZone") then {
                [_zone] call MWF_fnc_registerZone
            } else {
                _zone
            };
            if (!isNull _registered) then {
                _allZones pushBackUnique _registered;
                if (!isNil "MWF_fnc_syncZoneMarker") then {
                    [_registered] call MWF_fnc_syncZoneMarker;
                };
            };
        };
    } forEach _manualZones;

    missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];
    missionNamespace setVariable ["MWF_ActiveZones", _allZones, true];

    if ((count _allZones) > 0) then {
        if (!isNil "MWF_fnc_initZones") then {
            [] call MWF_fnc_initZones;
        };
        if (!isNil "MWF_fnc_zoneHandler") then {
            missionNamespace setVariable ["MWF_ZoneHandlerStarted", false, true];
            [] spawn MWF_fnc_zoneHandler;
        };
        if (!isNil "MWF_fnc_abandonManager") then {
            missionNamespace setVariable ["MWF_AbandonManagerStarted", false, true];
            [] spawn MWF_fnc_abandonManager;
        };
        missionNamespace setVariable ["MWF_ZoneSystemReady", true, true];
        diag_log format ["[MWF] EMERGENCY: recovered %1 zones.", count _allZones];
        true
    } else {
        diag_log "[MWF] ERROR: emergency zone rebuild still found zero zones.";
        false
    };
};

if (!_mobAssetsOk || {isNull (missionNamespace getVariable ["MWF_Intel_Center", objNull])}) then {
    _mobAssetsOk = call _ensureMobAssets;
};

if (!_zoneOk || {count ((missionNamespace getVariable ["MWF_all_mission_zones", []]) select {!isNull _x}) <= 0}) then {
    _zoneOk = call _ensureZones;
};

private _essentialsOk = _presetOk && _systemsOk && _mobAssetsOk && _zoneOk;
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
missionNamespace setVariable ["MWF_ServerBootStage", if (_essentialsOk) then {"ESSENTIALS_READY"} else {"ESSENTIALS_FAILED"}, true];
missionNamespace setVariable ["MWF_ServerReady", _essentialsOk, true];
missionNamespace setVariable ["MWF_ServerEssentialsReady", _essentialsOk, true];
missionNamespace setVariable ["MWF_ServerEssentialsFailed", !_essentialsOk, true];
missionNamespace setVariable ["MWF_ServerReadyReason", if (_essentialsOk) then {"ESSENTIALS_READY"} else {"ESSENTIALS_FAILED"}, true];

if (_essentialsOk) then {
    diag_log format ["[MWF] SUCCESS: Essentials ready. Presets=%1 Systems=%2 MOBAssets=%3 Zones=%4", _presetOk, _systemsOk, _mobAssetsOk, _zoneOk];
} else {
    diag_log format ["[MWF] ERROR: Essentials failed. Presets=%1 Systems=%2 MOBAssets=%3 Zones=%4", _presetOk, _systemsOk, _mobAssetsOk, _zoneOk];
};

["INIT_PERSISTENCE", { [] call MWF_fnc_initPersistence; }] call _spawnPostStep;
["LOAD_GAME", { [] call MWF_fnc_loadGame; }] call _spawnPostStep;
["INIT_ANALYTICS", { [] call MWF_fnc_initCampaignAnalytics; }] call _spawnPostStep;
["WORLD_MANAGER", { [] call MWF_fnc_worldManager; }] call _spawnPostStep;
["THREAT_MANAGER", { [] call MWF_fnc_threatManager; }] call _spawnPostStep;
["DEBUG_MANAGER", { [] call MWF_fnc_debugManager; }] call _spawnPostStep;
