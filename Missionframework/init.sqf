/*
    Author: Theeane / Gemini Guide
    File: init.sqf
    Project: Military War Framework (MWF)
    Description: 
    The master entry point. Handles server-side startup and client-side bootstrap.
*/

// 1. Engine safety
enableSaving [false, false];

// --- SERVER INITIALIZATION ---
if (isServer) then {
    diag_log "[MWF] Server: Starting Global State Manager...";
    
    // Initialize economy, quests, and global variables
    ["INIT"] call MWF_fnc_globalStateManager;
    
    // Signal to all players that the server is ready
    missionNamespace setVariable ["MWF_ServerInitialized", true, true];
    missionNamespace setVariable ["MWF_ServerBootStage", "CRITICAL_RELEASED", true];
    
    diag_log "[MWF] Server: Initialization complete and broadcasted.";
};

// --- CLIENT INITIALIZATION ---
if (hasInterface) then {
    diag_log "[MWF] Client: Waiting for server to be ready...";

    private _localBootDeadline = diag_tickTime + 120;
    waitUntil {
        uiSleep 0.25;
        (missionNamespace getVariable ["MWF_ServerInitialized", false]) || 
        {diag_tickTime >= _localBootDeadline}
    };

    if (missionNamespace getVariable ["MWF_ServerInitialized", false]) then {
        diag_log "[MWF] Client: Server ready. Starting intro cinematic.";
        
        // Starts the intro movie we checked earlier
        [] spawn MWF_fnc_playIntroCinematic;
    } else {
        diag_log "[MWF] Client: WARNING! Server initialization timed out.";
    };

    missionNamespace setVariable ["MWF_LocalInitReady", true];
};

diag_log "[MWF] init.sqf execution finished.";