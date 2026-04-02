params [
    ["_display", displayNull, [displayNull]],
    ["_mode", "ZONES", [""]]
];

if (isNull _display) exitWith { false };

private _modeUpper = toUpper _mode;

if !(_modeUpper isEqualTo "VEHICLE_MENU") then {
    [] call MWF_fnc_vehicleMenuClear;
};

private _result = [_display, _modeUpper] call MWF_fnc_refreshDataMap;

if (_modeUpper isEqualTo "VEHICLE_MENU") then {
    [_display] call MWF_fnc_vehicleMenuRefresh;
};

if (_modeUpper isEqualTo "REDEPLOY" && {uiNamespace getVariable ["MWF_RedeployShell_Active", false]}) then {
    [_display] call MWF_fnc_redeployRefreshShell;
};

_result
