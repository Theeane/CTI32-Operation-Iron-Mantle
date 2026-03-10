/*
    Author: Theane (AGS Project)
    Description: Updates HUD and handles dynamic Notoriety visibility.
*/

if (!hasInterface) exitWith {};

disableSerialization;
private _display = uiNamespace getVariable ["AGS_ctrl_resBar", displayNull];
if (isNull _display) then { cutRsc ["AGS_ResourceBar", "PLAIN"]; _display = uiNamespace getVariable "AGS_ctrl_resBar"; };

[] spawn {
    disableSerialization;
    while {alive player} do {
        private _display = uiNamespace getVariable ["AGS_ctrl_resBar", displayNull];
        if (isNull _display) exitWith {};

        // 1. Update Core Resources
        (_display displayCtrl 9001) ctrlSetText format ["SUP: %1", missionNamespace getVariable ["AGS_res_supplies", 0]];
        (_display displayCtrl 9002) ctrlSetText format ["INT: %1", missionNamespace getVariable ["AGS_res_intel", 0]];

        // 2. BASE CHECK (FOB/MOB visibility)
        // Adjust these to match your actual base objects or markers
        private _nearBase = (player distance (getMarkerPos "AGS_base_marker") < 100) || 
                            { count (nearestObjects [player, ["Land_Cargo_HQ_V1_F", "Land_Medevac_house_V1_F"], 50]) > 0 };

        private _notoGroup = _display displayCtrl 9200;
        if (_nearBase) then {
            _notoGroup ctrlShow true;
            (_display displayCtrl 9003) ctrlSetText format ["HEAT: %1%2", missionNamespace getVariable ["AGS_res_notoriety", 0], "%"];
        } else {
            _notoGroup ctrlShow false;
        };

        // 3. Update The Eye
        private _icon = "media\icons\eye_red.paa";
        if (captive player) then {
            _icon = if (player getVariable ["AGS_isSuspicious", false]) then { "media\icons\eye_yellow.paa" } else { "media\icons\eye_green.paa" };
        };
        (_display displayCtrl 9004) ctrlSetText _icon;

        uiSleep 1;
    };
};
