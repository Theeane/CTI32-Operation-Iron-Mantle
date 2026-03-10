/*
    Author: Theane (AGS Project)
    Description: Updates HUD and handles conditional visibility for Notoriety.
    Language: English
*/

if (!hasInterface) exitWith {};

disableSerialization;
// Ensure display is active
if (isNull (uiNamespace getVariable ["AGS_ctrl_resBar", displayNull])) then {
    cutRsc ["AGS_ResourceBar", "PLAIN"];
};

[] spawn {
    disableSerialization;
    while {alive player} do {
        private _display = uiNamespace getVariable ["AGS_ctrl_resBar", displayNull];
        if (isNull _display) exitWith {};

        // 1. Core Resources (Always Updated)
        (_display displayCtrl 9001) ctrlSetText format ["SUP: %1", missionNamespace getVariable ["AGS_res_supplies", 0]];
        (_display displayCtrl 9002) ctrlSetText format ["INT: %1", missionNamespace getVariable ["AGS_res_intel", 0]];

        // 2. Base Proximity Check for Heat (Notoriety)
        // Check if player is near a base marker or specific HQ objects
        private _isAtBase = (player distance (getMarkerPos "AGS_base_marker") < 150) || 
                            { count (nearestObjects [player, ["Land_Cargo_HQ_V1_F", "Land_InfoTerminal_01_F"], 50]) > 0 };

        private _notoGroup = _display displayCtrl 9200;
        if (_isAtBase) then {
            _notoGroup ctrlShow true;
            (_display displayCtrl 9003) ctrlSetText format ["HEAT: %1%2", missionNamespace getVariable ["AGS_res_notoriety", 0], "%"];
        } else {
            _notoGroup ctrlShow false;
        };

        // 3. Undercover Eye Status (Always Updated)
        private _icon = "media\icons\eye_red.paa"; // Default: Visible/Combat
        
        if (captive player) then {
            // Check if suspiciously geared (set in fn_undercoverHandler.sqf)
            if (player getVariable ["AGS_isSuspicious", false]) then {
                _icon = "media\icons\eye_yellow.paa"; // Questionable
            } else {
                _icon = "media\icons\eye_green.paa"; // Full Undercover
            };
        } else {
            // Not captive = Known rebel/enemy
            _icon = "media\icons\eye_red.paa";
        };
        
        (_display displayCtrl 9004) ctrlSetText _icon;

        uiSleep 0.5; // High frequency for better debug feedback
    };
};
