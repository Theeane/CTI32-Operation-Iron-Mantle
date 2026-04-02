/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_terminal_redeploy
    Project: Military War Framework

    Description:
    Opens a redeploy map session for FOB/MOB fast travel.
    Markers are temporary and local to the client. Clicking near a valid marker
    redeploys the player to that location, then cleans up the session.
*/

if (!hasInterface) exitWith { false };

params [
    ["_mode", "OPEN", [""]],
    ["_payload", [], [[]]]
];

private _modeUpper = toUpper _mode;

switch (_modeUpper) do {
    case "OPEN": {
        if (!alive player) exitWith {
            [["REDEPLOY", "Cannot redeploy while incapacitated."], "warning"] call MWF_fnc_showNotification;
            false
        };

        if (vehicle player != player) exitWith {
            [["REDEPLOY", "Exit your vehicle before opening redeploy."], "warning"] call MWF_fnc_showNotification;
            false
        };

        missionNamespace setVariable ["MWF_CommandTerminal_Object", _payload param [0, missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull]]];
        missionNamespace setVariable ["MWF_CommandTerminal_User", player];
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "REDEPLOY"] call MWF_fnc_dataHub;
        true
    };

    case "CLEANUP": {
        private _notifyCancelled = _payload param [0, false, [true]];
        private _markers = missionNamespace getVariable ["MWF_Redeploy_Markers", []];
        {
            deleteMarkerLocal _x;
        } forEach _markers;

        onMapSingleClick "";

        missionNamespace setVariable ["MWF_Redeploy_Active", false];
        missionNamespace setVariable ["MWF_Redeploy_Targets", nil];
        missionNamespace setVariable ["MWF_Redeploy_Markers", nil];
        missionNamespace setVariable ["MWF_Redeploy_ClickRadius", nil];
        missionNamespace setVariable ["MWF_Redeploy_SessionId", nil];

        if (_notifyCancelled) then {
            systemChat "Redeploy cancelled.";
        };

        true
    };

    default { false };
};
