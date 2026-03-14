sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

MWF_fnc_globalStateManager = {
    // Default global variables
    if (isNil "MWF_Global_Aggression") then {MWF_Global_Aggression = 1.0;};
    if (isNil "MWF_Global_PatrolDensity") then {MWF_Global_PatrolDensity = 1.0;};
    
    // Broadcast the global state to all players
    publicVariable "MWF_Global_Aggression";
    publicVariable "MWF_Global_PatrolDensity";

    // Function to activate the global effects for 15 minutes (900 seconds)
    _startDisruptEffects = {
        // Reduce global aggression and patrol density
        MWF_Global_Aggression = 0.7;
        MWF_Global_PatrolDensity = 0.5;
        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";

        // Wait for 15 minutes (900 seconds), then reset values
        sleep 900;

        // Reset values after disruption
        MWF_Global_Aggression = 1.0;
        MWF_Global_PatrolDensity = 1.0;
        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";
    };

    // Check if disruption has occurred (based on mission type)
    if (_this select 0 == "disrupt") then {
        // Trigger the disruption effect
        [] spawn {_startDisruptEffects};
    };
};
