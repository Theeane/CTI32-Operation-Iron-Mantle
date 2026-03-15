// Author: Theane / ChatGPT
// Project: Military War Framework

params ["_mode"];

// Default global variables
if (isNil "MWF_Global_Aggression") then { MWF_Global_Aggression = 1.0; };
if (isNil "MWF_Global_PatrolDensity") then { MWF_Global_PatrolDensity = 1.0; };

// Broadcast state
publicVariable "MWF_Global_Aggression";
publicVariable "MWF_Global_PatrolDensity";

if (_mode == "disrupt") then {

    [] spawn {

        MWF_Global_Aggression = 0.7;
        MWF_Global_PatrolDensity = 0.5;

        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";

        sleep 900;

        MWF_Global_Aggression = 1.0;
        MWF_Global_PatrolDensity = 1.0;

        publicVariable "MWF_Global_Aggression";
        publicVariable "MWF_Global_PatrolDensity";

    };

};
