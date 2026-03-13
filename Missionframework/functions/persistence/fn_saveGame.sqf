/*
    Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_saveGame
    Description: Saves the mission state to profileNamespace. 
    Rule: OPFOR units and active quests are NOT saved (Clean Slate).
*/

if (!isServer) exitWith {};
params [["_reason", "Auto-Save"]];

// 1. Map Completion Logic
private _allZones = missionNamespace getVariable ["KPIN_all_mission_zones", []];
private _totalZones = count _allZones;
private _capturedZoneNames = [];

{
    if (_x getVariable ["KPIN_isCaptured", false]) then {
        _capturedZoneNames pushBack (_x getVariable ["KPIN_zoneID", text _x]); 
    };
} forEach _allZones;

private _capturedCount = count _capturedZoneNames;
private _completionPercent = if (_totalZones > 0) then {(_capturedCount / _totalZones) * 100} else {0};

// Save completion data to trigger Tier 3 lock logic in loadGame/updateWorldState
profileNamespace setVariable ["KPIN_Save_Zones", _capturedZoneNames];
profileNamespace setVariable ["KPIN_Save_Completion", _completionPercent];

// 2. Economy & Reputation (Digital Currency)
profileNamespace setVariable ["KPIN_Save_Supplies", missionNamespace getVariable ["KPIN_Supplies", 100]];
profileNamespace setVariable ["KPIN_Save_Intel", missionNamespace getVariable ["KPIN_Intel", 0]];
profileNamespace setVariable ["KPIN_Save_CivRep", missionNamespace getVariable ["KPIN_CivRep", 0]];
profileNamespace setVariable ["KPIN_Save_RepPenalties", missionNamespace getVariable ["KPIN_RepPenaltyCount", 0]];

// 3. World State & Infrastructure
profileNamespace setVariable ["KPIN_Save_DestroyedHQs", missionNamespace getVariable ["KPIN_DestroyedHQs", 0]];
profileNamespace setVariable ["KPIN_Save_DestroyedRoadblocks", missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0]];
profileNamespace setVariable ["KPIN_Save_Tier", missionNamespace getVariable ["KPIN_CurrentTier", 1]];
profileNamespace setVariable ["KPIN_Save_FixedInfra", missionNamespace getVariable ["KPIN_FixedInfrastructure", []]];
profileNamespace setVariable ["KPIN_Save_FOBs", missionNamespace getVariable ["KPIN_FOB_Positions", []]];
profileNamespace setVariable ["KPIN_Save_BuildingMode", missionNamespace getVariable ["KPIN_LockedBuildingMode", -1]];

// 4. Mission Progress (Completed ONLY)
profileNamespace setVariable ["KPIN_Save_Missions", missionNamespace getVariable ["KPIN_completedMissions", []]];

saveProfileNamespace;
diag_log format ["[KPIN SAVE]: Game Saved (%1). Completion: %2%3. CivRep: %4", _reason, floor _completionPercent, "%", missionNamespace getVariable ["KPIN_CivRep", 0]];
