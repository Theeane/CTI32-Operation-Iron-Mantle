/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Dedicated purchase handoff for the separate vehicle menu dialog.
    Resolves the current selected entry, closes the dialog, and starts ghost placement
    outside the UI event context so placement is not lost when the display closes.
*/

if (!hasInterface) exitWith { false };

private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
private _category = missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];
private _display = findDisplay 9050;
private _selectedIndex = -1;

if (!isNull _display) then {
    private _list = _display displayCtrl 9052;
    if (!isNull _list) then { _selectedIndex = lbCurSel _list; };
};

if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
    [["VEHICLE MENU", format ["No valid selection in %1.", _category]], "warning"] call MWF_fnc_showNotification;
    false
};

private _entry = _entries select _selectedIndex;
private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];
private _displayName = _entry param [3, _entry param [0, "Vehicle"]];

missionNamespace setVariable ["MWF_VehicleMenu_LastEntry", _entry];
missionNamespace setVariable ["MWF_VehicleMenu_LastSelectionIndex", _selectedIndex];

closeDialog 0;

[_entry, _terminal, _displayName] spawn {
    params ["_entryLocal", "_terminalLocal", "_displayNameLocal"];
    uiSleep 0.12;

    private _started = [_entryLocal, _terminalLocal] call MWF_fnc_beginVehiclePlacement;
    if !(_started) then {
        [["VEHICLE PLACEMENT", format ["Failed to start placement for %1.", _displayNameLocal]], "warning"] call MWF_fnc_showNotification;
        systemChat format ["Vehicle placement handoff failed for %1.", _displayNameLocal];
    };
};

true
