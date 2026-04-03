if (!hasInterface) exitWith { false };

private _display = findDisplay 9050;
if (isNull _display) exitWith { false };

private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", uiNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []]];
private _listCtrl = _display displayCtrl 9052;
private _selectedIndex = lbCurSel _listCtrl;

if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
    systemChat "Vehicle Menu: select a vehicle first.";
    false
};

private _entry = _entries select _selectedIndex;
private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", uiNamespace getVariable ["MWF_DataHub_ContextTerminal", objNull]];

closeDialog 0;
[_entry, _terminal] spawn MWF_fnc_startVehicleBuildSession;
true
