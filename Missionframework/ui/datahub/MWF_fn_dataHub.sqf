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

        private _initialMode = "ZONES";
        if (_payload isEqualType "") then {
            _initialMode = toUpper _payload;
        } else {
            if (_payload isEqualType []) then {
                _initialMode = toUpper (_payload param [0, "ZONES", [""]]);
            };
        };

        if !(_initialMode in ["ZONES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY", "SUPPORT"]) then {
            _initialMode = "ZONES";
        };

        createDialog "MWF_RscDataHub";
        private _display = findDisplay 12200;
        if (isNull _display) exitWith { false };

        uiNamespace setVariable ["MWF_DataHub_Display", _display];
        uiNamespace setVariable ["MWF_DataHub_Mode", _initialMode];
        uiNamespace setVariable ["MWF_DataHub_Markers", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", nil];
        uiNamespace setVariable ["MWF_DataHub_ViewStack", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        _display displayAddEventHandler ["KeyDown", { params ["_display", "_dikCode"]; if (_dikCode isEqualTo 1) exitWith { if !(["BACK"] call MWF_fnc_dataHub) then { ["CLOSE"] call MWF_fnc_dataHub; }; true }; false }];
        _display displayAddEventHandler ["MouseButtonDown", { params ["_display", "_button"]; if (_button isEqualTo 1) exitWith { ["BACK"] call MWF_fnc_dataHub; true }; false }];

        ["SET_MODE", _initialMode] call MWF_fnc_dataHub;
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
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        uiNamespace setVariable ["MWF_DataHub_ViewStack", []];
        true
    };

    case "SET_MODE": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _newMode = if (_payload isEqualType "") then { toUpper _payload } else { toUpper (_payload param [0, "", [""]]) };
        if !(_newMode in ["ZONES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY", "SUPPORT"]) exitWith { false };
        private _currentMode = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        if !(_newMode isEqualTo _currentMode) then { private _stack = uiNamespace getVariable ["MWF_DataHub_ViewStack", []]; _stack pushBack _currentMode; uiNamespace setVariable ["MWF_DataHub_ViewStack", _stack]; };
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        [_display, _newMode] call MWF_fnc_refreshDataMap;
        true
    };

    case "MAP_CLICK": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };
        private _mapCtrl = _display displayCtrl 12205;
        if (isNull _mapCtrl) exitWith { false };
        private _mouse = _payload;
        if !(_mouse isEqualType []) exitWith { false };
        private _worldPos = _mapCtrl ctrlMapScreenToWorld _mouse;
        private _entries = uiNamespace getVariable ["MWF_DataHub_Entries", []];
        private _nearest = [];
        private _bestDistance = 999999;
        private _modeNow = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        {
            _x params ["_kind", "_label", "_pos", "_meta"];
            if ((_modeNow isEqualTo "REDEPLOY" && {_kind isEqualTo "RESPAWN"}) || (_modeNow isEqualTo "SIDE_MISSIONS" && {_kind isEqualTo "SIDE_MISSION"}) || (_modeNow isEqualTo "MAIN_OPERATIONS" && {_kind isEqualTo "MAIN_OPERATION"}) || (_modeNow isEqualTo "SUPPORT" && {_kind isEqualTo "SUPPORT"})) then {
                private _dist = _worldPos distance2D _pos;
                if (_dist < _bestDistance) then { _bestDistance = _dist; _nearest = _x; };
            };
        } forEach _entries;
        if (_nearest isEqualTo [] || {_bestDistance > 75}) exitWith { false };
        private _statusCtrl = _display displayCtrl 12206;
        private _infoCtrl = _display displayCtrl 12216;
        switch _modeNow do {
            case "REDEPLOY": {
                uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", _nearest];
                if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Redeploy target selected: %1", _nearest param [1, "Unknown"]]; };
            };
            default {
                uiNamespace setVariable ["MWF_DataHub_SelectedEntry", _nearest];
                private _meta = _nearest param [3, createHashMap, [createHashMap]];
                if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Selected: %1", _nearest param [1, "Unknown"]]; };
                if (!isNull _infoCtrl) then {
                    if (_modeNow isEqualTo "SUPPORT") then { _infoCtrl ctrlSetText format ["%1
%2", _nearest param [1, "Support"], _meta getOrDefault ["description", ""]]; } else { _infoCtrl ctrlSetText format ["%1
%2", _nearest param [1, "Entry"], _meta getOrDefault ["description", _meta getOrDefault ["effectText", ""]]]; };
                };
            };
        };
        true
    };

    case "BACK": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };
        private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
        if !(_selected isEqualTo []) exitWith {
            uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
            private _statusCtrl = _display displayCtrl 12206;
            private _infoCtrl = _display displayCtrl 12216;
            if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Mode: %1", [uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"], "_", " "] call BIS_fnc_replaceString]; };
            if (!isNull _infoCtrl) then { _infoCtrl ctrlSetText ""; };
            true
        };
        [] call MWF_fnc_uiGoBack
    };

    case "ACTION": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };
        private _modeNow = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        if (_modeNow isEqualTo "SUPPORT") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
            if (_selected isEqualTo []) exitWith { false };
            private _meta = _selected param [3, createHashMap, [createHashMap]];
            ["BUILD_UNIT", _meta getOrDefault ["index", 1], player] call MWF_fnc_terminal_support;
            true
        };
        if (_modeNow isEqualTo "REDEPLOY") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedRespawn", []];
            if (_selected isEqualTo []) then {
                private _statusCtrl = _display displayCtrl 12206;
                if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText "Redeploy: select a respawn point on the map first."; };
                false
            } else {
                private _statusCtrl = _display displayCtrl 12206;
                if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Redeploy target ready for integration: %1", _selected param [1, "Unknown"]]; };
                true
            }
        };
        ["CLOSE"] call MWF_fnc_dataHub;
        true
    };

    case "ACTION_SECONDARY": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };
        if !((uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"]) isEqualTo "SUPPORT") exitWith { ["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub; true };
        private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
        if (_selected isEqualTo []) exitWith { false };
        private _meta = _selected param [3, createHashMap, [createHashMap]];
        ["BUILD_GROUP", _meta getOrDefault ["index", 1], player] call MWF_fnc_terminal_support;
        true
    };

    default { false };
};
