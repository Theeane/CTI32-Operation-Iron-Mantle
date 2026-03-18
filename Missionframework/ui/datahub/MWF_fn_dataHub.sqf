/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_dataHub
    Project: Military War Framework

    Description:
    Standalone prototype controller for the unified command/data map.
    This is intentionally modular so the later GUI-tool pass can replace the shell
    while reusing the mode/filter and dataset logic.
*/

params [
    ["_mode", "OPEN", [""]],
    ["_payload", nil]
];

private _modeUpper = toUpper _mode;

switch (_modeUpper) do {
    case "OPEN": {
        if (!hasInterface) exitWith { false };
        createDialog "MWF_RscDataHub";
        private _display = findDisplay 12200;
        if (isNull _display) exitWith { false };

        uiNamespace setVariable ["MWF_DataHub_Display", _display];
        uiNamespace setVariable ["MWF_DataHub_Mode", "ZONES"];
        uiNamespace setVariable ["MWF_DataHub_Markers", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", nil];

        ["SET_MODE", "ZONES"] call MWF_fnc_dataHub;
        true
    };

    case "CLOSE": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (!isNull _display) then {
            closeDialog 0;
        };

        { deleteMarkerLocal _x; } forEach (uiNamespace getVariable ["MWF_DataHub_Markers", []]);
        uiNamespace setVariable ["MWF_DataHub_Markers", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", nil];
        true
    };

    case "SET_MODE": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _newMode = if (_payload isEqualType "") then { toUpper _payload } else { toUpper (_payload param [0, "", [""]]) };
        if !(_newMode in ["ZONES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY"]) exitWith { false };
        [_display, _newMode] call MWF_fnc_refreshDataMap;
        true
    };

    case "MAP_CLICK": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };
        if !((uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"]) isEqualTo "REDEPLOY") exitWith { false };

        private _mapCtrl = _display displayCtrl 12205;
        if (isNull _mapCtrl) exitWith { false };

        private _mouse = _payload;
        if !(_mouse isEqualType []) exitWith { false };

        private _worldPos = _mapCtrl ctrlMapScreenToWorld _mouse;
        private _entries = uiNamespace getVariable ["MWF_DataHub_Entries", []];
        private _nearest = [];
        private _bestDistance = 999999;

        {
            _x params ["_kind", "_label", "_pos", "_meta"];
            if (_kind isEqualTo "RESPAWN") then {
                private _dist = _worldPos distance2D _pos;
                if (_dist < _bestDistance) then {
                    _bestDistance = _dist;
                    _nearest = _x;
                };
            };
        } forEach _entries;

        if (_nearest isEqualTo [] || {_bestDistance > 75}) exitWith {
            private _statusCtrl = _display displayCtrl 12206;
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText "Redeploy: click closer to a valid respawn point.";
            };
            false
        };

        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", _nearest];
        private _statusCtrl = _display displayCtrl 12206;
        if (!isNull _statusCtrl) then {
            _statusCtrl ctrlSetText format ["Redeploy target selected: %1", _nearest param [1, "Unknown"]];
        };
        true
    };

    case "ACTION": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        if ((uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"]) isEqualTo "REDEPLOY") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedRespawn", []];
            if (_selected isEqualTo []) then {
                private _statusCtrl = _display displayCtrl 12206;
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText "Redeploy: select a respawn point on the map first.";
                };
                false
            } else {
                private _statusCtrl = _display displayCtrl 12206;
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText format ["Redeploy target ready for integration: %1", _selected param [1, "Unknown"]];
                };
                true
            }
        };

        ["CLOSE"] call MWF_fnc_dataHub;
        true
    };

    default { false };
};
