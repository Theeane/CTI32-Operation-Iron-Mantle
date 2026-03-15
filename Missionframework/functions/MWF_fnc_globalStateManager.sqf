/*
    Author: Theeane / Gemini Guide
    Function: MWF_fnc_globalStateManager
    Project: Military War Framework
    Description: 
    Manages global difficulty modifiers like aggression and patrol density.
    Includes cooldown logic for disruption effects.
*/

params [
    ["_mode", "", [""]]
];

// 1. Ensure global variables exist (Server side only)
if (isNil { missionNamespace getVariable "MWF_Global_Aggression" }) then {
    missionNamespace setVariable ["MWF_Global_Aggression", 1.0, true];
};
if (isNil { missionNamespace getVariable "MWF_Global_PatrolDensity" }) then {
    missionNamespace setVariable ["MWF_Global_PatrolDensity", 1.0, true];
};

// 2. Handle Disrupt Mode (from Quests)
if (_mode == "disrupt") then {
    // Prevent multiple overlaps by checking a cooldown flag
    if (missionNamespace getVariable ["MWF_Disrupt_Active", false]) exitWith {
        diag_log "[MWF] GlobalState: Disrupt already active, skipping overlap.";
    };

    [] spawn {
        missionNamespace setVariable ["MWF_Disrupt_Active", true, true];
        
        // Apply debuff to enemy forces
        missionNamespace setVariable ["MWF_Global_Aggression", 0.7, true];
        missionNamespace setVariable ["MWF_Global_PatrolDensity", 0.5, true];
        
        diag_log "[MWF] GlobalState: Enemy disrupted (900s). Aggression and Density reduced.";

        // Cooldown period (15 minutes / 900 seconds)
        uiSleep 900;

        // Reset to normal values
        missionNamespace setVariable ["MWF_Global_Aggression", 1.0, true];
        missionNamespace setVariable ["MWF_Global_PatrolDensity", 1.0, true];
        missionNamespace setVariable ["MWF_Disrupt_Active", false, true];
        
        diag_log "[MWF] GlobalState: Disrupt expired. Enemy forces returned to normal state.";
    };
};

true