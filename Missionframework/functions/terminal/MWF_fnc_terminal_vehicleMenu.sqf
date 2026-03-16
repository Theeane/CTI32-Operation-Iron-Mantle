/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_terminal_vehicleMenu
    Project: Military War Framework

    Description:
    Backend controller for preset-driven Vehicle Menu.
    This file intentionally keeps logic UI-light for now and exposes category/selection flows
    so a richer UI can be layered on top later without changing the backend contract.
*/

if (!hasInterface) exitWith { [] };

params [
    ["_mode", "OPEN", [""]],
    ["_terminal", objNull, [objNull]],
    ["_payload", [], [[]]]
];

private _catalog = [] call MWF_fnc_getVehicleCatalog;
private _modeUpper = toUpper _mode;

switch (_modeUpper) do {
    case "OPEN": {
        missionNamespace setVariable ["MWF_VehicleMenu_LastTerminal", _terminal];
        missionNamespace setVariable ["MWF_VehicleMenu_LastCatalog", _catalog];
        missionNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];

        private _summary = _catalog apply {
            private _entries = _x param [1, []];
            format ["%1: %2", _x param [0, "UNK"], count _entries]
        };

        [
            ["VEHICLE MENU", format ["Preset vehicle catalog ready. %1", _summary joinString " | "]],
            "info"
        ] call MWF_fnc_showNotification;

        systemChat "Vehicle Menu backend ready. UI hook can now query categories and select an entry.";
        _catalog
    };

    case "GET_CATEGORY": {
        private _category = toUpper (_payload param [0, "LIGHT", [""]]);
        private _found = _catalog select { (_x param [0, ""]) isEqualTo _category };
        if (_found isEqualTo []) exitWith { [] };
        (_found select 0) param [1, []]
    };

    case "SELECT": {
        private _category = toUpper (_payload param [0, "LIGHT", [""]]);
        private _index = _payload param [1, -1, [0]];

        private _entries = ["GET_CATEGORY", _terminal, [_category]] call MWF_fnc_terminal_vehicleMenu;
        if (_index < 0 || {_index >= count _entries}) exitWith {
            systemChat "Vehicle Menu: invalid selection index.";
            false
        };

        private _entry = _entries select _index;
        [_entry, _terminal] call MWF_fnc_beginVehiclePlacement;
    };

    default {
        _catalog
    };
};
