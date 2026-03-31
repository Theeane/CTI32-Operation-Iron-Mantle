/*
    Debug-instrumented purchase handoff for Vehicle Menu.
*/

if (!hasInterface) exitWith { false };

systemChat "VM DEBUG: purchase start";
diag_log "[OIM][VehicleMenu] purchase start";

private _entry = +(missionNamespace getVariable ["MWF_VehicleMenu_SelectedEntry", []]);
if (_entry isEqualTo []) then {
    systemChat "VM DEBUG: no cached entry, trying display selection";
    private _display = findDisplay 9050;
    if (!isNull _display) then {
        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _selectedIndex = lbCurSel (_display displayCtrl 9052);
        systemChat format ["VM DEBUG: display selection index %1 / entries %2", _selectedIndex, count _entries];
        if (_selectedIndex >= 0 && {_selectedIndex < count _entries}) then {
            _entry = +(_entries select _selectedIndex);
            missionNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", _selectedIndex];
            missionNamespace setVariable ["MWF_VehicleMenu_SelectedEntry", +_entry];
        };
    } else {
        systemChat "VM DEBUG: display 9050 missing during purchase";
    };
};

if (_entry isEqualTo [] || {(count _entry) < 4}) exitWith {
    systemChat "VM DEBUG: invalid selected entry";
    diag_log format ["[OIM][VehicleMenu] invalid selected entry: %1", _entry];
    false
};

diag_log format ["[OIM][VehicleMenu] selected entry: %1", _entry];
systemChat format ["VM DEBUG: selected %1", _entry param [3, _entry param [0, "UNKNOWN"]]];

private _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];
systemChat format ["VM DEBUG: terminal null = %1", isNull _terminal];
closeDialog 0;
systemChat "VM DEBUG: dialog closed";

[_entry, _terminal] spawn {
    params ["_entryLocal", "_terminalLocal"];
    systemChat "VM DEBUG: handoff spawned";
    uiSleep 0.05;
    systemChat "VM DEBUG: calling begin placement";
    diag_log format ["[OIM][VehicleMenu] begin placement handoff entry=%1 terminalNull=%2", _entryLocal, isNull _terminalLocal];
    [_entryLocal, _terminalLocal] call MWF_fnc_beginVehiclePlacement;
    systemChat "VM DEBUG: begin placement returned";
};

true
