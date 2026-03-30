params [["_payload", "ZONES", ["", []]]];

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
[_display, _newMode] call MWF_fnc_dataHubRefresh;
true
