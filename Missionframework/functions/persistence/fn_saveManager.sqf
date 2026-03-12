/*
    Author: Theane using gemini
    Function: KPIN_fnc_saveManager
    Description: Core persistence engine for Operation Iron Mantle. Manages global states for infrastructure, reputation, and progression without saving volatile data like active quests or Opfor units.
*/

if (!isServer) exitWith {};

params [["_mode", "SAVE"]];

private _saveName = "KPIN_IronMantle_SaveData";

// --- MODE: SAVE ---
if (_mode == "SAVE") exitWith {
    private _dataToSave = [
        missionNamespace getVariable ["KPIN_CivRep", 0],               // [0] Civilian Reputation
        missionNamespace getVariable ["KPIN_RepPenaltyCount", 0],      // [1] Times reached -25 threshold
        missionNamespace getVariable ["KPIN_DestroyedHQs", 0],          // [2] Counter for destroyed HQs
        missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0],   // [3] Counter for destroyed Roadblocks
        missionNamespace getVariable ["KPIN_FOB_Positions", []],        // [4] Locations and status of FOBs
        missionNamespace getVariable ["KPIN_CurrentTier", 1],           // [5] Current World Tier (1-3)
        missionNamespace getVariable ["KPIN_SupplyTimer", 15]           // [6] User-selected supply interval
    ];

    profileNamespace setVariable [_saveName, _dataToSave];
    saveProfileNamespace;
    
    diag_log format ["[KPIN SAVE]: Game state saved. Content: %1", _dataToSave];
    ["KPIN_Notify", ["Game Saved", "Your progress has been stored."]] call CBA_fnc_globalEvent;
};

// --- MODE: LOAD ---
if (_mode == "LOAD") exitWith {
    private _loadedData = profileNamespace getVariable [_saveName, []];

    // Safety check if file exists
    if (count _loadedData == 0) exitWith {
        diag_log "[KPIN LOAD]: No existing save file found. Initializing fresh session.";
    };

    // Apply loaded data to Mission Namespace and broadcast globally
    missionNamespace setVariable ["KPIN_CivRep", (_loadedData select 0), true];
    missionNamespace setVariable ["KPIN_RepPenaltyCount", (_loadedData select 1), true];
    missionNamespace setVariable ["KPIN_DestroyedHQs", (_loadedData select 2), true];
    missionNamespace setVariable ["KPIN_DestroyedRoadblocks", (_loadedData select 3), true];
    missionNamespace setVariable ["KPIN_FOB_Positions", (_loadedData select 4), true];
    missionNamespace setVariable ["KPIN_CurrentTier", (_loadedData select 5), true];
    missionNamespace setVariable ["KPIN_SupplyTimer", (_loadedData select 6), true];

    diag_log "[KPIN LOAD]: Game state loaded successfully.";
    ["KPIN_Notify", ["Game Loaded", "Persistent progress has been restored."]] call CBA_fnc_globalEvent;
};

// --- MODE: WIPE ---
if (_mode == "WIPE") exitWith {
    profileNamespace setVariable [_saveName, nil];
    saveProfileNamespace;
    diag_log "[KPIN WIPE]: Profile data for Iron Mantle has been cleared.";
};
