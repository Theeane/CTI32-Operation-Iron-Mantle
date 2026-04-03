private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };
if !((uiNamespace getVariable ["MWF_DataHub_Mode", ""]) isEqualTo "VEHICLE_MENU") exitWith { false };

private _entries = uiNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
private _selectedIndex = uiNamespace getVariable ["MWF_VehicleMenu_SelectedIndex", -1];
if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith { false };

private _entry = _entries select _selectedIndex;
private _terminal = uiNamespace getVariable ["MWF_DataHub_ContextTerminal", objNull];
["CLOSE"] call MWF_fnc_dataHub;
[_entry, _terminal] spawn MWF_fnc_startVehicleBuildSession;
true
