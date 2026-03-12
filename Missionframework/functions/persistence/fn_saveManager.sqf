/*
    Author: Theane using gemini
    Function: KPIN_fnc_saveManager
    Description: 
    Core persistence engine. Now includes logic to lock lobby parameters (Building Damage Mode) 
    after the first session and tracks the destruction status of civilian buildings.
*/

if (!isServer) exitWith {};

params [["_mode", "SAVE"]];

private _saveName = "KPIN_IronMantle_SaveData";

if (_mode == "SAVE") exitWith {
    private _dataToSave = [
        missionNamespace getVariable ["KPIN_CivRep", 0],               // [0]
        missionNamespace getVariable ["KPIN_RepPenaltyCount", 0],      // [1]
        missionNamespace getVariable ["KPIN_DestroyedHQs", 0],          // [2]
        missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0],   // [3]
        missionNamespace getVariable ["KPIN_FOB_Positions", []],        // [4]
        missionNamespace getVariable ["KPIN_CurrentTier", 1],           // [5]
        missionNamespace getVariable ["KPIN_SupplyTimer", 15],          // [6]
        missionNamespace getVariable ["KPIN_LockedBuildingMode", -1],   // [7] Locked Param
        missionNamespace getVariable ["KPIN_CityBuildingStatus", []],   // [8] Damaged Houses IDs
        missionNamespace getVariable ["KPIN_IntelPool", 0]              // [9] Current Intel Pool
    ];

    profileNamespace setVariable [_saveName, _dataToSave];
    saveProfileNamespace;
    diag_log "[KPIN SAVE]: Data saved including Locked Parameters.";
};

if (_mode == "LOAD") exitWith {
    private _loadedData = profileNamespace getVariable [_saveName, []];
    if (count _loadedData == 0) exitWith {
        // FIRST RUN: Get mode from Lobby Params and lock it
        private _lobbyParam = ["BuildingDamageMode", 0] call BIS_fnc_getParamValue;
        missionNamespace setVariable ["KPIN_LockedBuildingMode", _lobbyParam, true];
        diag_log format ["[KPIN LOAD]: Fresh start. Locking Building Mode to: %1", _lobbyParam];
    };

    // Apply standard data
    missionNamespace setVariable ["KPIN_CivRep", (_loadedData select 0), true];
    missionNamespace setVariable ["KPIN_RepPenaltyCount", (_loadedData select 1), true];
    missionNamespace setVariable ["KPIN_DestroyedHQs", (_loadedData select 2), true];
    missionNamespace setVariable ["KPIN_DestroyedRoadblocks", (_loadedData select 3), true];
    missionNamespace setVariable ["KPIN_FOB_Positions", (_loadedData select 4), true];
    missionNamespace setVariable ["KPIN_CurrentTier", (_loadedData select 5), true];
    missionNamespace setVariable ["KPIN_SupplyTimer", (_loadedData select 6), true];
    
    // STRICT LOCK: Use saved mode, ignore lobby params
    missionNamespace setVariable ["KPIN_LockedBuildingMode", (_loadedData select 7), true];
    missionNamespace setVariable ["KPIN_CityBuildingStatus", (_loadedData select 8), true];
    missionNamespace setVariable ["KPIN_IntelPool", (_loadedData select 9), true];

    diag_log "[KPIN LOAD]: Loaded. Lobby Building Params ignored in favor of Locked State.";
};
