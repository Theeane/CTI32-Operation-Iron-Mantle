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

if (_modeNow isEqualTo "SIDE_MISSIONS") exitWith { false };

["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
true
