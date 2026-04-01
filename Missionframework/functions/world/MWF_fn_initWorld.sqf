/*
    Author: OpenAI / Theane
    Function: MWF_fn_initWorld
    Project: Military War Framework

    Description:
    Server-side world bootstrap orchestrator.
    Starts the strategic runtime chain after globals, presets, MOB assets, and zone manager startup
    are already underway.

    Goals:
    - wake the economy loop
    - wake infrastructure/HQ-roadblock bootstrap
    - wake world + threat managers
    - wake mission/main-op runtime
    - restore FOB/session state and guarantee an initial FOB asset on fresh starts
*/

if (!isServer) exitWith { false };
if (missionNamespace getVariable ["MWF_InitWorldStarted", false]) exitWith { true };

missionNamespace setVariable ["MWF_InitWorldStarted", true, true];

// Load campaign save before dependent runtime systems if it has not already been applied.
if !(missionNamespace getVariable ["MWF_CampaignLoadApplied", false]) then {
    if (!isNil "MWF_fnc_loadGame") then {
        [] call MWF_fnc_loadGame;
    };
    missionNamespace setVariable ["MWF_CampaignLoadApplied", true, true];
};

// Restore any saved FOBs before deciding whether a fresh starting FOB asset is needed.
if (!isNil "MWF_fnc_restoreFOBs") then {
    [] call MWF_fnc_restoreFOBs;
};

if (!isNil "MWF_fnc_spawnInitialFOBAsset") then {
    [] call MWF_fnc_spawnInitialFOBAsset;
};

if (!isNil "MWF_fnc_infrastructureManager") then {
    ["INIT"] call MWF_fnc_infrastructureManager;
};

if (!isNil "MWF_fnc_spawnManager") then {
    ["BOOTSTRAP"] call MWF_fnc_spawnManager;
};

if (!isNil "MWF_fnc_economy") then {
    [] spawn MWF_fnc_economy;
};

if (!isNil "MWF_fnc_worldManager") then {
    [] spawn MWF_fnc_worldManager;
};

if (!isNil "MWF_fnc_threatManager") then {
    [] spawn MWF_fnc_threatManager;
};

if (!isNil "MWF_fnc_initMissionSystem") then {
    [] spawn MWF_fnc_initMissionSystem;
};

if (!isNil "MWF_fnc_initCampaignAnalytics") then {
    [] call MWF_fnc_initCampaignAnalytics;
};

if (!isNil "MWF_fnc_restoreSession") then {
    [] call MWF_fnc_restoreSession;
};

true
