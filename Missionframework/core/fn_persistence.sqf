/*
    Author: Theane using Gemini (AGS Project)
    Description: Advanced CBA-integrated Persistence System.
    Handles saving/loading of Zones (including Hidden), Economy, and Mission Progress.
    Language: English
*/

if (!isServer) exitWith {};

/**
 * MAIN SAVE FUNCTION
 * Can be called manually: [] call AGS_fnc_saveGame;
 * Use this when: 
 * - A zone is captured (including Hidden Zones)
 * - A mission is completed
 * - Large amounts of Intel/Supplies are gained
 */
AGS_fnc_saveGame = {
    params [["_reason", "Auto-Save"]];

    // 1. Save Captured Zones (Normal & Hidden)
    // We filter all zones that have been marked as captured
    private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
    private _capturedZoneNames = [];
    
    {
        if (_x getVariable ["AGS_isCaptured", false]) then {
            _capturedZoneNames pushBack (text _x); 
        };
    } forEach _allZones;
    
    profileNamespace setVariable ["AGS_Save_Zones", _capturedZoneNames];

    // 2. Save Economy (Supplies & Intel)
    private _supplies = missionNamespace getVariable ["AGS_res_supplies", 0];
    private _intel = missionNamespace getVariable ["AGS_res_intel", 0];
    
    profileNamespace setVariable ["AGS_Save_Supplies", _supplies];
    profileNamespace setVariable ["AGS_Save_Intel", _intel];

    // 3. Save Mission Progress (Optional: Store completed mission IDs)
    private _completedMissions = missionNamespace getVariable ["AGS_completedMissions", []];
    profileNamespace setVariable ["AGS_Save_Missions", _completedMissions];

    // Commit to disk (CBA/Arma standard)
    saveProfileNamespace;
    
    diag_log format ["AGS Persistence: Game Saved. Reason: %1. Zones: %2. Supplies: %3", _reason, count _capturedZoneNames, _supplies];
};

/**
 * LOAD FUNCTION
 * Should be called during init, AFTER factions and zones are initialized.
 */
AGS_fnc_loadGame = {
    // 1. Load Economy Resources
    private _savedSupplies = profileNamespace getVariable ["AGS_Save_Supplies", 100];
    private _savedIntel = profileNamespace getVariable ["AGS_Save_Intel", 0];
    
    missionNamespace setVariable ["AGS_res_supplies", _savedSupplies, true];
    missionNamespace setVariable ["AGS_res_intel", _savedIntel, true];

    // 2. Load and Restore Zones
    private _savedCapturedZones = profileNamespace getVariable ["AGS_Save_Zones", []];
    private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
    
    {
        if (text _x in _savedCapturedZones) then {
            _x setVariable ["AGS_isCaptured", true, true];
            // Visual feedback: Update marker to blue
            _x setMarkerColor "ColorBLUFOR";
            _x setMarkerAlpha 1; // Ensure hidden zones become visible if captured
        };
    } forEach _allZones;

    // 3. Load Completed Missions
    private _savedMissions = profileNamespace getVariable ["AGS_Save_Missions", []];
    missionNamespace setVariable ["AGS_completedMissions", _savedMissions, true];

    diag_log "AGS Persistence: World State Restored from Profile.";
};

// --- AUTOMATIC TRIGGERS ---

// A. Auto-save every 10 minutes using CBA PerFrameHandler
[
    { ["Scheduled Auto-Save"] call AGS_fnc_saveGame; }, 
    600
] call CBA_fnc_addPerFrameHandler;

// B. Event-based saving (Example: Save when a mission is marked complete)
["AGS_missionCompleted", {
    params ["_missionID"];
    private _list = missionNamespace getVariable ["AGS_completedMissions", []];
    _list pushBackUnique _missionID;
    missionNamespace setVariable ["AGS_completedMissions", _list, true];
    
    ["Mission Completed: " + _missionID] call AGS_fnc_saveGame;
}] call CBA_fnc_addEventHandler;

// C. Resource Update Saving (Save when Intel/Supplies change significantly)
// We add a small delay to avoid "save-spamming" if many items are picked up at once
AGS_fnc_requestDelayedSave = {
    if (missionNamespace getVariable ["AGS_savePending", false]) exitWith {};
    missionNamespace setVariable ["AGS_savePending", true];
    
    [
        { 
            ["Resource Update"] call AGS_fnc_saveGame; 
            missionNamespace setVariable ["AGS_savePending", false];
        }, 
        [], 
        5 // 5 second delay before saving
    ] call CBA_fnc_waitAndExecute;
};
