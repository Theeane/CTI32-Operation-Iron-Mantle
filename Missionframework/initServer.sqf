/*
    Author: Theeane / Gemini Guide
    File: initServer.sqf
    Project: Military War Framework (MWF)
    Description: 
    Initializes the server-side environment. 
    Sets up core variables, starts background loops, and signals client readiness.
*/

if (!isServer) exitWith {};

diag_log "[MWF] INFO: Server-side initialization started.";

// 1. Initialize Global Variables and Economy
// This replaces manual assignments to ensure lobby parameters are respected.
[] call MWF_fnc_initGlobals;

// 2. Initialize Core Systems
// Sets up zones, infrastructure, and faction presets.
[] call MWF_fnc_initSystems;
[] call MWF_fnc_presetManager;

// 3. Start Background Loops
// Starts the digital economy income loop and zone monitoring.
[] spawn MWF_fnc_economy;
[] call MWF_fnc_initZones;

// 4. Mission Logic
// You can add logic here to start the first mission or check save-game status.
// [] call MWF_fnc_generateInitialMission;

// 5. Signal Readiness
// This flag allows clients (init.sqf / initPlayerLocal.sqf) to proceed.
missionNamespace setVariable ["MWF_ServerInitialized", true, true];

diag_log "[MWF] SUCCESS: Server initialization complete. Framework is ready.";