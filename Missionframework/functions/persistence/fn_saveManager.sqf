/*
    Author: Theane using gemini
    Function: KPIN_fnc_saveManager
    Description: 
    Advanced persistence engine for Operation Iron Mantle. Manages a 10-point data array 
    including locked building damage parameters, discovered infrastructure, and the intel pool.
*/

if (!isServer) exitWith {};

params [["_mode", "SAVE"]];

private _saveName = "KPIN_IronMantle_SaveData";

// --- MODE: SAVE ---
if (_mode == "SAVE") exitWith {
    private _dataToSave = [
        missionNamespace getVariable ["KPIN_CivRep", 0],               // [0] Civilian Reputation
        missionNamespace getVariable ["KPIN_RepPenaltyCount", 0],      // [1] Reputation Penalties
        missionNamespace getVariable ["KPIN_DestroyedHQs", 0],          // [2] Counter: HQs
        missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0],   // [3] Counter: Roadblocks
        missionNamespace getVariable ["KPIN_FOB_Positions", []],        // [4] FOB Locations
        missionNamespace getVariable ["KPIN_CurrentTier", 1],           // [5] Tech Tier
        missionNamespace getVariable ["KPIN_SupplyTimer", 15],          // [6] Logistics Interval
        missionNamespace getVariable ["KPIN_LockedBuildingMode", -1],   // [7] 0=Damaged, 1=Destroyed (Locked)
        missionNamespace getVariable ["KPIN_CityBuildingStatus", []],   // [8] Ruined Buildings
        missionNamespace getVariable ["KPIN_IntelPool", 0],             // [9] Current Intel Amount
        missionNamespace getVariable ["KPIN_FixedInfrastructure", []]   // [10] Discovered Base Coords
    ];

    profileNamespace setVariable [_saveName, _dataToSave];
    saveProfileNamespace;
    
    diag_log format ["[KPIN SAVE]: Persistent state updated. Array size: %1", count _dataToSave];
};

// --- MODE: LOAD ---
if (_mode == "LOAD") exitWith {
    private _loadedData = profileNamespace getVariable [_saveName, []];

    // Check if this is a brand new campaign
    if (count _loadedData == 0) exitWith {
        // Initial run: Lock the building damage parameter from the lobby
        private _lobbyParam = ["BuildingDamageMode", 0] call BIS_fnc_getParamValue;
        missionNamespace setVariable ["KPIN_LockedBuildingMode", _lobbyParam, true];
        
        // Initialize other defaults
        missionNamespace setVariable ["KPIN_FixedInfrastructure", [], true];
        missionNamespace setVariable ["KPIN_CityBuildingStatus", [], true];
        missionNamespace setVariable ["KPIN_IntelPool", 0, true];
        
        diag_log "[KPIN LOAD]: New campaign started. Lobby parameters locked.";
    };

    // Apply loaded data to Mission Namespace
    missionNamespace setVariable ["KPIN_CivRep", (_loadedData select 0), true];
    missionNamespace setVariable ["KPIN_RepPenaltyCount", (_loadedData select 1), true];
    missionNamespace setVariable ["KPIN_DestroyedHQs", (_loadedData select 2), true];
    missionNamespace setVariable ["KPIN_DestroyedRoadblocks", (_loadedData select 3), true];
    missionNamespace setVariable ["KPIN_FOB_Positions", (_loadedData select 4), true];
    missionNamespace setVariable ["KPIN_CurrentTier", (_loadedData select 5), true];
    missionNamespace setVariable ["KPIN_SupplyTimer", (_loadedData select 6), true];
    
    // Crucial: Use saved state for Building Mode, ignoring lobby after first run
    missionNamespace setVariable ["KPIN_LockedBuildingMode", (_loadedData select 7), true];
    missionNamespace setVariable ["KPIN_CityBuildingStatus", (_loadedData select 8), true];
    missionNamespace setVariable ["KPIN_IntelPool", (_loadedData select 9), true];
    missionNamespace setVariable ["KPIN_FixedInfrastructure", (_loadedData select 10), true];

    diag_log "[KPIN LOAD]: Campaign state restored successfully.";
};

// --- MODE: WIPE ---
if (_mode == "WIPE") exitWith {
    profileNamespace setVariable [_saveName, nil];
    saveProfileNamespace;
    diag_log "[KPIN WIPE]: All persistent data for Operation Iron Mantle has been cleared.";
};
