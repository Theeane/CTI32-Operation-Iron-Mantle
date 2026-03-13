/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Description: Master Persistence Engine. 
    Handles: Economy, CivRep, Infrastructure, and Lobby-Parameter Locking.
*/

if (!isServer) exitWith {};

/**
 * MAIN SAVE FUNCTION
 */
KPIN_fnc_saveGame = {
    params [["_reason", "Auto-Save"]];

    // 1. Captured Zones
    private _allZones = missionNamespace getVariable ["KPIN_all_mission_zones", []];
    private _capturedZoneNames = [];
    {
        if (_x getVariable ["KPIN_isCaptured", false]) then {
            _capturedZoneNames pushBack (text _x); 
        };
    } forEach _allZones;
    profileNamespace setVariable ["KPIN_Save_Zones", _capturedZoneNames];

    // 2. Economy & Reputation
    profileNamespace setVariable ["KPIN_Save_Supplies", missionNamespace getVariable ["KPIN_Supplies", 100]];
    profileNamespace setVariable ["KPIN_Save_Intel", missionNamespace getVariable ["KPIN_Intel", 0]];
    profileNamespace setVariable ["KPIN_Save_CivRep", missionNamespace getVariable ["KPIN_CivRep", 0]];
    profileNamespace setVariable ["KPIN_Save_RepPenalties", missionNamespace getVariable ["KPIN_RepPenaltyCount", 0]];

    // 3. Infrastructure & World State (Från din SaveManager)
    profileNamespace setVariable ["KPIN_Save_DestroyedHQs", missionNamespace getVariable ["KPIN_DestroyedHQs", 0]];
    profileNamespace setVariable ["KPIN_Save_DestroyedRoadblocks", missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0]];
    profileNamespace setVariable ["KPIN_Save_FixedInfra", missionNamespace getVariable ["KPIN_FixedInfrastructure", []]];
    profileNamespace setVariable ["KPIN_Save_BuildingMode", missionNamespace getVariable ["KPIN_LockedBuildingMode", -1]];
    profileNamespace setVariable ["KPIN_Save_FOBs", missionNamespace getVariable ["KPIN_FOB_Positions", []]];
    profileNamespace setVariable ["KPIN_Save_Tier", missionNamespace getVariable ["KPIN_CurrentTier", 1]];

    saveProfileNamespace;
    diag_log format ["[KPIN SAVE]: Game Saved. Reason: %1", _reason];
};

/**
 * MASTER LOAD FUNCTION
 */
KPIN_fnc_loadGame = {
    // 1. Restore Economy
    missionNamespace setVariable ["KPIN_Supplies", profileNamespace getVariable ["KPIN_Save_Supplies", 100], true];
    missionNamespace setVariable ["KPIN_Intel", profileNamespace getVariable ["KPIN_Save_Intel", 0], true];
    missionNamespace setVariable ["KPIN_CivRep", profileNamespace getVariable ["KPIN_Save_CivRep", 0], true];
    
    // 2. Restore World State
    missionNamespace setVariable ["KPIN_DestroyedHQs", profileNamespace getVariable ["KPIN_Save_DestroyedHQs", 0], true];
    missionNamespace setVariable ["KPIN_FOB_Positions", profileNamespace getVariable ["KPIN_Save_FOBs", []], true];
    missionNamespace setVariable ["KPIN_CurrentTier", profileNamespace getVariable ["KPIN_Save_Tier", 1], true];

    // 3. LOBBY PARAMETER LOCK (Din geniala logik)
    private _savedMode = profileNamespace getVariable ["KPIN_Save_BuildingMode", -1];
    if (_savedMode == -1) then {
        // Första uppstarten: Hämta från lobby
        private _lobbyParam = ["BuildingDamageMode", 0] call BIS_fnc_getParamValue;
        missionNamespace setVariable ["KPIN_LockedBuildingMode", _lobbyParam, true];
    } else {
        // Ladda tidigare låst läge
        missionNamespace setVariable ["KPIN_LockedBuildingMode", _savedMode, true];
    };

    diag_log "[KPIN LOAD]: Campaign state fully restored.";
};

// Auto-save triggers... (behåll CBA-handlern vi skrev innan)
