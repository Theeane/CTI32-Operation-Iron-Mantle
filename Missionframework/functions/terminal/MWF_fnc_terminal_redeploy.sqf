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
        ["CLEANUP", [false]] call MWF_fnc_terminal_redeploy;

        if (!alive player) exitWith {
            [["REDEPLOY", "Cannot redeploy while incapacitated."], "warning"] call MWF_fnc_showNotification;
            false
        };

        if (vehicle player != player) exitWith {
            [["REDEPLOY", "Exit your vehicle before opening redeploy."], "warning"] call MWF_fnc_showNotification;
            false
        };

        private _targets = [];
        private _markerNames = [];
        private _sessionId = format ["%1_%2", floor diag_tickTime, floor random 100000];
        private _clickRadius = 40;

        private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
        private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
        private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
        if !(_mobPos isEqualTo [0,0,0]) then {
            _targets pushBack ["MOB", _mobName, _mobPos];
        };

        private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
        {
            _x params ["_marker", "_obj", ["_name", "FOB", [""]]];
            if (!isNull _obj) then {
                _targets pushBack ["FOB", _name, getPosATL _obj];
            };
        } forEach _registry;

        {
            if (_x getVariable ["MWF_isMobileRespawn", false] && {_x getVariable ["MWF_respawnAvailable", false]}) then {
                _targets pushBack ["MRU", "Mobile Respawn Unit", getPosATL _x];
            };
        } forEach vehicles;

        if (_targets isEqualTo []) exitWith {
            [["REDEPLOY", "No valid redeploy targets available."], "warning"] call MWF_fnc_showNotification;
            false
        };

        {
            _x params ["_kind", "_label", "_pos"];
            private _markerName = format ["MWF_Redeploy_%1_%2", _forEachIndex, _sessionId];
            private _marker = createMarkerLocal [_markerName, _pos];
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTextLocal _label;

            switch (_kind) do {
                case "MOB": {
                    _marker setMarkerTypeLocal "mil_flag";
                    _marker setMarkerColorLocal "ColorYellow";
                };
                case "MRU": {
                    _marker setMarkerTypeLocal "mil_warning";
                    _marker setMarkerColorLocal "ColorGreen";
                };
                default {
                    _marker setMarkerTypeLocal "mil_box";
                    _marker setMarkerColorLocal "ColorBlue";
                };
            };

            _markerNames pushBack _markerName;
        } forEach _targets;

        private _playerMarkerName = format ["MWF_Redeploy_Player_%1", _sessionId];
        private _playerMarker = createMarkerLocal [_playerMarkerName, getPosATL player];
        _playerMarker setMarkerShapeLocal "ICON";
        _playerMarker setMarkerTypeLocal "mil_triangle";
        _playerMarker setMarkerColorLocal "ColorBlue";
        _playerMarker setMarkerTextLocal "Du är här";
        _markerNames pushBack _playerMarkerName;

        missionNamespace setVariable ["MWF_Redeploy_Active", true];
        missionNamespace setVariable ["MWF_Redeploy_Targets", _targets];
        missionNamespace setVariable ["MWF_Redeploy_Markers", _markerNames];
        missionNamespace setVariable ["MWF_Redeploy_ClickRadius", _clickRadius];
        missionNamespace setVariable ["MWF_Redeploy_SessionId", _sessionId];

        onMapSingleClick "[_pos] call MWF_fnc_handleRedeployMapClick; true;";
        openMap [true, false];

        [["REDEPLOY", "Map opened. Click a MOB or FOB marker to redeploy."], "info"] call MWF_fnc_showNotification;

        [] spawn {
            waitUntil {
                uiSleep 0.1;
                !(missionNamespace getVariable ["MWF_Redeploy_Active", false]) || {!visibleMap}
            };

            if (missionNamespace getVariable ["MWF_Redeploy_Active", false]) then {
                ["CLEANUP", [true]] call MWF_fnc_terminal_redeploy;
            };
        };

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
