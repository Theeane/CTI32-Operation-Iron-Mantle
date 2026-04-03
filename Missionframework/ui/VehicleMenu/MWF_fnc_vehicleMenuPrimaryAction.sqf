private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };
if !((uiNamespace getVariable ["MWF_DataHub_Mode", ""]) isEqualTo "VEHICLE_MENU") exitWith { false };

private _entries = uiNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
private _selectedIndex = uiNamespace getVariable ["MWF_VehicleMenu_SelectedIndex", -1];
private _statusCtrl = _display displayCtrl 12206;

if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
    if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText "Vehicle Menu: select a vehicle first."; };
    false
};

private _entry = _entries # _selectedIndex;
private _state = _entry param [7, createHashMap, [createHashMap]];
private _isLocked = _state getOrDefault ["isLocked", true];
private _canAfford = _state getOrDefault ["canAfford", false];
private _reason = _state getOrDefault ["reason", "Vehicle unavailable."];

if (_isLocked || {!_canAfford}) exitWith {
    if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText _reason; };
    [["VEHICLE MENU", _reason], if (_isLocked) then {"warning"} else {"info"}] call MWF_fnc_showNotification;
    false
};

private _terminal = uiNamespace getVariable ["MWF_DataHub_ContextTerminal", missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull]];
["CLOSE"] call MWF_fnc_dataHub;
["vehicle", _entry, _terminal] call MWF_fnc_startGhostPlacement;
true
