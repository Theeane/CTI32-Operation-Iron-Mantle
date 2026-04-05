params [["_display", displayNull, [displayNull]]];
if (isNull _display) then {
    _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
};
if (isNull _display) exitWith { false };
if !((uiNamespace getVariable ["MWF_DataHub_Mode", ""]) isEqualTo "VEHICLE_MENU") exitWith { false };

private _dynamicCtrls = uiNamespace getVariable ["MWF_VehicleMenu_DynamicCtrls", []];
private _mapFrame = _display displayCtrl 12204;
private _mapCtrl = _display displayCtrl 12205;
private _statusCtrl = _display displayCtrl 12206;
private _infoCtrl = _display displayCtrl 12216;
private _actionCtrl = _display displayCtrl 12207;
private _leftCtrl = _display displayCtrl 12215;
private _terminalStatusCtrl = _display displayCtrl 12218;

if (!isNull _mapFrame) then { _mapFrame ctrlShow false; };
if (!isNull _mapCtrl) then { _mapCtrl ctrlShow false; };
if (!isNull _infoCtrl) then { _infoCtrl ctrlShow false; };

private _buttonDefs = [
    [12210, "Cars", "['LIGHT'] call MWF_fnc_vehicleMenuSetCategory;"],
    [12211, "APC", "['APC'] call MWF_fnc_vehicleMenuSetCategory;"],
    [12212, "Tanks", "['TANKS'] call MWF_fnc_vehicleMenuSetCategory;"],
    [12213, "Helis", "['HELIS'] call MWF_fnc_vehicleMenuSetCategory;"],
    [12214, "Jets", "['JETS'] call MWF_fnc_vehicleMenuSetCategory;"]
];
{
    _x params ["_idc", "_text", "_action"];
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlSetText _text;
        buttonSetAction [_ctrl, _action];
        _ctrl ctrlSetTooltip format ["Open %1 list.", _text];
        _ctrl ctrlEnable true;
    };
} forEach _buttonDefs;

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _carriedIntel = player getVariable ["MWF_carriedIntelValue", 0];
private _worldTier = missionNamespace getVariable ["MWF_WorldTier", 1];
private _baseTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _phase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
private _debugMode = missionNamespace getVariable ["MWF_DebugMode", ((["MWF_Param_DebugMode", 0] call BIS_fnc_getParamValue) > 0)];
if (!isNull _terminalStatusCtrl) then {
    _terminalStatusCtrl ctrlSetStructuredText parseText format [
        "<t size='0.9' color='#FFFFFF'>SUP %1</t><t color='#AAAAAA'> | </t><t size='0.9' color='#8CC8FF'>INT %2</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFD27A'>TEMP %3</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>WORLD T%4</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>BASE T%5</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>PHASE %6</t>",
        _supplies, _intel, _carriedIntel, _worldTier, _baseTier, _phase
    ];
};

private _catalog = uiNamespace getVariable ["MWF_VehicleMenu_Catalog", []];
if (_catalog isEqualTo []) then {
    private _raw = [] call MWF_fnc_getVehicleCatalog;
    _catalog = [];
    {
        if ((_x param [0, ""]) != "__META__") then {
            _catalog pushBack _x;
        };
    } forEach _raw;
    uiNamespace setVariable ["MWF_VehicleMenu_Catalog", _catalog];
};

private _getCategoryEntries = {
    params ["_catalogData", "_categoryKey"];
    private _found = _catalogData select { (_x param [0, ""]) isEqualTo _categoryKey };
    if (_found isEqualTo []) exitWith { [] };
    (_found # 0) param [1, []]
};

private _fallbackIcons = createHashMapFromArray [
    ["LIGHT", getText (configFile >> "CfgVehicles" >> "B_MRAP_01_F" >> "icon")],
    ["APC", getText (configFile >> "CfgVehicles" >> "B_APC_Wheeled_01_cannon_F" >> "icon")],
    ["TANKS", getText (configFile >> "CfgVehicles" >> "B_MBT_01_cannon_F" >> "icon")],
    ["HELIS", getText (configFile >> "CfgVehicles" >> "B_Heli_Light_01_F" >> "icon")],
    ["JETS", getText (configFile >> "CfgVehicles" >> "B_Plane_Fighter_01_F" >> "icon")]
];

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

    private _state = createHashMapFromArray [
        ["isLocked", false],
        ["canAfford", true],
        ["reason", "Ready to purchase."],
        ["statusText", "AVAILABLE"]
    ];

    if (_className isEqualTo "") exitWith {
        _state set ["isLocked", true];
        _state set ["canAfford", false];
        _state set ["reason", "Invalid preset entry."];
        _state set ["statusText", "INVALID"];
        _state
    };

    if (_debugMode) exitWith {
        _state set ["canAfford", true];
        _state set ["reason", "Ready to purchase. DEBUG progression override active."];
        _state set ["statusText", "AVAILABLE"];
        _state
    };

    if (_isTier5 && {!( ["TIER5"] call MWF_fnc_hasProgressionAccess )}) then {
        _state set ["isLocked", true];
        _state set ["reason", "Requires BLUFOR Tier 5 upgrade."];
        _state set ["statusText", "LOCKED"];
    };

    if !(_state get "isLocked") then {
        switch (toUpper _requiredUnlock) do {
            case "ARMOR": {
                if !( ["ARMOR"] call MWF_fnc_hasProgressionAccess ) then {
                    _state set ["isLocked", true];
                    _state set ["reason", "Requires main operation: Steel Rain."];
                    _state set ["statusText", "LOCKED"];
                };
            };
            case "HELI": {
                if !( ["HELI"] call MWF_fnc_hasProgressionAccess ) then {
                    _state set ["isLocked", true];
                    _state set ["reason", "Requires main operation: Sky Guardian."];
                    _state set ["statusText", "LOCKED"];
                } else {
                    if !([_requiredUnlock] call _hasRequiredUpgradeStructure) then {
                        _state set ["isLocked", true];
                        _state set ["reason", "Build the Helicopter Uplink at the MOB first."];
                        _state set ["statusText", "LOCKED"];
                    };
                };
            };
            case "JETS": {
                if !( ["JETS"] call MWF_fnc_hasProgressionAccess ) then {
                    _state set ["isLocked", true];
                    _state set ["reason", "Requires main operation: Point Blank."];
                    _state set ["statusText", "LOCKED"];
                } else {
                    if !([_requiredUnlock] call _hasRequiredUpgradeStructure) then {
                        _state set ["isLocked", true];
                        _state set ["reason", "Build Aircraft Control at the MOB first."];
                        _state set ["statusText", "LOCKED"];
                    };
                };
            };
        };
    };

    if !(_state get "isLocked") then {
        if (_baseTier < _minTier) then {
            _state set ["isLocked", true];
            _state set ["reason", format ["Requires Base Tier %1.", _minTier]];
            _state set ["statusText", "LOCKED"];
        };
    };

    if (_supplies < _cost) then {
        _state set ["canAfford", false];
        if (_state get "isLocked") then {
            _state set ["reason", format ["%1 | Also need %2 Supplies.", _state get "reason", _cost]];
        } else {
            _state set ["reason", format ["Insufficient Supplies: %1 needed.", _cost]];
            _state set ["statusText", "NO FUNDS"];
        };
    };

    _state
};

private _category = uiNamespace getVariable ["MWF_VehicleMenu_CurrentCategory", "LIGHT"];
private _entries = [_catalog, _category] call _getCategoryEntries;
if (_entries isEqualTo []) then {
    {
        private _try = [_catalog, _x] call _getCategoryEntries;
        if (_try isNotEqualTo []) exitWith {
            _category = _x;
            _entries = _try;
        };
    } forEach ["LIGHT", "APC", "TANKS", "HELIS", "JETS"];
    uiNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", _category];
};

private _decoratedEntries = [];
{
    private _entry = +_x;
    private _state = [_entry] call _evaluateEntry;
    private _className = _entry param [0, "", [""]];
    private _cfg = configFile >> "CfgVehicles" >> _className;
    private _icon = if (isClass _cfg) then { getText (_cfg >> "icon") } else { "" };
    if (_icon isEqualTo "") then { _icon = _fallbackIcons getOrDefault [_category, ""]; };

    private _transportSeats = if (isClass _cfg) then { getNumber (_cfg >> "transportSoldier") } else { 0 };
    private _role = switch (true) do {
        case (_category isEqualTo "LIGHT" && {_transportSeats > 6}): { "Transport" };
        case (_category isEqualTo "LIGHT"): { "Light Vehicle" };
        case (_category isEqualTo "APC"): { "Armored Personnel Carrier" };
        case (_category isEqualTo "TANKS"): { "Main Battle Tank" };
        case (_category isEqualTo "HELIS"): { if (_transportSeats > 0) then { "Transport Helicopter" } else { "Attack Helicopter" } };
        case (_category isEqualTo "JETS"): { "Jet Aircraft" };
        default { _category };
    };

    private _subText = _role;
    if ((_entry param [5, false]) isEqualTo true) then {
        _subText = _subText + " | Tier 5";
    } else {
        _subText = _subText + format [" | Tier %1", _entry param [2, 1]];
    };

    _entry pushBack _icon;
    _entry pushBack _subText;
    _entry pushBack _state;
    _decoratedEntries pushBack _entry;
} forEach _entries;
_entries = _decoratedEntries;
uiNamespace setVariable ["MWF_VehicleMenu_CurrentEntries", _entries];

private _selectedIndex = uiNamespace getVariable ["MWF_VehicleMenu_SelectedIndex", -1];
if (_selectedIndex < 0 && {count _entries > 0}) then { _selectedIndex = 0; };
if (_selectedIndex >= count _entries) then { _selectedIndex = (count _entries) - 1; };
uiNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", _selectedIndex];

if (_dynamicCtrls isEqualTo []) then {
    private _listX = 0.190 * safezoneW + safezoneX;
    private _listY = 0.255 * safezoneH + safezoneY;
    private _listW = 0.405 * safezoneW;
    private _listH = 0.338 * safezoneH;
    private _panelGap = 0.012 * safezoneW;
    private _infoX = _listX + _listW + _panelGap;
    private _infoY = _listY;
    private _infoW = 0.203 * safezoneW;
    private _infoH = _listH;

    private _listBg = _display ctrlCreate ["RscText", 12350];
    _listBg ctrlSetPosition [_listX, _listY, _listW, _listH];
    _listBg ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.72];
    _listBg ctrlCommit 0;

    private _listGroup = _display ctrlCreate ["RscControlsGroup", 12351];
    _listGroup ctrlSetPosition [_listX + 0.004 * safezoneW, _listY + 0.006 * safezoneH, _listW - 0.008 * safezoneW, _listH - 0.012 * safezoneH];
    _listGroup ctrlCommit 0;

    private _infoBg = _display ctrlCreate ["RscText", 12352];
    _infoBg ctrlSetPosition [_infoX, _infoY, _infoW, _infoH];
    _infoBg ctrlSetBackgroundColor [0.04, 0.04, 0.04, 0.72];
    _infoBg ctrlCommit 0;

    private _infoIcon = _display ctrlCreate ["RscPicture", 12353];
    _infoIcon ctrlSetPosition [_infoX + 0.012 * safezoneW, _infoY + 0.014 * safezoneH, 0.040 * safezoneW, 0.060 * safezoneH];
    _infoIcon ctrlCommit 0;

    private _infoTitle = _display ctrlCreate ["RscText", 12354];
    _infoTitle ctrlSetPosition [_infoX + 0.060 * safezoneW, _infoY + 0.018 * safezoneH, _infoW - 0.072 * safezoneW, 0.038 * safezoneH];
    _infoTitle ctrlSetFontHeight 0.036;
    _infoTitle ctrlSetTextColor [1,1,1,1];
    _infoTitle ctrlCommit 0;

    private _infoBody = _display ctrlCreate ["RscStructuredText", 12355];
    _infoBody ctrlSetPosition [_infoX + 0.014 * safezoneW, _infoY + 0.082 * safezoneH, _infoW - 0.028 * safezoneW, _infoH - 0.096 * safezoneH];
    _infoBody ctrlCommit 0;

    _dynamicCtrls = [12350,12351,12352,12353,12354,12355];
    uiNamespace setVariable ["MWF_VehicleMenu_DynamicCtrls", _dynamicCtrls];
};

private _listGroup = _display displayCtrl 12351;
if (isNull _listGroup) exitWith { false };

{
    private _ctrl = _display displayCtrl _x;
    if (!isNull _ctrl) then { ctrlDelete _ctrl; };
} forEach (uiNamespace getVariable ["MWF_VehicleMenu_RowCtrls", []]);

private _rowIdcs = [];
private _groupPos = ctrlPosition _listGroup;
private _rowW = (_groupPos # 2) - 0.010 * safezoneW;
private _rowH = 0.066 * safezoneH;
private _rowGap = 0.004 * safezoneH;

{
    private _y = _forEachIndex * (_rowH + _rowGap);
    _x params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5", "_iconPath", "_subText", "_state"];
    private _isSelected = _forEachIndex isEqualTo _selectedIndex;
    private _isLocked = _state getOrDefault ["isLocked", true];
    private _canAfford = _state getOrDefault ["canAfford", false];

    private _bgIdc = 12400 + (_forEachIndex * 11);
    private _selIdc = _bgIdc + 1;
    private _btnIdc = _bgIdc + 2;
    private _iconIdc = _bgIdc + 3;
    private _nameIdc = _bgIdc + 4;
    private _subIdc = _bgIdc + 5;
    private _priceIdc = _bgIdc + 6;
    private _frameA = _bgIdc + 7;
    private _frameB = _bgIdc + 8;
    private _frameC = _bgIdc + 9;
    private _frameD = _bgIdc + 10;

    private _bg = _display ctrlCreate ["RscText", _bgIdc, _listGroup];
    _bg ctrlSetPosition [0, _y, _rowW, _rowH];
    _bg ctrlSetBackgroundColor [0, 0, 0, 0.18];
    _bg ctrlCommit 0;

    private _selBg = _display ctrlCreate ["RscText", _selIdc, _listGroup];
    _selBg ctrlSetPosition [0, _y, _rowW, _rowH];
    _selBg ctrlSetBackgroundColor [1, 1, 1, if (_isSelected) then {0.10} else {0}];
    _selBg ctrlCommit 0;

    private _button = _display ctrlCreate ["MWF_RscTerminalButton", _btnIdc, _listGroup];
    _button ctrlSetPosition [0, _y, _rowW, _rowH];
    _button ctrlSetText "";
    _button ctrlSetTooltip (_state getOrDefault ["reason", "Vehicle entry."]);
    buttonSetAction [_button, format ["[%1] call MWF_fnc_vehicleMenuSelectEntry;", _forEachIndex]];
    _button ctrlCommit 0;

    private _icon = _display ctrlCreate ["RscPicture", _iconIdc, _listGroup];
    _icon ctrlSetPosition [0.008 * safezoneW, _y + 0.010 * safezoneH, 0.026 * safezoneW, 0.040 * safezoneH];
    _icon ctrlSetText _iconPath;
    _icon ctrlSetTextColor [1,1,1, if (_isLocked) then {0.45} else {0.92}];
    _icon ctrlCommit 0;

    private _name = _display ctrlCreate ["RscText", _nameIdc, _listGroup];
    _name ctrlSetPosition [0.038 * safezoneW, _y + 0.006 * safezoneH, _rowW - 0.140 * safezoneW, 0.030 * safezoneH];
    _name ctrlSetFontHeight 0.030;
    _name ctrlSetText _displayName;
    _name ctrlSetTextColor (if (_isLocked) then {[1,0.45,0.45,0.95]} else {[1,1,1,1]});
    _name ctrlCommit 0;

    private _sub = _display ctrlCreate ["RscText", _subIdc, _listGroup];
    _sub ctrlSetPosition [0.038 * safezoneW, _y + 0.031 * safezoneH, _rowW - 0.140 * safezoneW, 0.024 * safezoneH];
    _sub ctrlSetFontHeight 0.020;
    _sub ctrlSetText _subText;
    _sub ctrlSetTextColor (if (_isLocked) then {[0.92,0.55,0.55,0.85]} else {[0.80,0.80,0.80,0.92]});
    _sub ctrlCommit 0;

    private _price = _display ctrlCreate ["RscText", _priceIdc, _listGroup];
    _price ctrlSetStyle 1;
    _price ctrlSetPosition [_rowW - 0.108 * safezoneW, _y + 0.015 * safezoneH, 0.100 * safezoneW, 0.028 * safezoneH];
    _price ctrlSetFontHeight 0.026;
    _price ctrlSetText format ["%1 SUP", _cost];
    private _priceColor = if (!_canAfford) then {[1,0.4,0.4,0.95]} else { if (_isLocked) then {[0.95,0.65,0.65,0.95]} else {[1,1,1,0.95]} };
    _price ctrlSetTextColor _priceColor;
    _price ctrlCommit 0;

    private _frames = [];
    {
        _x params ["_idc", "_px", "_py", "_pw", "_ph"];
        private _frame = _display ctrlCreate ["RscText", _idc, _listGroup];
        _frame ctrlSetPosition [_px, _py, _pw, _ph];
        _frame ctrlSetBackgroundColor [1,1,1, if (_isSelected) then {0.95} else {0}];
        _frame ctrlCommit 0;
        _frames pushBack _idc;
    } forEach [
        [_frameA, 0, _y, 0.0022 * safezoneW, _rowH],
        [_frameB, _rowW - 0.0022 * safezoneW, _y, 0.0022 * safezoneW, _rowH],
        [_frameC, 0, _y, _rowW, 0.0022 * safezoneH],
        [_frameD, 0, _y + _rowH - 0.0022 * safezoneH, _rowW, 0.0022 * safezoneH]
    ];

    _rowIdcs append [_bgIdc, _selIdc, _btnIdc, _iconIdc, _nameIdc, _subIdc, _priceIdc];
    _rowIdcs append _frames;
} forEach _entries;
uiNamespace setVariable ["MWF_VehicleMenu_RowCtrls", _rowIdcs];


private _selectedEntry = if (_selectedIndex >= 0 && {_selectedIndex < count _entries}) then { _entries # _selectedIndex } else { [] };
private _canPurchase = false;
private _statusText = format ["Vehicle Menu | %1 | Entries: %2", _category, count _entries];
private _detailText = "Select a vehicle.";
private _detailTitle = format ["%1 VEHICLES", _category];
private _detailIcon = _fallbackIcons getOrDefault [_category, ""];

if (_selectedEntry isNotEqualTo []) then {
    _selectedEntry params ["_className", "_cost", "_minTier", "_displayName", "_requiredUnlock", "_isTier5", "_iconPath", "_subText", "_state"];
    _detailTitle = _displayName;
    _detailIcon = _iconPath;
    private _stateText = _state getOrDefault ["statusText", "AVAILABLE"];
    private _reason = _state getOrDefault ["reason", "Ready to purchase."];
    _detailText = format [
        "<t size='1.05'>%1</t><br/><t color='#BFBFBF'>%2</t><br/><br/><t color='#FFFFFF'>Cost:</t> %3 Supplies<br/><t color='#FFFFFF'>Tier:</t> %4<br/><t color='#FFFFFF'>Status:</t> %5<br/><br/><t color='#D8D8D8'>%6</t>",
        _category,
        _subText,
        _cost,
        _minTier,
        _stateText,
        _reason
    ];
    _canPurchase = !(_state getOrDefault ["isLocked", true]) && (_state getOrDefault ["canAfford", false]);
    _statusText = format ["Vehicle Menu | %1 | %2 | %3 Supplies", _category, _displayName, _cost];
};

if (!isNull _statusCtrl) then {
    _statusCtrl ctrlShow true;
    _statusCtrl ctrlSetText _statusText;
};
if (!isNull _leftCtrl) then {
    _leftCtrl ctrlSetText "Back";
    _leftCtrl ctrlEnable true;
    _leftCtrl ctrlSetTooltip "Return to previous view.";
};
if (!isNull _actionCtrl) then {
    _actionCtrl ctrlSetText "Purchase";
    _actionCtrl ctrlEnable _canPurchase;
    _actionCtrl ctrlSetTooltip (if (_canPurchase) then {"Purchase selected vehicle and enter ghost placement."} else {"Select an available vehicle to purchase."});
};

private _infoIconCtrl = _display displayCtrl 12353;
private _infoTitleCtrl = _display displayCtrl 12354;
private _infoBodyCtrl = _display displayCtrl 12355;
if (!isNull _infoIconCtrl) then { _infoIconCtrl ctrlSetText _detailIcon; };
if (!isNull _infoTitleCtrl) then { _infoTitleCtrl ctrlSetText _detailTitle; };
if (!isNull _infoBodyCtrl) then { _infoBodyCtrl ctrlSetStructuredText parseText _detailText; };

true
