/*
    File: initServer.sqf
    Language: English
*/

// 1. Setup Globals
[] call AGS_fnc_initGlobals;

// 2. Scan Map for Zones
[] call AGS_fnc_scanZones;

// 3. Start Economy Loop
[] spawn AGS_fnc_economy;

diag_log "AGS Server: Initialization Complete.";
