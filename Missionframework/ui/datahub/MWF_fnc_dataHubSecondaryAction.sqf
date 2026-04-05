private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };

private _modeNow = uiNamespace getVariable ["MWF_DataHub_Mode", "ZONES"];

if (_modeNow isEqualTo "VEHICLE_MENU") exitWith {
    [] call MWF_fnc_vehicleMenuSecondaryAction
};

if (_modeNow isEqualTo "BUILD_MENU") exitWith {
    ["SET_MODE", "ZONES"] call MWF_fnc_dataHub;
    true
};

if (_modeNow isEqualTo "SUPPORT") exitWith {
    private _selected = uiNamespace getVariable ["MWF_DataHub_SelectedEntry", []];
    if (_selected isEqualTo []) exitWith { false };
    private _meta = _selected param [3, createHashMap, [createHashMap]];
    ["BUILD_GROUP", _meta getOrDefault ["index", 1], player] call MWF_fnc_terminal_support;
    true
};

if (_modeNow isEqualTo "REDEPLOY") exitWith {
    if (uiNamespace getVariable ["MWF_RedeployShell_Active", false]) then {
        private _terminal = uiNamespace getVariable ["MWF_RedeployShell_ReturnTerminal", missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull]];
        uiNamespace setVariable ["MWF_RedeployShell_Active", false];
        uiNamespace setVariable ["MWF_RedeployShell_ReturnTerminal", objNull];
        ["CLOSE"] call MWF_fnc_dataHub;
        if (!isNull _terminal) then {
            [_terminal, player] spawn MWF_fnc_openBuyMenu;
        };
        true
    } else {
        ["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
        true
    };
};

if (_modeNow isEqualTo "SIDE_MISSIONS") exitWith { false };

["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
true
