/*
    Author: Theane (AGS Project)
    Description: Updates HUD and handles dynamic fading for the Undercover Eye.
    Language: English
*/

if (!hasInterface) exitWith {};

disableSerialization;
private _display = uiNamespace getVariable ["AGS_ctrl_resBar", displayNull];
if (isNull _display) then { cutRsc ["AGS_ResourceBar", "PLAIN"]; _display = uiNamespace getVariable "AGS_ctrl_resBar"; };

[] spawn {
    disableSerialization;
    private _lastStatus = "";
    private _fadeTime = 0;

    while {alive player} do {
        private _display = uiNamespace getVariable ["AGS_ctrl_resBar", displayNull];
        if (isNull _display) exitWith {};

        // 1. Resources (Standard update)
        (_display displayCtrl 9001) ctrlSetText format ["SUP: %1", missionNamespace getVariable ["AGS_res_supplies", 0]];
        (_display displayCtrl 9002) ctrlSetText format ["INT: %1", missionNamespace getVariable ["AGS_res_intel", 0]];

        // 2. Base Proximity for Notoriety
        private _isAtBase = (player distance (getMarkerPos "AGS_base_marker") < 150);
        private _notoGroup = _display displayCtrl 9200;
        if (_isAtBase) then {
            _notoGroup ctrlShow true;
            (_display displayCtrl 9003) ctrlSetText format ["HEAT: %1%2", missionNamespace getVariable ["AGS_res_notoriety", 0], "%"];
        } else {
            _notoGroup ctrlShow false;
        };

        // 3. Dynamic Undercover Eye (Fade Logic)
        private _eyeGroup = _display displayCtrl 9100;
        private _eyePic = _display displayCtrl 9004;
        private _currentStatus = "red";

        if (captive player) then {
            _currentStatus = if (player getVariable ["AGS_isSuspicious", false]) then { "yellow" } else { "green" };
        };

        private _iconPath = format ["media\icons\eye_%1.paa", _currentStatus];
        _eyePic ctrlSetText _iconPath;

        // Check for changes
        if (_currentStatus != _lastStatus) then {
            _lastStatus = _currentStatus;
            _fadeTime = serverTime + 10; // Reset 10s timer on change
            _eyeGroup ctrlSetFade 0;     // Make fully visible
            _eyeGroup ctrlCommit 0.5;    // Smooth fade in
        };

        // Handle Fading
        if (serverTime > _fadeTime) then {
            if (ctrlFade _eyeGroup == 0) then {
                _eyeGroup ctrlSetFade 0.7; // Fade to 70% transparent (don't hide completely for debug)
                _eyeGroup ctrlCommit 2;    // Slow fade out
            };
        };

        uiSleep 0.5;
    };
};
