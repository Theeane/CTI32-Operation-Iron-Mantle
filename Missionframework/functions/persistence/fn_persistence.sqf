/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Description: Core KPIN Persistence System.
    Handles: Zones, Digital Economy, CivRep, and Fixed Infrastructure.
*/

if (!isServer) exitWith {};

/**
 * MAIN SAVE FUNCTION
 */
KPIN_fnc_saveGame = {
    params [["_reason", "Auto-Save"]];

    // 1. Save Captured Zones
    private _allZones = missionNamespace getVariable ["KPIN_all_mission_zones", []];
    private _capturedZoneNames = [];
    
    {
        if (_x getVariable ["KPIN_isCaptured", false]) then {
            _capturedZoneNames pushBack (text _x); 
        };
    } forEach _allZones;
    
    profileNamespace setVariable ["KPIN_Save_Zones", _capturedZoneNames];

    // 2. Save Economy & Reputation (Digital Currency & CivRep)
    profileNamespace setVariable ["KPIN_Save_Supplies", missionNamespace getVariable ["KPIN_Supplies", 100]];
    profileNamespace setVariable ["KPIN_Save_Intel", missionNamespace getVariable ["KPIN_Intel", 0]];
    profileNamespace setVariable ["KPIN_Save_CivRep", missionNamespace getVariable ["KPIN_CivRep", 0]];
    profileNamespace setVariable ["KPIN_Save_RepPenalties", missionNamespace getVariable ["KPIN_RepPenaltyCount", 0]];

    // 3. Save Fixed Infrastructure (Roadblocks & HQ)
    private _infrastructure = missionNamespace getVariable ["KPIN_FixedInfrastructure", []];
    profileNamespace setVariable ["KPIN_Save_Infrastructure", _infrastructure];

    // 4. Save Mission Progress
    private _completedMissions = missionNamespace getVariable ["KPIN_completedMissions", []];
    profileNamespace setVariable ["KPIN_Save_Missions", _completedMissions];

    saveProfileNamespace;
    
    diag_log format ["[KPIN PERSISTENCE]: Saved. Reason: %1. Zones: %2. Intel: %3", _reason, count _capturedZoneNames, missionNamespace getVariable ["KPIN_Intel", 0]];
};

/**
 * LOAD FUNCTION
 */
KPIN_fnc_loadGame = {
    // 1. Load Economy & Reputation
    missionNamespace setVariable ["KPIN_Supplies", profileNamespace getVariable ["KPIN_Save_Supplies", 100], true];
    missionNamespace setVariable ["KPIN_Intel", profileNamespace getVariable ["KPIN_Save_Intel", 0], true];
    missionNamespace setVariable ["KPIN_CivRep", profileNamespace getVariable ["KPIN_Save_CivRep", 0], true];
    missionNamespace setVariable ["KPIN_RepPenaltyCount", profileNamespace getVariable ["KPIN_Save_RepPenalties", 0], true];

    // 2. Restore Zones
    private _savedCapturedZones = profileNamespace getVariable ["KPIN_Save_Zones", []];
    private _allZones = missionNamespace getVariable ["KPIN_all_mission_zones", []];
    
    {
        if (text _x in _savedCapturedZones) then {
            _x setVariable ["KPIN_isCaptured", true, true];
            _x setMarkerColor "ColorBLUFOR";
            _x setMarkerAlpha 1;
        };
    } forEach _allZones;

    // 3. Restore Fixed Infrastructure
    private _savedInfra = profileNamespace getVariable ["KPIN_Save_Infrastructure", []];
    missionNamespace setVariable ["KPIN_FixedInfrastructure", _savedInfra, true];

    // 4. Load Completed Missions
    private _savedMissions = profileNamespace getVariable ["KPIN_Save_Missions", []];
    missionNamespace setVariable ["KPIN_completedMissions", _savedMissions, true];

    diag_log "[KPIN PERSISTENCE]: World State Restored.";
};

// --- AUTOMATIC TRIGGERS ---

// Auto-save var 10:e minut
[
    { ["Scheduled Auto-Save"] call KPIN_fnc_saveGame; }, 
    600
] call CBA_fnc_addPerFrameHandler;

// Event-baserad sparning
["KPIN_missionCompleted", {
    params ["_missionID"];
    private _list = missionNamespace getVariable ["KPIN_completedMissions", []];
    _list pushBackUnique _missionID;
    missionNamespace setVariable ["KPIN_completedMissions", _list, true];
    ["Mission Completed: " + _missionID] call KPIN_fnc_saveGame;
}] call CBA_fnc_addEventHandler;

// Delayed Save för resurser (för att undvika spam)
KPIN_fnc_requestDelayedSave = {
    if (missionNamespace getVariable ["KPIN_savePending", false]) exitWith {};
    missionNamespace setVariable ["KPIN_savePending", true];
    
    [
        { 
            ["Resource Update"] call KPIN_fnc_saveGame; 
            missionNamespace setVariable ["KPIN_savePending", false];
        }, 
        [], 
        5 
    ] call CBA_fnc_waitAndExecute;
};
