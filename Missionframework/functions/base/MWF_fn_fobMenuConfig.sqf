/*
    Author: Theeane / Gemini
    Function: MWF_fnc_fobMenuConfig
    Project: Military War Framework

    Description:
    Centralized configuration for FOB operations and global mission rules.
    This file defines the logic for digital currency, asset requirements, 
    and operation cooldowns.
*/

if (!isServer) exitWith {};

diag_log "[MWF] Config: Initializing FOB and Mission Global Settings...";

// 1. Digital Currency & Intel Rules
// Supply and intel are strictly digital; no physical objects.
missionNamespace setVariable ["MWF_Economy_DigitalOnly", true, true];
missionNamespace setVariable ["MWF_Intel_CleanupTimer", 900, true]; // 15 mins before dropped intel disappears

// 2. FOB Asset Configuration
// Defines the two primary options for starting a FOB: Truck or Box.
missionNamespace setVariable ["MWF_FOB_AssetOptions", [
    ["Truck", "B_Truck_01_box_F"], 
    ["Box", "B_Slingload_01_Cargo_F"]
], true];

// 3. Asset Requirements & Tier Logic
// Rearm trucks are locked until the area reaches Tier 3.
missionNamespace setVariable ["MWF_FOB_RearmRequiredTier", 3, true];
missionNamespace setVariable ["MWF_FOB_MinCompletionTier", 3, true]; // After 50% completion, tier cannot drop below 3

// 4. Grand Operation Cooldowns
// All Grand Ops have a strictly enforced 30-minute cooldown.
missionNamespace setVariable ["MWF_Op_GrandOpCooldown", 1800, true]; 

// 5. Repack & Deployment Logic
// Settings for the FOB "Repack" and "Deploy" sequences.
missionNamespace setVariable ["MWF_FOB_RepackTime", 5, true]; // Time in seconds to repack a base
missionNamespace setVariable ["MWF_FOB_DeploymentRadius", 50, true]; // Radius for the loadout zone

diag_log "[MWF] Config: FOB Menu Configuration loaded successfully.";
true