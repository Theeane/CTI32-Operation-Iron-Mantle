/*
    Author: Theeane / Gemini Guide
    File: init.sqf
    Project: Military War Framework (MWF)
    Description: 
    Initializes the client-side environment. 
    Synchronizes with the server initialization before allowing client scripts to run.
*/

// 1. Wait for server to finish its critical boot sequence (Presets, Economy, Systems)
// This ensures that global variables like MWF_Supplies are available before UI starts.
waitUntil { missionNamespace getVariable ["MWF_ServerInitialized", false] };

// 2. Log start of client initialization
diag_log "[MWF] INFO: Client initialization started.";

/* NOTE: 
    Individual function preprocessing (preprocessFileLineNumbers) has been removed.
    All functions are now handled via CfgFunctions.hpp using the 'MWF' tag.
    Access them using: MWF_fnc_functionName
*/

// 3. Client-side setup or local variables can be initialized here
// (Keep this clean to avoid conflicts with initPlayerLocal.sqf)

// 4. Log completion
diag_log "[MWF] SUCCESS: Client-side initialization complete.";