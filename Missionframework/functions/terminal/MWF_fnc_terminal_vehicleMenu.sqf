/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_terminal_vehicleMenu
    Project: Military War Framework

    Description:
    Separate terminal-style vehicle purchase dialog.
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
if (_modeUpper isEqualTo "CATEGORY") then { _modeUpper = "REFRESH"; };

private _catalogRaw = [] call MWF_fnc_getVehicleCatalog;
private _metaBlock = (_catalogRaw select { (_x param [0, ""]) isEqualTo "__META__" });
private _meta = if (_metaBlock isEqualTo []) then { [] } else { (_metaBlock select 0) param [1, []] };
private _totalEntries = ((_meta select { (_x param [0, ""]) isEqualTo "totalEntries" }) param [0, ["totalEntries", 0]]) param [1, 0];
private _emptyCategories = ((_meta select { (_x param [0, ""]) isEqualTo "emptyCategories" }) param [0, ["emptyCategories", []]]) param [1, []];
private _invalidEntries = ((_meta select { (_x param [0, ""]) isEqualTo "invalidEntries" }) param [0, ["invalidEntries", 0]]) param [1, 0];
private _publicCatalog = _catalogRaw select { (_x param [0, ""]) != "__META__" };

private _validCategories = ["LIGHT", "APC", "TANKS", "HELIS", "JETS"];
private _buttonMap = [
    ["LIGHT", 9060],
    ["APC", 9061],
    ["TANKS", 9062],
    ["HELIS", 9063],
    ["JETS", 9064]
];

private _getCategoryEntries = {
    params ["_catalog", ["_category", "LIGHT", [""]]];
    private _categoryUpper = toUpper _category;
    private _found = _catalog select { (_x param [0, ""]) isEqualTo _categoryUpper };
    if (_found isEqualTo []) exitWith { [] };
    (_found select 0) param [1, []]
};

private _getCategoryLabel = {
    switch (toUpper (_this param [0, "LIGHT"])) do {
        case "LIGHT": { "Cars" };
        case "APC": { "APC" };
        case "TANKS": { "Tanks" };
        case "HELIS": { "Helis" };
        case "JETS": { "Jets" };
        default { toUpper (_this param [0, "LIGHT"]) };
    };
};

private _getCategoryFallbackIcon = {
    switch (toUpper (_this param [0, "LIGHT"])) do {
        case "APC": { "\A3\ui_f\data\map\vehicleicons\iconAPC_ca.paa" };
        case "TANKS": { "\A3\ui_f\data\map\vehicleicons\iconTank_ca.paa" };
        case "HELIS": { "\A3\ui_f\data\map\vehicleicons\iconHelicopter_ca.paa" };
        case "JETS": { "\A3\ui_f\data\map\vehicleicons\iconPlane_ca.paa" };
        default { "\A3\ui_f\data\map\vehicleicons\iconCar_ca.paa" };
    };
};

private _getEntryIcon = {
    params ["_className", ["_category", "LIGHT", [""]]];
    private _icon = getText (configFile >> "CfgVehicles" >> _className >> "icon");
    if (_icon isEqualTo "") then {
        _icon = [_category] call _getCategoryFallbackIcon;
    };
    _icon
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
    private _debugMode = missionNamespace getVariable ["MWF_DebugMode", false];
    private _lockReason = if (_debugMode) then {"Ready to build. DEBUG progression override active."} else {"Ready to build."};
    private _isLocked = false;

    if (_className isEqualTo "") exitWith { [true, "Empty preset placeholder.", false, false] };

    if (_isTier5 && {!( ["TIER5"] call MWF_fnc_hasProgressionAccess )}) then {
        _isLocked = true;
        _lockReason = "Requires main operation: Apex Predator.";
    };

    if (!_isLocked) then {
        switch (toUpper _requiredUnlock) do {
            case "ARMOR": {
                if !(["ARMOR"] call MWF_fnc_hasProgressionAccess) then {
                    _isLocked = true;
                    _lockReason = "Requires main operation: Steel Rain.";
                };
            };
            case "HELI": {
                if !(["HELI"] call MWF_fnc_hasProgressionAccess) then {
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
                if !(["JETS"] call MWF_fnc_hasProgressionAccess) then {
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

    private _canAfford = _supplies >= _cost;
    private _insufficientFunds = (!_isLocked && {!_canAfford});
    if (_insufficientFunds) then {
        _lockReason = format ["Insufficient Supplies: %1 needed.", _cost];
    };

    [_isLocked, _lockReason, _canAfford, _insufficientFunds]
};

private _formatTerminalStatus = {
    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
    private _carriedIntel = player getVariable ["MWF_carriedIntelValue", 0];
    private _worldTier = missionNamespace getVariable ["MWF_WorldTier", 1];
    private _baseTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
    private _phase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];

    format [
        "<t size='0.9' color='#FFFFFF'>SUP %1</t><t color='#AAAAAA'> | </t><t size='0.9' color='#8CC8FF'>INT %2</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFD27A'>TEMP %3</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>WORLD T%4</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>BASE T%5</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>PHASE %6</t>",
        _supplies,
        _intel,
        _carriedIntel,
        _worldTier,
        _baseTier,
        _phase
    ]
};

private _updateCategoryButtons = {
    params [["_display", displayNull, [displayNull]], ["_activeCategory", "LIGHT", [""]]];
    if (isNull _display) exitWith {};
    {
        _x params ["_category", "_idc"];
        private _ctrl = _display displayCtrl _idc;
        if (!isNull _ctrl) then {
            if (_category isEqualTo _activeCategory) then {
                _ctrl ctrlSetBackgroundColor [1, 1, 1, 0.08];
                _ctrl ctrlSetTextColor [1, 1, 1, 1];
            } else {
                _ctrl ctrlSetBackgroundColor [0, 0, 0, 0];
                _ctrl ctrlSetTextColor [0.94, 0.94, 0.94, 1];
            };
        };
    } forEach _buttonMap;
};

private _updateHeader = {
    params [
        ["_display", displayNull, [displayNull]],
        ["_category", "LIGHT", [""]],
        ["_entries", [], [[]]],
        ["_selectedIndex", -1, [0]]
    ];

    if (isNull _display) exitWith {};
    private _categoryCtrl = _display displayCtrl 9053;
    private _supplyCtrl = _display displayCtrl 9051;
    private _listStatusCtrl = _display displayCtrl 9056;
    private _terminalStatusCtrl = _display displayCtrl 9057;

    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _entryCount = count _entries;
    private _selectedText = if (_selectedIndex >= 0 && {_selectedIndex < _entryCount}) then {
        format ["Row %1/%2 selected", _selectedIndex + 1, _entryCount]
    } else {
        if (_entryCount > 0) then { format ["Rows: %1", _entryCount] } else { "Rows: 0" }
    };

    if (!isNull _categoryCtrl) then {
        _categoryCtrl ctrlSetText format ["Vehicle Menu | %1", [_category] call _getCategoryLabel];
    };

    if (!isNull _supplyCtrl) then {
        _supplyCtrl ctrlSetText format ["Supplies: %1 | %2", _supplies, _selectedText];
    };

    if (!isNull _listStatusCtrl) then {
        _listStatusCtrl ctrlSetText format ["Available entries in %1: %2", [_category] call _getCategoryLabel, _entryCount];
    };

    if (!isNull _terminalStatusCtrl) then {
        _terminalStatusCtrl ctrlSetStructuredText parseText (call _formatTerminalStatus);
    };

    [_display, _category] call _updateCategoryButtons;
};

switch (_modeUpper) do {
    case "OPEN": {
        if (_totalEntries <= 0) exitWith {
            [["VEHICLE MENU", "Active BLUFOR preset has no valid vehicle entries."], "warning"] call MWF_fnc_showNotification;
            systemChat "Vehicle Menu unavailable: preset returned no valid vehicle entries.";
            []
        };

        if (isNull _terminal) then {
            _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", objNull];
        };

        missionNamespace setVariable ["MWF_VehicleMenu_LastTerminal", _terminal];
        missionNamespace setVariable ["MWF_VehicleMenu_LastCatalog", _publicCatalog];

        private _requestedCategory = toUpper (missionNamespace getVariable ["MWF_VehicleMenu_LastCategory", "LIGHT"]);
        if !(_requestedCategory in _validCategories) then { _requestedCategory = "LIGHT"; };

        private _resolvedCategory = _requestedCategory;
        if (([_publicCatalog, _resolvedCategory] call _getCategoryEntries) isEqualTo []) then {
            {
                if !(([_publicCatalog, _x] call _getCategoryEntries) isEqualTo []) exitWith { _resolvedCategory = _x; };
            } forEach _validCategories;
        };

        missionNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", _resolvedCategory];
        missionNamespace setVariable ["MWF_VehicleMenu_CurrentEntries", []];
        missionNamespace setVariable ["MWF_VehicleMenu_LastCategory", _resolvedCategory];

        closeDialog 0;
        createDialog "IronMantle_BuyMenu";
        private _display = findDisplay 9050;
        if (isNull _display) exitWith {
            systemChat "Vehicle Menu failed to open.";
            []
        };

        if (_emptyCategories isNotEqualTo []) then {
            [["VEHICLE MENU", format ["Preset categories empty: %1", _emptyCategories joinString ", "]], "warning"] call MWF_fnc_showNotification;
        };
        if (_invalidEntries > 0) then {
            [["VEHICLE MENU", format ["Invalid preset entries skipped: %1", _invalidEntries]], "warning"] call MWF_fnc_showNotification;
        };

        [_display, _resolvedCategory, [], -1] call _updateHeader;
        ["REFRESH", _terminal, [_resolvedCategory]] call MWF_fnc_terminal_vehicleMenu;
        _publicCatalog
    };

    case "REFRESH": {
        private _display = findDisplay 9050;
        if (isNull _display) exitWith { [] };

        private _category = toUpper (_payload param [0, missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"], [""]]);
        private _entries = [_publicCatalog, _category] call _getCategoryEntries;
        private _listBox = _display displayCtrl 9052;
        private _infoCtrl = _display displayCtrl 9054;
        private _buildCtrl = _display displayCtrl 9055;
        private _iconCtrl = _display displayCtrl 9058;

        missionNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", _category];
        missionNamespace setVariable ["MWF_VehicleMenu_LastCategory", _category];
        missionNamespace setVariable ["MWF_VehicleMenu_CurrentEntries", _entries];

        if (!isNull _buildCtrl) then {
            _buildCtrl ctrlEnable false;
            _buildCtrl ctrlSetTooltip "Select an available vehicle to purchase.";
            _buildCtrl ctrlSetText "Purchase";
        };

        if (!isNull _iconCtrl) then { _iconCtrl ctrlSetText ""; };

        lbClear _listBox;
        if (_entries isEqualTo []) then {
            private _idx = _listBox lbAdd "No preset entries in this category.";
            _listBox lbSetData [_idx, "-1"];
            _listBox lbSetColor [_idx, [0.55, 0.55, 0.55, 1]];
            _listBox lbSetTooltip [_idx, "This category currently has no valid preset entries."];
            if (!isNull _infoCtrl) then {
                _infoCtrl ctrlSetStructuredText parseText "<t color='#CCCCCC'>No vehicles configured in this category.</t>";
            };
            [_display, _category, _entries, -1] call _updateHeader;
            []
        } else {
            {
                private _entry = _x;
                _entry params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5"];
                private _evaluation = [_entry] call _evaluateEntry;
                private _isLocked = _evaluation param [0, false];
                private _lockReason = _evaluation param [1, "Ready to build."];
                private _canAfford = _evaluation param [2, true];
                private _insufficientFunds = _evaluation param [3, false];

                private _idx = _listBox lbAdd format ["%1  |  %2 Supplies", _displayName, _cost];
                _listBox lbSetData [_idx, str _forEachIndex];
                _listBox lbSetValue [_idx, _cost];
                _listBox lbSetPicture [_idx, [_className, _category] call _getEntryIcon];
                _listBox lbSetTooltip [_idx, _lockReason];

                if (_isLocked) then {
                    _listBox lbSetColor [_idx, [0.92, 0.25, 0.25, 1]];
                } else {
                    if (_insufficientFunds) then {
                        _listBox lbSetColor [_idx, [0.45, 0.45, 0.45, 1]];
                    } else {
                        _listBox lbSetColor [_idx, [0.96, 0.96, 0.96, 1]];
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
        private _iconCtrl = _display displayCtrl 9058;
        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _category = missionNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];
        private _selectedIndex = lbCurSel _listBox;

        if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
            if (!isNull _buildCtrl) then {
                _buildCtrl ctrlEnable false;
                _buildCtrl ctrlSetTooltip "Select an available vehicle to purchase.";
            };
            if (!isNull _infoCtrl) then {
                _infoCtrl ctrlSetStructuredText parseText "<t color='#CCCCCC'>Select a vehicle entry.</t>";
            };
            if (!isNull _iconCtrl) then { _iconCtrl ctrlSetText ""; };
            [_display, _category, _entries, -1] call _updateHeader;
            false
        };

        private _entry = _entries select _selectedIndex;
        _entry params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5"];
        private _evaluation = [_entry] call _evaluateEntry;
        private _isLocked = _evaluation param [0, false];
        private _lockReason = _evaluation param [1, "Ready to build."];
        private _canAfford = _evaluation param [2, true];
        private _insufficientFunds = _evaluation param [3, false];
        private _unlockPath = if (_requiredUnlock isEqualTo "") then { "Standard" } else { toUpper _requiredUnlock };
        private _statusColor = if (_isLocked) then { "#FF5555" } else { if (_insufficientFunds) then { "#7A7A7A" } else { "#A7D7A7" } };
        private _statusText = if (_isLocked) then {
            _lockReason
        } else {
            if (_insufficientFunds) then { _lockReason } else { "Ready to purchase and enter ghost placement." }
        };

        if (!isNull _iconCtrl) then {
            _iconCtrl ctrlSetText ([_className, _category] call _getEntryIcon);
        };

        if (!isNull _infoCtrl) then {
            _infoCtrl ctrlSetStructuredText parseText format [
                "<t size='1.15' color='#FFFFFF'>%1</t><br/><t color='#D7D7D7'>Class: %2</t><br/><t color='#D7D7D7'>Category: %3</t><br/><t color='#D7D7D7'>Cost: %4 Supplies</t><br/><t color='#D7D7D7'>Required Base Tier: %5</t><br/><t color='#D7D7D7'>Unlock Path: %6</t><br/><t color='#D7D7D7'>Tier 5 Entry: %7</t><br/><br/><t color='%8'>%9</t>",
                _displayName,
                _className,
                [_category] call _getCategoryLabel,
                _cost,
                _minTier,
                _unlockPath,
                if (_isTier5) then { "Yes" } else { "No" },
                _statusColor,
                _statusText
            ];
        };

        if (!isNull _buildCtrl) then {
            _buildCtrl ctrlEnable (!_isLocked && _canAfford);
            _buildCtrl ctrlSetTooltip _statusText;
        };

        [_display, _category, _entries, _selectedIndex] call _updateHeader;
        true
    };

    case "PURCHASE": {
        private _display = findDisplay 9050;
        if (isNull _display) exitWith { false };

        private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []];
        private _selectedIndex = lbCurSel (_display displayCtrl 9052);

        if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
            systemChat "Vehicle Menu: invalid selection.";
            false
        };

        private _entry = _entries select _selectedIndex;
        private _evaluation = [_entry] call _evaluateEntry;
        private _isLocked = _evaluation param [0, false];
        private _lockReason = _evaluation param [1, "Vehicle locked."];
        private _canAfford = _evaluation param [2, true];

        if (_isLocked) exitWith {
            [["VEHICLE LOCKED", _lockReason], "warning"] call MWF_fnc_showNotification;
            false
        };

        if !(_canAfford) exitWith {
            [["VEHICLE MENU", _lockReason], "warning"] call MWF_fnc_showNotification;
            false
        };

        private _terminalRef = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", _terminal];
        closeDialog 0;
        [_entry, _terminalRef] spawn {
            params ["_entryLocal", "_terminalLocal"];
            uiSleep 0.05;
            [_entryLocal, _terminalLocal] call MWF_fnc_beginVehiclePlacement;
        };
        true
    };

    default {
        _publicCatalog
    };
};
