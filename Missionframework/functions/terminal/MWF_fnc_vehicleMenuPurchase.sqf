/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Separate handoff for Vehicle Menu purchase so dialog close cannot kill the
    ghost placement startup path.
*/

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

missionNamespace setVariable ["MWF_VehicleMenu_PendingEntry", _entry];
missionNamespace setVariable ["MWF_VehicleMenu_PendingTerminal", _terminal];
uiNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", _selectedIndex];

[_entry, _terminal] spawn {
    params ["_entryLocal", "_terminalLocal"];
    uiSleep 0.05;
    ["[MWF] New vehicle preview path via buyMenu."] call BIS_fnc_showSubtitle;
    [_entryLocal, _terminalLocal] spawn MWF_fnc_startVehicleBuildSession;
};

true
