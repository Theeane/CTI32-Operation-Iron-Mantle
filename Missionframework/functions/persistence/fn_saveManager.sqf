/*
    Author: KPIN
    Description: Core persistence engine for Operation Iron Mantle.
    Handles storage and retrieval of infrastructure, reputation, and progression.
    
    Strict Rules:
    - NO Opfor units or active quests are saved.
    - Infrastructure is saved dynamically (HQs/Roadblocks).
    - Uses profileNamespace for persistent cross-session storage.
*/

if (!isServer) exitWith {};

params [["_mode", "SAVE"]];

private _saveName = "KPIN_IronMantle_SaveData";

// --- MODE: SAVE ---
if (_mode == "SAVE") exitWith {
    private _dataToSave = [
        missionNamespace getVariable ["KPIN_CivRep", 0],               // [0] Reputation
        missionNamespace getVariable ["KPIN_RepPenaltyCount", 0],      // [1] Penalty Count
        missionNamespace getVariable ["KPIN_DestroyedHQs", 0],          // [2] Destroyed HQs
        missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0],   // [3] Destroyed Roadblocks
        missionNamespace getVariable ["KPIN_FOB_Positions", []],        // [4] Active FOBs
        missionNamespace getVariable ["KPIN_CurrentTier", 1],           // [5] World Tier
        missionNamespace getVariable ["KPIN_SupplyTimer", 15]           // [6] Supply Interval (5,10,15,20,30)
    ];

    profileNamespace setVariable [_saveName, _dataToSave];
    saveProfileNamespace;
    
    diag_log format ["[KPIN SAVE]: Game state saved. Data: %1", _dataToSave];
    ["KPIN_Notify", ["Game Saved", "Your progress has been stored in the profile."]] call CBA_fnc_globalEvent;
};

// --- MODE: LOAD ---
if (_mode == "LOAD") exitWith {
    private _loadedData = profileNamespace getVariable [_saveName, []];

    // Check if save data actually exists
    if (count _loadedData == 0) exitWith {
        diag_log "[KPIN LOAD]: No save data found. Starting fresh session.";
    };

    // Apply loaded variables to the mission namespace
    missionNamespace setVariable ["KPIN_CivRep", (_loadedData select 0), true];
    missionNamespace setVariable ["KPIN_RepPenaltyCount", (_loadedData select 1), true];
    missionNamespace setVariable ["KPIN_DestroyedHQs", (_loadedData select 2), true];
    missionNamespace setVariable ["KPIN_DestroyedRoadblocks", (_loadedData select 3), true];
    missionNamespace setVariable ["KPIN_FOB_Positions", (_loadedData select 4), true];
    missionNamespace setVariable ["KPIN_CurrentTier", (_loadedData select 5), true];
    missionNamespace setVariable ["KPIN_SupplyTimer", (_loadedData select 6), true];

    diag_log "[KPIN LOAD]: Game state loaded successfully.";
    ["KPIN_Notify", ["Game Loaded", "Persistent progress restored."]] call CBA_fnc_globalEvent;
};

// --- MODE: WIPE (Useful for testing) ---
if (_mode == "WIPE") exitWith {
    profileNamespace setVariable [_saveName, nil];
    saveProfileNamespace;
    diag_log "[KPIN WIPE]: Save data cleared.";
};
