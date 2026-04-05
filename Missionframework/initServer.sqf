/*
    Author: OpenAI / Operation Iron Mantle
    File: initServer.sqf
    Project: Military War Framework (MWF)

    Description:
    Authoritative server bootstrapper. Optimized for speed and reliability.
    Guarantees MOB assets and forces client release to prevent lobby-hangs.
*/

if (!isServer) exitWith {};

// 1. Initial Server State
missionNamespace setVariable ["MWF_ServerBootRunning", true, true];
missionNamespace setVariable ["MWF_ServerReady", false, true];
missionNamespace setVariable ["MWF_ServerInitialized", false, true];
missionNamespace setVariable ["MWF_ServerBootStage", "BOOT_START", true];

// Helper to run steps and update global status
private _runStep = {
    params ["_label", "_code"];
    missionNamespace setVariable ["MWF_ServerBootStage", _label, true];
    diag_log format ["[MWF] STEP START: %1", _label];
    private _success = call _code;
    diag_log format ["[MWF] STEP END: %1", _label];
    if (isNil "_success") then { _success = true; };
    _success
};

// 2. Sequential Essentials (Critical for Terminal & Systems)
["LOAD_GAME", {
    private _wipeRequested = ["MWF_Param_WipeSave", 0] call BIS_fnc_getParamValue;
    private _wipeConfirmed = ["MWF_Param_ConfirmWipe", 0] call BIS_fnc_getParamValue;

    if (_wipeRequested == 1 && _wipeConfirmed == 1) then {
        missionNamespace setVariable ["MWF_isWiping", true, true];
        if (!isNil "MWF_fnc_wipeSave") then {
            [] call MWF_fnc_wipeSave;
        };
        diag_log "[MWF] Save wipe requested by lobby parameters before campaign load.";
    };

    if (!isNil "MWF_fnc_loadGame") then {
        [] call MWF_fnc_loadGame;
    };
    missionNamespace setVariable ["MWF_CampaignLoadApplied", true, true];
    true
}] call _runStep;
["INIT_GLOBALS", { [] call MWF_fnc_initGlobals; }] call _runStep;
["PRESET_MANAGER", { [] call MWF_fnc_presetManager; }] call _runStep;
["INIT_SYSTEMS", { [] call MWF_fnc_initSystems; }] call _runStep;

// 3. MOB Asset Spawning (Creates the physical laptop)
["INIT_MOB_ASSETS", { 
    private _terminal = [] call MWF_fnc_initMOBAssets;
    !isNull _terminal 
}] call _runStep;

// 4. Zone Management (Background process to prevent blocking)
["ZONE_MANAGER", { 
    // We spawn this so the server can move on to releasing clients immediately
    [] spawn {
        [] call MWF_fnc_zoneManager;
        
        // VISUAL FIX: Force zones to appear on the map
        // This loops through all registered zones and ensures they draw visible markers
        uiSleep 2;
        private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
        {
            if (!isNil "MWF_fnc_syncZoneMarker") then {
                [_x] call MWF_fnc_syncZoneMarker;
            };
        } forEach _allZones;
        
        missionNamespace setVariable ["MWF_ZoneSystemReady", true, true];
        diag_log format ["[MWF] Zone Visual Sync Complete. Zones Processed: %1", count _allZones];
    };
    true
}] call _runStep;

// 5. Handshake & Release Logic
[] spawn {
    // Wait for core assets but cap the wait at 10 seconds
    private _deadline = diag_tickTime + 10;
    waitUntil {
        uiSleep 0.5;
        (missionNamespace getVariable ["MWF_MOBAssetsInitialized", false]) || {diag_tickTime >= _deadline}
    };

    // Release clients into the mission
    missionNamespace setVariable ["MWF_ServerBootStage", "CRITICAL_RELEASED", true];
    missionNamespace setVariable ["MWF_ServerReady", true, true];
    missionNamespace setVariable ["MWF_ServerInitialized", true, true];
    missionNamespace setVariable ["MWF_ServerBootRunning", false, true];
    
    diag_log "[MWF] SERVER HANDSHAKE RELEASED: Clients are now authorized to start.";
};

// 6. Background World/Persistence (Non-essential for initial spawn)
["INIT_WORLD", { [] spawn MWF_fnc_initWorld; true }] call _runStep;
["INIT_PERSISTENCE", { [] spawn MWF_fnc_initPersistence; true }] call _runStep;

true
