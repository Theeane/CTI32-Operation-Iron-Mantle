/*
    Author: Gemini Guide
    Project: Military War Framework (MWF)
    Description: 
    Registry of functions successfully migrated to the MWF_fn_ naming convention.
    This file acts as a manifest for the current migration status.
*/

if (!isServer) exitWith {};

private _migratedCore = [
    "MWF_fn_initGlobals",       // Initializes digital economy and campaign params
    "MWF_fn_economy",           // Central digital resource management
    "MWF_fn_initSystems",       // Framework core state initialization
    "MWF_fn_initZones",         // Zone capture loop initiator
    "MWF_fn_buildMode",         // Local placement and digital cost handling
    "MWF_fn_finalizeBuild",     // Server-side object spawn and supply sync
    "MWF_fn_presetManager",     // Faction and persistence management
    "MWF_fn_limitZeusAssets",   // Asset filtering for build modes
    "MWF_fn_openBaseArchitect", // Local Zeus radius-locked construction
    "MWF_fn_openBuildZeus"      // Resource-integrated Zeus build session
];

// Log current status to RPT for debugging
diag_log "------------------------------------------------";
diag_log "[MWF] Migration Status: CORE & BASE Section";
{
    diag_log format ["[MWF] Registered Migrated Function: %1", _x];
} forEach _migratedCore;
diag_log format ["[MWF] Total functions migrated in this session: %1", count _migratedCore];
diag_log "------------------------------------------------";

true
