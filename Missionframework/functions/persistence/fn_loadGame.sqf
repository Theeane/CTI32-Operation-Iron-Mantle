/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_loadGame
    Description: Restores mission state and locks lobby parameters.
    Language: English
*/

if (!isServer) exitWith {};

// 1. Economy & Reputation
missionNamespace setVariable ["KPIN_Supplies", profileNamespace getVariable ["KPIN_Save_Supplies", 100], true];
missionNamespace setVariable ["KPIN_Intel", profileNamespace getVariable ["KPIN_Save_Intel", 0], true];
missionNamespace setVariable ["KPIN_CivRep", profileNamespace getVariable ["KPIN_Save_CivRep", 0], true];
missionNamespace setVariable ["KPIN_RepPenaltyCount", profileNamespace getVariable ["KPIN_Save_RepPenalties", 0], true];

// 2. World State
missionNamespace setVariable ["KPIN_DestroyedHQs", profileNamespace getVariable ["KPIN_Save_DestroyedHQs", 0], true];
missionNamespace setVariable ["KPIN_DestroyedRoadblocks", profileNamespace getVariable ["KPIN_Save_DestroyedRoadblocks", 0], true];
missionNamespace setVariable ["KPIN_FOB_Positions", profileNamespace getVariable ["KPIN_Save_FOBs", []], true];
missionNamespace setVariable ["KPIN_CurrentTier", profileNamespace getVariable ["KPIN_Save_Tier", 1], true];
missionNamespace setVariable ["KPIN_FixedInfrastructure", profileNamespace getVariable ["KPIN_Save_FixedInfra", []], true];

// 3. Lobby Parameter Lock
private _savedMode = profileNamespace getVariable ["KPIN_Save_BuildingMode", -1];
if (_savedMode == -1) then {
    private _lobbyParam = ["BuildingDamageMode", 0] call BIS_fnc_getParamValue;
    missionNamespace setVariable ["KPIN_LockedBuildingMode", _lobbyParam, true];
} else {
    missionNamespace setVariable ["KPIN_LockedBuildingMode", _savedMode, true];
};

diag_log "[KPIN LOAD]: Campaign state fully restored.";
