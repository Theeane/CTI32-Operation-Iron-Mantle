/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_saveGame
    Description: Saves the entire mission state to profileNamespace.
    Language: English
*/

if (!isServer) exitWith {};
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

// 3. World State & Infrastructure
profileNamespace setVariable ["KPIN_Save_DestroyedHQs", missionNamespace getVariable ["KPIN_DestroyedHQs", 0]];
profileNamespace setVariable ["KPIN_Save_DestroyedRoadblocks", missionNamespace getVariable ["KPIN_DestroyedRoadblocks", 0]];
profileNamespace setVariable ["KPIN_Save_FixedInfra", missionNamespace getVariable ["KPIN_FixedInfrastructure", []]];
profileNamespace setVariable ["KPIN_Save_BuildingMode", missionNamespace getVariable ["KPIN_LockedBuildingMode", -1]];
profileNamespace setVariable ["KPIN_Save_FOBs", missionNamespace getVariable ["KPIN_FOB_Positions", []]];
profileNamespace setVariable ["KPIN_Save_Tier", missionNamespace getVariable ["KPIN_CurrentTier", 1]];

// 4. Mission Progress (Denna saknades!)
profileNamespace setVariable ["KPIN_Save_Missions", missionNamespace getVariable ["KPIN_completedMissions", []]];

saveProfileNamespace;
diag_log format ["[KPIN SAVE]: Game Saved. Reason: %1", _reason];
