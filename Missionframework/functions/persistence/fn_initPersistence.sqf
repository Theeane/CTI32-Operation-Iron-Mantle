/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_initPersistence
    Description: Initializes the persistence engine, auto-save loops, and delayed save logic.
    Language: English
*/

if (!isServer) exitWith {};

// 1. Start the 10-minute auto-save loop via CBA
[
    { ["Scheduled Auto-Save"] call KPIN_fnc_saveGame; }, 
    600
] call CBA_fnc_addPerFrameHandler;

// 2. Define the Delayed Save function
// This prevents the server from saving multiple times per second during heavy resource pickup
KPIN_fnc_requestDelayedSave = {
    if (missionNamespace getVariable ["KPIN_savePending", false]) exitWith {};
    missionNamespace setVariable ["KPIN_savePending", true];
    
    [
        { 
            ["Resource Update"] call KPIN_fnc_saveGame; 
            missionNamespace setVariable ["KPIN_savePending", false];
        }, 
        [], 
        5 // 5-second buffer
    ] call CBA_fnc_waitAndExecute;
};

diag_log "[KPIN PERSISTENCE]: Persistence engine and auto-save loop initialized.";
