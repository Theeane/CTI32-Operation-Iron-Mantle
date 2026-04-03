/*
    Author: OpenAI
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Single purchase entrypoint for both the old buy menu and the DataHub vehicle menu.
*/

if (!hasInterface) exitWith { false };

private _entry = missionNamespace getVariable ["MWF_VehicleMenu_SelectedEntry", []];
private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];

if (_entry isEqualTo []) then {
    private _display = findDisplay 9050;
    if (isNull _display) then { _display = findDisplay 9060; };
    if (isNull _display) then { _display = findDisplay 9000; };

    if (!isNull _display) then {
        private _list = _display displayCtrl 9052;
        if (isNull _list) then { _list = _display displayCtrl 9002; };
        if (!isNull _list) then {
            private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
            private _selectedIndex = lbCurSel _list;
            if (_selectedIndex >= 0 && {_selectedIndex < count _entries}) then {
                _entry = +(_entries select _selectedIndex);
                missionNamespace setVariable ["MWF_VehicleMenu_SelectedEntry", +_entry];
                missionNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", _selectedIndex];
            };
        };
    };
};

if (_entry isEqualTo []) exitWith {
    [["VEHICLE MENU", "No vehicle selected."], "warning"] call MWF_fnc_showNotification;
    false
};

closeDialog 0;
["CLOSE"] call MWF_fnc_dataHub;
[_entry, _terminal] spawn MWF_fnc_startVehicleBuildSession;
true
