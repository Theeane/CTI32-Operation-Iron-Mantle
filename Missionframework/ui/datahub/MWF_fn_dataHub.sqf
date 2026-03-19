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

private _renderSelection = {
    params ["_display", ["_entry", [], [[]]]];
    if (isNull _display) exitWith { false };

    private _titleCtrl = _display displayCtrl 12209;
    private _detailCtrl = _display displayCtrl 12216;
    private _acceptCtrl = _display displayCtrl 12217;
    private _statusCtrl = _display displayCtrl 12206;
    if (isNull _titleCtrl || {isNull _detailCtrl} || {isNull _acceptCtrl}) exitWith { false };

    if (_entry isEqualTo []) then {
        _titleCtrl ctrlSetText "Select an entry";
        _detailCtrl ctrlSetStructuredText parseText "<t size='0.9'>Click a mission, main operation, or respawn marker on the map to inspect it.</t>";
        _acceptCtrl ctrlShow false;
        _acceptCtrl ctrlEnable false;
        true
    } else {
        _entry params ["_kind", "_label", "_pos", ["_meta", createHashMap, [createHashMap]]];

        private _title = _meta getOrDefault ["title", _label];
        private _description = _meta getOrDefault ["description", "No description available."];
        private _statusText = _meta getOrDefault ["statusText", ""];
        private _tooltipText = _meta getOrDefault ["tooltipText", ""];
        private _zoneName = _meta getOrDefault ["zoneName", ""];
        private _rewardText = _meta getOrDefault ["rewardText", ""];
        private _effectText = _meta getOrDefault ["effectText", ""];
        private _fallbackText = _meta getOrDefault ["fallbackText", ""];
        private _acceptLabel = _meta getOrDefault ["acceptLabel", "Accept"];
        private _isAvailable = _meta getOrDefault ["isAvailable", false];

        _titleCtrl ctrlSetText _title;

        private _lines = [format ["<t size='0.95'>%1</t>", _description]];
        if (_zoneName isNotEqualTo "") then {
            _lines pushBack format ["<br/><t color='#B5D1E8'>Area:</t> %1", _zoneName];
        };
        if (_rewardText isNotEqualTo "") then {
            _lines pushBack format ["<br/><t color='#A4E28C'>Reward:</t> %1", _rewardText];
        };
        if (_effectText isNotEqualTo "") then {
            _lines pushBack format ["<br/><t color='#FFD27A'>Effect:</t> %1", _effectText];
        };
        if (_fallbackText isNotEqualTo "") then {
            _lines pushBack format ["<br/><t color='#CFCFCF'>Fallback:</t> %1", _fallbackText];
        };
        if (_statusText isNotEqualTo "") then {
            _lines pushBack format ["<br/><t color='#7CC8FF'>Status:</t> %1", _statusText];
        };
        if (_tooltipText isNotEqualTo "") then {
            _lines pushBack format ["<br/><t size='0.85' color='#D0D0D0'>%1</t>", _tooltipText];
        };

        _detailCtrl ctrlSetStructuredText parseText (_lines joinString "");

        private _showAccept = (_kind in ["SIDE_MISSION", "MAIN_OPERATION", "RESPAWN"]);
        _acceptCtrl ctrlShow _showAccept;
        _acceptCtrl ctrlEnable (_showAccept && _isAvailable);
        _acceptCtrl ctrlSetText _acceptLabel;

        if (!isNull _statusCtrl) then {
            private _modeLabel = [uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"], "_", " "] call BIS_fnc_replaceString;
            _statusCtrl ctrlSetText format ["Mode: %1 | Selected: %2", _modeLabel, _title];
        };
        true
    };
};

private _findNearestEntry = {
    params ["_entries", "_worldPos", ["_modeName", "", [""]]];

    private _nearest = [];
    private _bestDistance = 1e10;
    private _maxDistance = switch (toUpper _modeName) do {
        case "REDEPLOY": { 75 };
        default { 250 };
    };

    {
        _x params ["_kind", "_label", "_pos"];
        private _isCandidate = switch (toUpper _modeName) do {
            case "SIDE_MISSIONS": { _kind isEqualTo "SIDE_MISSION" };
            case "MAIN_OPERATIONS": { _kind isEqualTo "MAIN_OPERATION" };
            case "REDEPLOY": { _kind isEqualTo "RESPAWN" };
            default { false };
        };

        if (_isCandidate) then {
            private _dist = _worldPos distance2D _pos;
            if (_dist < _bestDistance) then {
                _bestDistance = _dist;
                _nearest = _x;
            };
        };
    } forEach _entries;

    if (_nearest isEqualTo [] || {_bestDistance > _maxDistance}) exitWith { [] };
    _nearest
};

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

        if !(_initialMode in ["ZONES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY"]) then {
            _initialMode = "ZONES";
        };

        createDialog "MWF_RscDataHub";
        private _display = findDisplay 12200;
        if (isNull _display) exitWith { false };

        uiNamespace setVariable ["MWF_DataHub_Display", _display];
        uiNamespace setVariable ["MWF_DataHub_Mode", _initialMode];
        uiNamespace setVariable ["MWF_DataHub_Markers", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", nil];
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];

        [_display, []] call _renderSelection;
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
        true
    };

    case "SET_MODE": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _newMode = if (_payload isEqualType "") then { toUpper _payload } else { toUpper (_payload param [0, "", [""]]) };
        if !(_newMode in ["ZONES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY"]) exitWith { false };
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        [_display, _newMode] call MWF_fnc_refreshDataMap;
        [_display, []] call _renderSelection;
        true
    };

    case "MAP_CLICK": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _modeName = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        if !(_modeName in ["SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY"]) exitWith { false };

        private _mapCtrl = _display displayCtrl 12205;
        if (isNull _mapCtrl) exitWith { false };

        private _mouse = _payload;
        if !(_mouse isEqualType []) exitWith { false };

        private _worldPos = _mapCtrl ctrlMapScreenToWorld _mouse;
        private _entries = uiNamespace getVariable ["MWF_DataHub_Entries", []];
        private _nearest = [_entries, _worldPos, _modeName] call _findNearestEntry;

        if (_nearest isEqualTo []) exitWith {
            private _statusCtrl = _display displayCtrl 12206;
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Mode: %1 | Click closer to a valid marker.", [_modeName, "_", " "] call BIS_fnc_replaceString];
            };
            false
        };

        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", _nearest];
        if ((_nearest # 0) isEqualTo "RESPAWN") then {
            uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", _nearest];
        };
        [_display, _nearest] call _renderSelection;
        true
    };

    case "ACCEPT": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
        if (_selected isEqualTo []) exitWith {
            private _statusCtrl = _display displayCtrl 12206;
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText "Select an entry on the map first.";
            };
            false
        };

        _selected params ["_kind", "_label", "_pos", ["_meta", createHashMap, [createHashMap]]];
        if !(_meta getOrDefault ["isAvailable", false]) exitWith {
            [_display, _selected] call _renderSelection;
            false
        };

        switch (_kind) do {
            case "SIDE_MISSION": {
                private _slotIndex = _meta getOrDefault ["slotIndex", -1];
                if (_slotIndex < 0) exitWith { false };
                ["CLOSE"] call MWF_fnc_dataHub;
                [_slotIndex, player] remoteExecCall ["MWF_fnc_activateMissionBoardSlot", 2];
                true
            };

            case "MAIN_OPERATION": {
                private _registryIndex = _meta getOrDefault ["registryIndex", -1];
                if (_registryIndex < 0) exitWith { false };
                ["CLOSE"] call MWF_fnc_dataHub;
                ["START_SERVER", _registryIndex, clientOwner] remoteExecCall ["MWF_fnc_terminal_mainOperations", 2];
                true
            };

            case "RESPAWN": {
                uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", _selected];
                private _statusCtrl = _display displayCtrl 12206;
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText format ["Redeploy target selected: %1", _selected param [1, "Unknown"]];
                };
                [_display, _selected] call _renderSelection;
                true
            };

            default { false };
        };
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
