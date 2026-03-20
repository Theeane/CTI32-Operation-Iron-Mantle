/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_terminal_vehicleMenu
    Project: Military War Framework

    Description:
    Preset-driven vehicle menu controller with a lightweight list frontend.
    Keeps preset order intact, surfaces locked entries with reasons, and routes
    valid selections into the ghost-build placement flow.
*/

if (!hasInterface) exitWith { [] };

params [
    ["_mode", "OPEN", [""]],
    ["_terminal", objNull, [objNull]],
    ["_payload", [], [[]]]
];

private _modeUpper = toUpper _mode;
private _selectionMode = _modeUpper;
if (_modeUpper isEqualTo "CATEGORY") then { _modeUpper = "REFRESH"; };
if (_modeUpper isEqualTo "SELECT") then { _modeUpper = "PURCHASE"; };
private _catalogRaw = [] call MWF_fnc_getVehicleCatalog;
private _metaBlock = (_catalogRaw select { (_x param [0, ""]) isEqualTo "__META__" });
private _meta = if (_metaBlock isEqualTo []) then { [] } else { (_metaBlock select 0) param [1, []] };
private _totalEntries = ((_meta select { (_x param [0, ""]) isEqualTo "totalEntries" }) param [0, ["totalEntries", 0]]) param [1, 0];
private _emptyCategories = ((_meta select { (_x param [0, ""]) isEqualTo "emptyCategories" }) param [0, ["emptyCategories", []]]) param [1, []];
private _invalidEntries = ((_meta select { (_x param [0, ""]) isEqualTo "invalidEntries" }) param [0, ["invalidEntries", 0]]) param [1, 0];
private _publicCatalog = _catalogRaw select { (_x param [0, ""]) != "__META__" };

private _getCategoryEntries = {
    params ["_catalog", ["_category", "LIGHT", [""]]];
    private _categoryUpper = toUpper _category;
    private _found = _catalog select { (_x param [0, ""]) isEqualTo _categoryUpper };
    if (_found isEqualTo []) exitWith { [] };
    (_found select 0) param [1, []]
};

private _hasRequiredUpgradeStructure = {
    params [["_requiredUnlock", "", [""]]];

    private _modeKey = toUpper _requiredUnlock;
    if !(_modeKey in ["HELI", "JETS"]) exitWith { true };

    private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
    private _structureClass = switch (_modeKey) do {
        case "HELI": { missionNamespace getVariable ["MWF_Heli_Tower_Class", ""] };
        case "JETS": { missionNamespace getVariable ["MWF_Jet_Control_Class", ""] };
        default { "" };
    };

    if (_structureClass isEqualTo "") exitWith { false };
    ({ typeOf _x isEqualTo _structureClass } count (nearestObjects [_mobPos, [_structureClass], 120])) > 0
};

private _evaluateEntry = {
    params [["_entry", [], [[]]]];

    _entry params [
        ["_className", "", [""]],
        ["_cost", 0, [0]],
        ["_minTier", 1, [0]],
        ["_displayName", "", [""]],
        ["_requiredUnlock", "", [""]],
        ["_isTier5", false, [false]]
    ];

    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
    private _lockReason = "Ready to build.";
    private _isLocked = false;

    if (_className isEqualTo "") exitWith { [true, "Empty preset placeholder.", false] };

    if (_isTier5 && {!(missionNamespace getVariable ["MWF_Unlock_Tier5", false])}) then {
        _isLocked = true;
        _lockReason = "Requires main operation: Apex Predator.";
    };

    if (!_isLocked) then {
        switch (toUpper _requiredUnlock) do {
            case "ARMOR": {
                if !(missionNamespace getVariable ["MWF_Unlock_Armor", false]) then {
                    _isLocked = true;
                    _lockReason = "Requires main operation: Steel Rain.";
                };
            };
            case "HELI": {
                if !(missionNamespace getVariable ["MWF_Unlock_Heli", false]) then {
                    _isLocked = true;
                    _lockReason = "Requires main operation: Sky Guardian.";
                } else {
                    if !([_requiredUnlock] call _hasRequiredUpgradeStructure) then {
                        _isLocked = true;
                        _lockReason = "Build the Helicopter Uplink at the MOB first.";
                    };
                };
            };
            case "JETS": {
                if !(missionNamespace getVariable ["MWF_Unlock_Jets", false]) then {
                    _isLocked = true;
                    _lockReason = "Requires main operation: Point Blank.";
                } else {
                    if !([_requiredUnlock] call _hasRequiredUpgradeStructure) then {
                        _isLocked = true;
                        _lockReason = "Build Aircraft Control at the MOB first.";
                    };
                };
            };
        };
    };

    if (!_isLocked && {_currentTier < _minTier}) then {
        _isLocked = true;
        _lockReason = format ["Requires Base Tier %1.", _minTier];
    };

    if (!_isLocked && {_supplies < _cost}) then {
        _lockReason = format ["Insufficient Supplies: %1 needed.", _cost];
    };

    [_isLocked, _lockReason, _supplies >= _cost]
};

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

        closeDialog 0;
        createDialog "IronMantle_BuyMenu";
        private _display = findDisplay 9050;
        if (isNull _display) exitWith {
            systemChat "Vehicle Menu failed to open.";
            []
        };

        if (_emptyCategories isNotEqualTo []) then {
            systemChat format ["Vehicle Menu warning: empty preset categories -> %1", _emptyCategories joinString ", "];
        };
        if (_invalidEntries > 0) then {
            systemChat format ["Vehicle Menu warning: %1 invalid preset entries skipped.", _invalidEntries];
        };

        ["REFRESH", _terminal, ["LIGHT"]] call MWF_fnc_terminal_vehicleMenu;
        _publicCatalog
    };

    case "GET_CATEGORY": {
        [_publicCatalog, _payload param [0, missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"], [""]]] call _getCategoryEntries
    };

    case "REFRESH": {
        private _display = findDisplay 9050;
        if (isNull _display) exitWith { [] };

        private _category = toUpper (_payload param [0, missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"], [""]]);
        private _entries = [_publicCatalog, _category] call _getCategoryEntries;
        private _listBox = _display displayCtrl 9052;
        private _supplyCtrl = _display displayCtrl 9051;
        private _categoryCtrl = _display displayCtrl 9053;
        private _infoCtrl = _display displayCtrl 9054;
        private _buildCtrl = _display displayCtrl 9055;
        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

        missionNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", _category];
        missionNamespace setVariable ["MWF_VehicleMenu_CurrentEntries", _entries];

        if (!isNull _categoryCtrl) then { _categoryCtrl ctrlSetText format ["Vehicle Menu | %1", _category]; };
        if (!isNull _supplyCtrl) then { _supplyCtrl ctrlSetText format ["Supplies: %1", _supplies]; };
        if (!isNull _buildCtrl) then { _buildCtrl ctrlEnable false; };

        lbClear _listBox;
        if (_entries isEqualTo []) then {
            private _idx = _listBox lbAdd "No preset entries in this category.";
            _listBox lbSetData [_idx, "-1"];
            _listBox lbSetColor [_idx, [0.6, 0.6, 0.6, 1]];
            if (!isNull _infoCtrl) then {
                _infoCtrl ctrlSetStructuredText parseText "<t color='#CCCCCC'>No vehicles configured in this category.</t>";
            };
            []
        } else {
            {
                private _entry = _x;
                _entry params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5"];
                private _evaluation = [_entry] call _evaluateEntry;
                private _isLocked = _evaluation param [0, false];
                private _lockReason = _evaluation param [1, "Ready to build."];
                private _canAfford = _evaluation param [2, true];

                private _suffixParts = [format ["%1 S", _cost], format ["T%1", _minTier]];
                if (_isTier5) then { _suffixParts pushBack "T5"; };
                private _requiredUnlockUpper = toUpper _requiredUnlock;
                if (_requiredUnlockUpper in ["ARMOR", "HELI", "JETS"]) then { _suffixParts pushBack _requiredUnlockUpper; };
                if (_isLocked) then { _suffixParts pushBack "LOCKED"; };

                private _label = format ["%1 [%2]", _displayName, _suffixParts joinString " | "];
                private _idx = _listBox lbAdd _label;
                _listBox lbSetData [_idx, str _forEachIndex];
                _listBox lbSetValue [_idx, _cost];

                if (_isLocked) then {
                    _listBox lbSetColor [_idx, [0.55, 0.55, 0.55, 1]];
                } else {
                    if (!_canAfford) then {
                        _listBox lbSetColor [_idx, [1, 0.3, 0.3, 1]];
                    };
                };
            } forEach _entries;

            _listBox lbSetCurSel 0;
            ["SHOW_SELECTION"] call MWF_fnc_terminal_vehicleMenu;
            _entries
        }
    };

    case "SHOW_SELECTION": {
        private _display = findDisplay 9050;
        if (isNull _display) exitWith { false };

        private _listBox = _display displayCtrl 9052;
        private _infoCtrl = _display displayCtrl 9054;
        private _buildCtrl = _display displayCtrl 9055;
        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _selectedIndex = lbCurSel _listBox;

        if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
            if (!isNull _buildCtrl) then { _buildCtrl ctrlEnable false; };
            if (!isNull _infoCtrl) then {
                _infoCtrl ctrlSetStructuredText parseText "<t color='#CCCCCC'>Select a vehicle entry.</t>";
            };
            false
        };

        private _entry = _entries select _selectedIndex;
        _entry params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5"];
        private _evaluation = [_entry] call _evaluateEntry;
        private _isLocked = _evaluation param [0, false];
        private _lockReason = _evaluation param [1, "Ready to build."];
        private _statusText = if (_isLocked) then { format ["Locked: %1", _lockReason] } else { _lockReason };

        if (!isNull _infoCtrl) then {
            _infoCtrl ctrlSetStructuredText parseText format [
                "<t size='1.1' color='#FFFFFF'>%1</t><br/><t color='#D7D7D7'>Class: %2</t><br/><t color='#D7D7D7'>Cost: %3 Supplies</t><br/><t color='#D7D7D7'>Required Base Tier: %4</t><br/><t color='#D7D7D7'>Unlock Path: %5</t><br/><t color='#D7D7D7'>Tier 5 Entry: %6</t><br/><t color='#A7D7A7'>%7</t>",
                _displayName,
                _className,
                _cost,
                _minTier,
                if (_requiredUnlock isEqualTo "") then { "None" } else { _requiredUnlock },
                if (_isTier5) then { "Yes" } else { "No" },
                _statusText
            ];
        };

        if (!isNull _buildCtrl) then {
            _buildCtrl ctrlEnable (!_isLocked);
        };

        true
    };

    case "PURCHASE": {
        private _display = findDisplay 9050;
        if (isNull _display) exitWith { false };

        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _category = missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];
        private _selectedIndex = if (_selectionMode isEqualTo "SELECT") then {
            _payload param [1, -1, [0]]
        } else {
            lbCurSel (_display displayCtrl 9052)
        };

        if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
            systemChat format ["Vehicle Menu: invalid selection in category %1.", _category];
            false
        };

        private _entry = _entries select _selectedIndex;
        private _evaluation = [_entry] call _evaluateEntry;
        private _isLocked = _evaluation param [0, false];
        private _lockReason = _evaluation param [1, "Vehicle locked."];
        if (_isLocked) exitWith {
            [["VEHICLE LOCKED", _lockReason], "warning"] call MWF_fnc_showNotification;
            false
        };

        closeDialog 0;
        [_entry, missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", _terminal]] call MWF_fnc_beginVehiclePlacement
    };

    default {
        _publicCatalog
    };
};
