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
private _metaBlock = (_catalog select { (_x param [0, ""]) isEqualTo "__META__" });
private _meta = if (_metaBlock isEqualTo []) then { [] } else { (_metaBlock select 0) param [1, []] };
private _totalEntries = ((_meta select { (_x param [0, ""]) isEqualTo "totalEntries" }) param [0, ["totalEntries", 0]]) param [1, 0];
private _emptyCategories = ((_meta select { (_x param [0, ""]) isEqualTo "emptyCategories" }) param [0, ["emptyCategories", []]]) param [1, []];
private _invalidEntries = ((_meta select { (_x param [0, ""]) isEqualTo "invalidEntries" }) param [0, ["invalidEntries", 0]]) param [1, 0];
private _publicCatalog = _catalog select { (_x param [0, ""]) != "__META__" };

switch (_modeUpper) do {
    case "OPEN": {
        if (_totalEntries <= 0) exitWith {
            [
                ["VEHICLE MENU", "Active BLUFOR preset has no valid vehicle entries."],
                "warning"
            ] call MWF_fnc_showNotification;
            systemChat "Vehicle Menu unavailable: preset returned no valid vehicle entries.";
            []
        };

        missionNamespace setVariable ["MWF_VehicleMenu_LastTerminal", _terminal];
        missionNamespace setVariable ["MWF_VehicleMenu_LastCatalog", _publicCatalog];
        missionNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];

        private _summary = _publicCatalog apply {
            private _entries = _x param [1, []];
            format ["%1: %2", _x param [0, "UNK"], count _entries]
        };

        private _warningText = if (_invalidEntries > 0 || {_emptyCategories isNotEqualTo []}) then {
            format [" | invalid: %1 | empty: %2", _invalidEntries, _emptyCategories joinString ", "]
        } else {
            ""
        };

        [
            ["VEHICLE MENU", format ["Preset vehicle catalog ready. %1%2", _summary joinString " | ", _warningText]],
            "info"
        ] call MWF_fnc_showNotification;

        if (_emptyCategories isNotEqualTo []) then {
            systemChat format ["Vehicle Menu warning: empty preset categories -> %1", _emptyCategories joinString ", "];
        };

        _publicCatalog
    };

    case "GET_CATEGORY": {
        private _category = toUpper (_payload param [0, "LIGHT", [""]]);
        private _found = _publicCatalog select { (_x param [0, ""]) isEqualTo _category };
        if (_found isEqualTo []) exitWith { [] };
        (_found select 0) param [1, []]
    };

    case "SELECT": {
        private _category = toUpper (_payload param [0, "LIGHT", [""]]);
        private _index = _payload param [1, -1, [0]];

        private _entries = ["GET_CATEGORY", _terminal, [_category]] call MWF_fnc_terminal_vehicleMenu;
        if (_entries isEqualTo []) exitWith {
            systemChat format ["Vehicle Menu: category %1 has no valid entries.", _category];
            false
        };

        if (_index < 0 || {_index >= count _entries}) exitWith {
            systemChat "Vehicle Menu: invalid selection index.";
            false
        };

        private _entry = _entries select _index;
        [_entry, _terminal] call MWF_fnc_beginVehiclePlacement;
    };

    default {
        _publicCatalog
    };
};
