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
    if (_selected isEqualTo []) exitWith {
        if (!isNull _statusCtrl) then {
            _statusCtrl ctrlSetText "Redeploy: select a respawn point on the map first.";
        };
        false
    };
    if (!alive player) exitWith {
        if (!isNull _statusCtrl) then {
            _statusCtrl ctrlSetText "Redeploy unavailable while incapacitated.";
        };
        false
    };
    if (vehicle player != player) exitWith {
        if (!isNull _statusCtrl) then {
            _statusCtrl ctrlSetText "Exit your vehicle before redeploying.";
        };
        false
    };

    _selected params ["_kind", "_label", "_targetPos"];
    private _teleportPos = [_targetPos, 3, 12, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
    if (_teleportPos isEqualTo [] || {_teleportPos isEqualTo [0,0,0]}) then {
        _teleportPos = _targetPos vectorAdd [3, 0, 0];
    };

    player setPosATL _teleportPos;
    [["REDEPLOY COMPLETE", format ["Redeployed to %1.", _label]], "success"] call MWF_fnc_showNotification;
    ["CLOSE"] call MWF_fnc_dataHub;
    true
};

if (_modeNow isEqualTo "UPGRADES") exitWith {
    private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
    if (_selected isEqualTo []) exitWith { false };

    private _meta = _selected param [3, createHashMap, [createHashMap]];
    private _actionMode = _meta getOrDefault ["actionMode", "LOCKED"];
    private _tooltipText = _meta getOrDefault ["tooltipText", "Upgrade locked."];

    switch (_actionMode) do {
        case "VEHICLE_MENU": {
            private _terminal = _meta getOrDefault ["contextTerminal", uiNamespace getVariable ["MWF_DataHub_ContextTerminal", missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull]]];
            ["CLOSE"] call MWF_fnc_dataHub;
            ["OPEN", _terminal] call MWF_fnc_terminal_vehicleMenu;
            true
        };
        case "BASE_BUILDING";
        case "GARAGE_BUILD": {
            private _buildClass = _meta getOrDefault ["buildClass", ""];
            private _buildCost = _meta getOrDefault ["buildCost", 0];
            if (_buildClass isEqualTo "") exitWith {
                if (!isNull _statusCtrl) then {
                    _statusCtrl ctrlSetText format ["%1 build data missing.", if (_actionMode isEqualTo "GARAGE_BUILD") then {"Virtual garage"} else {"Upgrade"}];
                };
                false
            };
            [[if (_actionMode isEqualTo "GARAGE_BUILD") then {"VIRTUAL GARAGE"} else {"BASE UPGRADE"}, _tooltipText], "info"] call MWF_fnc_showNotification;
            ["CLOSE"] call MWF_fnc_dataHub;
            [_buildClass, _buildCost] spawn MWF_fnc_startBuildPlacement;
            true
        };
        case "GARAGE_INFO";
        case "TIER5_INFO": {
            [[if (_actionMode isEqualTo "GARAGE_INFO") then {"VIRTUAL GARAGE"} else {"BASE UPGRADE"}, _tooltipText], "info"] call MWF_fnc_showNotification;
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
