/*
    Author: Theane / ChatGPT
    Function: MWF_fn_updateResourceUI
    Project: Military War Framework

    Description:
    Handles UI logic for updating the resource bar HUD.
    Strict migration from original fn_updateResourceUI.sqf.
*/

disableSerialization;

// Start the HUD layer
"MWF_resLayer" cutRsc ["MWF_ResourceBar", "PLAIN"];

while {true} do {
    private _ui = uiNamespace getVariable ["MWF_ctrl_resBar", displayNull];
    
    if (!isNull _ui) then {
        // 1. Fetch Current Values
        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
        private _intel = missionNamespace getVariable ["MWF_res_intel", 0];
        private _heat = missionNamespace getVariable ["MWF_res_notoriety", 0];
        
        // 2. Update Basic Resources
        (_ui displayCtrl 9001) ctrlSetText format ["SUP: %1", _supplies];
        (_ui displayCtrl 9002) ctrlSetText format ["INT: %1", _intel];
        (_ui displayCtrl 9003) ctrlSetText format ["HEAT: %1%%", _heat];

        // 3. Logic: Notoriety/Heat Visibility
        // Show Heat panel only if player is near a FOB or has active Heat
        private _isNearFOB = player getVariable ["MWF_isNearFOB", false];
        if (_heat > 0 || _isNearFOB) then {
            (_ui displayCtrl 9200) ctrlSetFade 0;
        } else {
            (_ui displayCtrl 9200) ctrlSetFade 1;
        };
        (_ui displayCtrl 9200) ctrlCommit 0.5;

        // 4. Logic: Undercover "The Eye"
        private _isUndercover = player getVariable ["MWF_isUndercover", false];
        private _eyeCtrl = (_ui displayCtrl 9004);
        
        if (_isUndercover) then {
            _eyeCtrl ctrlSetText "media\icons\eye_green.paa";
            _eyeCtrl ctrlSetTooltip "You are currently Undercover";
        } else {
            _eyeCtrl ctrlSetText "media\icons\eye_red.paa";
            _eyeCtrl ctrlSetTooltip "You are EXPOSED";
        };
    };

    uiSleep 2; // Tick rate
};
