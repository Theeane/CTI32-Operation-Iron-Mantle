/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Robust purchase handoff for Vehicle Menu. Resolves the selected entry from
    mission state first so UI timing cannot kill the placement startup path.
*/

if (!hasInterface) exitWith { false };

private _entry = + (missionNamespace getVariable ["MWF_VehicleMenu_SelectedEntry", []]);
private _isLocked = missionNamespace getVariable ["MWF_VehicleMenu_SelectedLocked", true];
private _canAfford = missionNamespace getVariable ["MWF_VehicleMenu_SelectedCanAfford", false];
private _statusText = missionNamespace getVariable ["MWF_VehicleMenu_SelectedStatusText", "Select a vehicle entry."];
private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];

if (_entry isEqualTo []) then {
    private _display = findDisplay 9050;
    if (isNull _display) exitWith { false };

    private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
    private _listCtrl = _display displayCtrl 9052;
    private _selectedIndex = lbCurSel _listCtrl;

    if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
        systemChat "Vehicle Menu: select a vehicle first.";
        false
    };

    _entry = + (_entries select _selectedIndex);
};

if (_entry isEqualTo []) exitWith {
    systemChat "Vehicle Menu: no selected entry found.";
    false
};

if (_isLocked) exitWith {
    systemChat _statusText;
    false
};

if (!_canAfford) exitWith {
    systemChat _statusText;
    false
};

missionNamespace setVariable ["MWF_VehicleMenu_PendingEntry", +_entry];
missionNamespace setVariable ["MWF_VehicleMenu_PendingTerminal", _terminal];

closeDialog 0;

[] spawn {
    uiSleep 0.10;

    private _pendingEntry = + (missionNamespace getVariable ["MWF_VehicleMenu_PendingEntry", []]);
    private _pendingTerminal = missionNamespace getVariable ["MWF_VehicleMenu_PendingTerminal", objNull];

    missionNamespace setVariable ["MWF_VehicleMenu_PendingEntry", nil];
    missionNamespace setVariable ["MWF_VehicleMenu_PendingTerminal", nil];

    if (_pendingEntry isEqualTo []) exitWith {
        systemChat "Vehicle Menu: purchase handoff lost selected entry.";
        false
    };

    [_pendingEntry, _pendingTerminal] call MWF_fnc_beginVehiclePlacement;
};

true
