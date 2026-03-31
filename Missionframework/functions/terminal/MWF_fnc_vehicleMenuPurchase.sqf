/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Stable handoff from the vehicle menu to local ghost placement.
    UI is left untouched; this only resolves the selected entry and starts placement after dialog close.
*/

if (!hasInterface) exitWith { false };

private _entry = +(missionNamespace getVariable ["MWF_VehicleMenu_SelectedEntry", []]);
if (_entry isEqualTo []) then {
    private _display = findDisplay 9050;
    if (!isNull _display) then {
        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _selectedIndex = lbCurSel (_display displayCtrl 9052);
        if (_selectedIndex >= 0 && {_selectedIndex < count _entries}) then {
            _entry = +(_entries select _selectedIndex);
            missionNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", _selectedIndex];
            missionNamespace setVariable ["MWF_VehicleMenu_SelectedEntry", +_entry];
        };
    };
};

if (_entry isEqualTo [] || {(count _entry) < 4}) exitWith {
    systemChat "Vehicle Menu: no valid selected vehicle to purchase.";
    false
};

private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];
closeDialog 0;

[_entry, _terminal] spawn {
    params ["_entryLocal", "_terminalLocal"];
    uiSleep 0.05;
    [_entryLocal, _terminalLocal] call MWF_fnc_beginVehiclePlacement;
};

true
