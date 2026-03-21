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

private _setInfoText = {
    params [["_ctrl", controlNull, [controlNull]], ["_lines", [], [[]]]];
    if (isNull _ctrl) exitWith {};
    _ctrl ctrlSetStructuredText parseText (_lines joinString "<br/>");
};

private _setButtonState = {
    params [["_ctrl", controlNull, [controlNull]], ["_text", "", [""]], ["_enabled", true, [true]]];
    if (isNull _ctrl) exitWith {};
    _ctrl ctrlSetText _text;
    _ctrl ctrlEnable _enabled;
};

private _performRedeploy = {
    params [["_selected", [], [[]]]];

    if (_selected isEqualTo []) exitWith { [false, "Redeploy: select a respawn point on the map first."] };
    if (!alive player) exitWith { [false, "Redeploy unavailable while incapacitated."] };
    if (vehicle player != player) exitWith { [false, "Exit your vehicle before redeploying."] };

    _selected params ["_kind", "_label", "_targetPos"];
    private _teleportPos = [_targetPos, 3, 12, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
    if (_teleportPos isEqualTo [] || {_teleportPos isEqualTo [0,0,0]}) then {
        _teleportPos = _targetPos vectorAdd [3, 0, 0];
    };

    player setPosATL _teleportPos;
    [["REDEPLOY COMPLETE", format ["Redeployed to %1.", _label]], "success"] call MWF_fnc_showNotification;
    [true, format ["Redeployed to %1.", _label]]
};

private _showSelectedEntry = {
    params [
        ["_display", displayNull, [displayNull]],
        ["_entry", [], [[]]],
        ["_modeNow", "ZONES", [""]]
    ];

    if (isNull _display || {_entry isEqualTo []}) exitWith {};

    private _statusCtrl = _display displayCtrl 12206;
    private _infoCtrl = _display displayCtrl 12216;
    private _actionCtrl = _display displayCtrl 12207;
    private _leftCtrl = _display displayCtrl 12215;

    private _label = _entry param [1, "Unknown"];
    private _meta = _entry param [3, createHashMap, [createHashMap]];

    switch (_modeNow) do {

        case "UPGRADES": {
            private _statusText = _meta getOrDefault ["statusText", "Locked"];
            private _tooltipText = _meta getOrDefault ["tooltipText", ""];
            private _actionMode = _meta getOrDefault ["actionMode", "LOCKED"];
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Base Upgrade: %1", _label];
            };

            [_infoCtrl, [
                format ["<t size='1.05' color='#111111'>%1</t>", _label],
                format ["<t color='#222222'>%1</t>", _meta getOrDefault ["description", "Base upgrade."]],
                format ["<t color='#222222'>Status: %1</t>", _statusText],
                format ["<t color='#222222'>%1</t>", _tooltipText]
            ]] call _setInfoText;

            switch (_actionMode) do {
                case "VEHICLE_MENU": {
                    [_actionCtrl, "Vehicle Menu", true] call _setButtonState;
                    [_leftCtrl, "Main Ops", true] call _setButtonState;
                };
                case "BASE_BUILDING": {
                    [_actionCtrl, "Base Building", true] call _setButtonState;
                    [_leftCtrl, "Main Ops", true] call _setButtonState;
                };
                case "TIER5_INFO": {
                    [_actionCtrl, "Tier 5 Info", true] call _setButtonState;
                    [_leftCtrl, "Main Ops", true] call _setButtonState;
                };
                default {
                    [_actionCtrl, "Locked", false] call _setButtonState;
                    [_leftCtrl, "Main Ops", true] call _setButtonState;
                };
            };
        };

        case "SUPPORT": {
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Selected Support: %1", _label];
            };

            [_infoCtrl, [
                format ["<t size='1.05' color='#111111'>%1</t>", _label],
                format ["<t color='#222222'>%1</t>", _meta getOrDefault ["description", "Support package."]],
                "<t color='#222222'>Accept: Build Unit | Left button: Build Group</t>"
            ]] call _setInfoText;

            [_actionCtrl, "Build Unit", true] call _setButtonState;
            [_leftCtrl, "Build Group", true] call _setButtonState;
        };

        case "REDEPLOY": {
            private _kind = _meta getOrDefault ["kind", "FOB"];
            private _canRedeploy = alive player && {vehicle player == player};

            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Redeploy Target: %1", _label];
            };

            [_infoCtrl, [
                format ["<t size='1.05' color='#111111'>%1</t>", _label],
                format ["<t color='#222222'>Type: %1</t>", _kind],
                format ["<t color='#222222'>Status: %1</t>", if (_canRedeploy) then {"Ready"} else {"Unavailable right now"}]
            ]] call _setInfoText;

            [_actionCtrl, "Redeploy", _canRedeploy] call _setButtonState;
            [_leftCtrl, "Side Missions", true] call _setButtonState;
        };

        case "SIDE_MISSIONS": {
            private _category = toLower (_meta getOrDefault ["category", "disrupt"]);
            private _difficulty = toLower (_meta getOrDefault ["difficulty", "easy"]);
            private _zoneName = _meta getOrDefault ["zoneName", "Unknown Area"];
            private _state = toLower (_meta getOrDefault ["state", "available"]);
            private _rewardSupplies = _meta getOrDefault ["rewardSupplies", 0];
            private _rewardIntel = _meta getOrDefault ["rewardIntel", 0];
            private _rewardThreat = _meta getOrDefault ["rewardThreat", 0];
            private _rewardTier = _meta getOrDefault ["rewardTier", 0];
            private _rewardThreatUndercover = _meta getOrDefault ["rewardThreatUndercover", _rewardThreat];
            private _fallbackSupplies = _meta getOrDefault ["fallbackSupplies", 0];
            private _fallbackIntel = _meta getOrDefault ["fallbackIntel", 0];
            private _allowUndercover = _meta getOrDefault ["allowUndercover", false];
            private _notes = _meta getOrDefault ["notes", ""];
            private _description = _meta getOrDefault ["description", ""];
            private _access = ["MISSION_HUB"] call MWF_fnc_validateTerminalAccess;
            private _isAvailable = (_state isEqualTo "available") && (_access param [0, false]);
            private _statusText = if (_state isEqualTo "active") then {
                "Active"
            } else {
                if (_access param [0, false]) then { "Available" } else { _access param [1, "Unavailable"] };
            };

            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Selected Mission: %1 | %2", _label, _statusText];
            };

            private _lines = [
                format ["<t size='1.05' color='#111111'>%1</t>", _label],
                format ["<t color='#222222'>Area: %1 | Template: %2</t>", _zoneName, _meta getOrDefault ["missionId", "Unknown"]]
            ];

            if !(_description isEqualTo "") then {
                _lines pushBack format ["<t color='#222222'>%1</t>", _description];
            };

            _lines pushBack format ["<t color='#222222'>Rewards: %1 Supplies / %2 Intel | Progress: +%3 threat / +%4 tier</t>", _rewardSupplies, _rewardIntel, _rewardThreat, _rewardTier];

            if (_allowUndercover) then {
                _lines pushBack format ["<t color='#222222'>Undercover threat: %1</t>", _rewardThreatUndercover];
            };

            if ((_fallbackSupplies > 0) || {_fallbackIntel > 0}) then {
                _lines pushBack format ["<t color='#222222'>Fallback reward if progression effect is blocked: %1 Supplies / %2 Intel</t>", _fallbackSupplies, _fallbackIntel];
            };

            if !(_notes isEqualTo "") then {
                _lines pushBack format ["<t color='#222222'>Notes: %1</t>", _notes];
            };

            _lines pushBack format ["<t color='#222222'>Status: %1</t>", _statusText];

            [_infoCtrl, _lines] call _setInfoText;

            [_actionCtrl, "Accept", _isAvailable] call _setButtonState;
            [_leftCtrl, "Main Ops", true] call _setButtonState;
        };

        case "MAIN_OPERATIONS": {
            private _key = _meta getOrDefault ["key", ""];
            private _ops = [] call MWF_fnc_getMainOperationRegistry;
            private _opIndex = _ops findIf { (_x # 0) isEqualTo _key };
            private _state = if (_opIndex >= 0) then { [_key, _ops # _opIndex] call MWF_fnc_getMainOperationState } else { createHashMap };
            private _access = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
            private _statusText = if (_access param [0, false]) then {
                _state getOrDefault ["statusText", "Unknown"]
            } else {
                _access param [1, "Unavailable"]
            };
            private _isAvailable = (_state getOrDefault ["isAvailable", false]) && (_access param [0, false]);
            private _zoneName = _meta getOrDefault ["zoneName", "Unknown Area"];

            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Selected Main Operation: %1 | %2", _label, _statusText];
            };

            [_infoCtrl, [
                format ["<t size='1.05' color='#111111'>%1</t>", _label],
                format ["<t color='#222222'>AO: %1</t>", _zoneName],
                format ["<t color='#222222'>%1</t>", _meta getOrDefault ["description", ""]],
                format ["<t color='#222222'>Effect: %1</t>", _meta getOrDefault ["effectText", ""]],
                format ["<t color='#222222'>Status: %1</t>", _statusText]
            ]] call _setInfoText;

            [_actionCtrl, "Accept", _isAvailable] call _setButtonState;
            [_leftCtrl, "Side Missions", true] call _setButtonState;
        };

        default {
            if (!isNull _statusCtrl) then {
                _statusCtrl ctrlSetText format ["Selected: %1", _label];
            };
            [_infoCtrl, [format ["<t size='1.05' color='#111111'>%1</t>", _label]]] call _setInfoText;
        };
    };
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

        if !(_initialMode in ["ZONES", "UPGRADES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY", "SUPPORT"]) then {
            _initialMode = "ZONES";
        };

        createDialog "MWF_RscDataHub";
        private _display = findDisplay 12200;
        if (isNull _display) exitWith { false };

        uiNamespace setVariable ["MWF_DataHub_Display", _display];
        uiNamespace setVariable ["MWF_DataHub_Mode", _initialMode];
        uiNamespace setVariable ["MWF_DataHub_Markers", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
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
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        uiNamespace setVariable ["MWF_DataHub_ViewStack", []];
        true
    };

    case "SET_MODE": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _newMode = if (_payload isEqualType "") then { toUpper _payload } else { toUpper (_payload param [0, "", [""]]) };
        if !(_newMode in ["ZONES", "UPGRADES", "SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY", "SUPPORT"]) exitWith { false };
        private _currentMode = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        if !(_newMode isEqualTo _currentMode) then {
            private _stack = uiNamespace getVariable ["MWF_DataHub_ViewStack", []];
            _stack pushBack _currentMode;
            uiNamespace setVariable ["MWF_DataHub_ViewStack", _stack];
        };

        uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
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
        private _modeNow = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];
        private _nearest = [];
        private _bestDistance = 999999;

        {
            _x params ["_kind", "_label", "_pos", "_meta"];
            if ((_modeNow isEqualTo "REDEPLOY" && {_kind isEqualTo "RESPAWN"}) || (_modeNow isEqualTo "SIDE_MISSIONS" && {_kind isEqualTo "SIDE_MISSION"}) || (_modeNow isEqualTo "MAIN_OPERATIONS" && {_kind isEqualTo "MAIN_OPERATION"}) || (_modeNow isEqualTo "SUPPORT" && {_kind isEqualTo "SUPPORT"}) || (_modeNow isEqualTo "UPGRADES" && {_kind isEqualTo "UPGRADE"})) then {
                private _dist = _worldPos distance2D _pos;
                if (_dist < _bestDistance) then {
                    _bestDistance = _dist;
                    _nearest = _x;
                };
            };
        } forEach _entries;

        if (_nearest isEqualTo [] || {_bestDistance > 75}) exitWith { false };

        if (_modeNow isEqualTo "REDEPLOY") then {
            uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", _nearest];
            uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
        } else {
            uiNamespace setVariable ["MWF_DataHub_SelectedEntry", _nearest];
            uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
        };

        [_display, _nearest, _modeNow] call _showSelectedEntry;
        true
    };

    case "BACK": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
        private _selectedRespawn = uiNamespace getVariable ["MWF_DataHub_SelectedRespawn", []];
        if !(_selected isEqualTo [] && {_selectedRespawn isEqualTo []}) exitWith {
            uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];
            uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
            [_display, uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"]] call MWF_fnc_refreshDataMap;
            true
        };

        [] call MWF_fnc_uiGoBack
    };

    case "ACTION": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _statusCtrl = _display displayCtrl 12206;
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
            private _result = [_selected] call _performRedeploy;
            if (_result param [0, false]) then {
                ["CLOSE"] call MWF_fnc_dataHub;
                true
            } else {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText (_result param [1, "Redeploy failed."]);
                };
                false
            }
        };


        if (_modeNow isEqualTo "UPGRADES") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
            if (_selected isEqualTo []) exitWith { false };

            private _meta = _selected param [3, createHashMap, [createHashMap]];
            private _actionMode = _meta getOrDefault ["actionMode", "LOCKED"];
            private _tooltipText = _meta getOrDefault ["tooltipText", "Upgrade locked."];

            switch (_actionMode) do {
                case "VEHICLE_MENU": {
                    ["CLOSE"] call MWF_fnc_dataHub;
                    ["OPEN", objNull] call MWF_fnc_terminal_vehicleMenu;
                    true
                };
                case "BASE_BUILDING": {
                    private _buildClass = _meta getOrDefault ["buildClass", ""];
                    private _buildCost = _meta getOrDefault ["buildCost", 0];
                    private _upgradeId = _meta getOrDefault ["upgradeId", ""];
                    if (_buildClass isEqualTo "") exitWith {
                        if (!isNull _statusCtrl) then {
                            _statusCtrl ctrlSetText "Upgrade build data missing.";
                        };
                        false
                    };
                    [["BASE UPGRADE", _tooltipText], "info"] call MWF_fnc_showNotification;
                    ["CLOSE"] call MWF_fnc_dataHub;
                    [_buildClass, _buildCost, _upgradeId] spawn MWF_fnc_startBuildPlacement;
                    true
                };
                case "TIER5_INFO": {
                    [["BASE UPGRADE", _tooltipText], "info"] call MWF_fnc_showNotification;
                    if (!isNull _statusCtrl) then {
                        _statusCtrl ctrlSetText _tooltipText;
                    };
                    false
                };
                default {
                    if (!isNull _statusCtrl) then {
                        _statusCtrl ctrlSetText _tooltipText;
                    };
                    false
                };
            };
        };

        if (_modeNow isEqualTo "SIDE_MISSIONS") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
            if (_selected isEqualTo []) exitWith { false };

            private _meta = _selected param [3, createHashMap, [createHashMap]];
            private _access = ["MISSION_HUB"] call MWF_fnc_validateTerminalAccess;
            if !(_access param [0, false]) exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText (_access param [1, "Mission Hub unavailable."]);
                };
                false
            };

            private _state = toLower (_meta getOrDefault ["state", "available"]);
            if !(_state isEqualTo "available") exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText format ["Mission not available: %1", _selected param [1, "Unknown"]];
                };
                false
            };

            private _slotIndex = _meta getOrDefault ["slotIndex", -1];
            if (_slotIndex < 0) exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText "Mission slot metadata missing.";
                };
                false
            };

            ["CLOSE"] call MWF_fnc_dataHub;
            [_slotIndex, player] remoteExecCall ["MWF_fnc_activateMissionBoardSlot", 2];
            [["MISSION BOARD", format ["Requested mission: %1", _selected param [1, "Unknown"]]], "info"] call MWF_fnc_showNotification;
            true
        };

        if (_modeNow isEqualTo "MAIN_OPERATIONS") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
            if (_selected isEqualTo []) exitWith { false };

            private _meta = _selected param [3, createHashMap, [createHashMap]];
            private _access = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
            if !(_access param [0, false]) exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText (_access param [1, "Main Operations unavailable."]);
                };
                false
            };

            private _key = _meta getOrDefault ["key", ""];
            private _ops = [] call MWF_fnc_getMainOperationRegistry;
            private _opIndex = _ops findIf { (_x # 0) isEqualTo _key };
            if (_opIndex < 0) exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText "Main operation metadata missing.";
                };
                false
            };

            private _state = [_key, _ops # _opIndex] call MWF_fnc_getMainOperationState;
            if !(_state getOrDefault ["isAvailable", false]) exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText (_state getOrDefault ["tooltipText", "Operation unavailable."]);
                };
                false
            };

            ["CLOSE"] call MWF_fnc_dataHub;
            ["START_SERVER", _opIndex, clientOwner] remoteExecCall ["MWF_fnc_terminal_mainOperations", 2];
            [["MAIN OPERATION", format ["Requested operation: %1", _selected param [1, "Unknown"]]], "info"] call MWF_fnc_showNotification;
            true
        };

        ["CLOSE"] call MWF_fnc_dataHub;
        true
    };

    case "ACTION_SECONDARY": {
        private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
        if (isNull _display) exitWith { false };

        private _modeNow = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];

        if (_modeNow isEqualTo "SUPPORT") exitWith {
            private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
            if (_selected isEqualTo []) exitWith { false };
            private _meta = _selected param [3, createHashMap, [createHashMap]];
            ["BUILD_GROUP", _meta getOrDefault ["index", 1], player] call MWF_fnc_terminal_support;
            true
        };

        if (_modeNow isEqualTo "UPGRADES") exitWith {
            ["SET_MODE", "MAIN_OPERATIONS"] call MWF_fnc_dataHub;
            true
        };

        if (_modeNow isEqualTo "SIDE_MISSIONS") exitWith {
            ["SET_MODE", "MAIN_OPERATIONS"] call MWF_fnc_dataHub;
            true
        };

        ["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
        true
    };

    default { false };
};
