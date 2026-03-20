/*
    Author: Theane / ChatGPT
    Function: MWF_fn_garageSystem
    Project: Military War Framework

    Description:
    Unified virtual garage handler.

    Client modes:
    - STATUS
    - PREV
    - NEXT
    - REQUEST_STORE
    - REQUEST_RETRIEVE
    - REQUEST_SCRAP

    Server modes:
    - REGISTER_BUILD
    - STORE
    - RETRIEVE
    - SCRAP
*/

params [
    ["_mode", "STATUS", [""]],
    ["_garage", objNull, [objNull]],
    ["_caller", objNull, [objNull]],
    ["_extra", 0]
];

private _modeUpper = toUpper _mode;

private _summaryDisplay = {
    params ["_garageObj", "_unit"];
    if (isNull _garageObj || {isNull _unit}) exitWith { false };

    private _baseKey = _garageObj getVariable ["MWF_Garage_BaseKey", "MOB"];
    private _baseLabel = _garageObj getVariable ["MWF_Garage_BaseLabel", "Garage"];
    private _summary = + (_garageObj getVariable ["MWF_Garage_InventorySummary", []]);
    private _count = count _summary;
    private _state = + (missionNamespace getVariable ["MWF_Garage_SelectedIndices", []]);
    private _selectedIndex = 0;
    private _match = _state findIf { (_x param [0, ""]) isEqualTo _baseKey };
    if (_match >= 0) then { _selectedIndex = (_state # _match) param [1, 0]; };
    if (_count > 0) then { _selectedIndex = (_selectedIndex max 0) min (_count - 1); } else { _selectedIndex = 0; };

    private _lines = [
        format ["Garage: %1", _baseLabel],
        format ["Stored vehicles: %1", _count]
    ];

    if (_count > 0) then {
        private _entry = _summary # _selectedIndex;
        private _name = _entry param [0, _entry param [1, "Unknown"]];
        private _stateText = _entry param [2, "Stored"];
        _lines pushBack format ["Selected: %1 (%2/%3)", _name, _selectedIndex + 1, _count];
        _lines pushBack format ["State: %1", _stateText];
    } else {
        _lines pushBack "Selected: none";
    };

    hintSilent (_lines joinString "\n");
    true
};

private _selectRelative = {
    params ["_garageObj", "_unit", ["_delta", 1, [0]]];
    if (isNull _garageObj || {isNull _unit}) exitWith { false };

    private _baseKey = _garageObj getVariable ["MWF_Garage_BaseKey", "MOB"];
    private _summary = + (_garageObj getVariable ["MWF_Garage_InventorySummary", []]);
    private _count = count _summary;
    if (_count <= 0) exitWith { [ _garageObj, _unit ] call _summaryDisplay };

    private _state = + (missionNamespace getVariable ["MWF_Garage_SelectedIndices", []]);
    private _idx = _state findIf { (_x param [0, ""]) isEqualTo _baseKey };
    private _selected = 0;
    if (_idx >= 0) then { _selected = (_state # _idx) param [1, 0]; };
    _selected = (_selected + _delta) mod _count;
    if (_selected < 0) then { _selected = _selected + _count; };

    if (_idx >= 0) then {
        _state set [_idx, [_baseKey, _selected]];
    } else {
        _state pushBack [_baseKey, _selected];
    };
    missionNamespace setVariable ["MWF_Garage_SelectedIndices", _state];

    [ _garageObj, _unit ] call _summaryDisplay
};

if (_modeUpper in ["STATUS", "PREV", "NEXT", "REQUEST_STORE", "REQUEST_RETRIEVE", "REQUEST_SCRAP"]) exitWith {
    if (!hasInterface) exitWith { false };
    if (isNull _garage || {isNull _caller}) exitWith { false };

    switch (_modeUpper) do {
        case "STATUS": { [_garage, _caller] call _summaryDisplay; };
        case "PREV": { [_garage, _caller, -1] call _selectRelative; };
        case "NEXT": { [_garage, _caller, 1] call _selectRelative; };
        case "REQUEST_STORE": { ["STORE", _garage, _caller, 0] remoteExecCall ["MWF_fnc_garageSystem", 2]; true };
        case "REQUEST_RETRIEVE": {
            private _state = + (missionNamespace getVariable ["MWF_Garage_SelectedIndices", []]);
            private _baseKey = _garage getVariable ["MWF_Garage_BaseKey", "MOB"];
            private _idx = _state findIf { (_x param [0, ""]) isEqualTo _baseKey };
            private _selected = if (_idx >= 0) then { (_state # _idx) param [1, 0] } else { 0 };
            ["RETRIEVE", _garage, _caller, _selected] remoteExecCall ["MWF_fnc_garageSystem", 2];
            true
        };
        case "REQUEST_SCRAP": { ["SCRAP", _garage, _caller, 0] remoteExecCall ["MWF_fnc_garageSystem", 2]; true };
        default { false };
    };
};

if (!isServer) exitWith { false };
if (isNull _garage) exitWith { false };

private _requestSave = {
    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };
};

private _getStorage = {
    + (missionNamespace getVariable ["MWF_GarageStoredVehicles", []])
};

private _setStorage = {
    params ["_storage"];
    missionNamespace setVariable ["MWF_GarageStoredVehicles", + _storage, true];
};

private _findStorageIndex = {
    params ["_storage", "_baseKey"];
    _storage findIf { (_x param [0, "", [""]]) isEqualTo _baseKey }
};

private _getVehicleDisplayName = {
    params ["_className"];
    private _name = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_name isEqualTo "") then { _name = _className; };
    _name
};

private _getBaseStatus = {
    params ["_garageObj"];
    private _baseType = _garageObj getVariable ["MWF_Garage_BaseType", "MOB"];
    if (_baseType isEqualTo "MOB") exitWith { [true, "MOB garage ready."] };

    private _baseKey = _garageObj getVariable ["MWF_Garage_BaseKey", ""];
    private _label = _garageObj getVariable ["MWF_Garage_BaseLabel", "FOB"];
    private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _match = _registry findIf { format ["FOB:%1", _x param [2, "", [""]]] isEqualTo _baseKey };
    if (_match < 0) exitWith { [false, format ["%1 garage unavailable: FOB not present.", _label]] };

    private _terminal = (_registry # _match) param [1, objNull];
    if (isNull _terminal) exitWith { [false, format ["%1 garage unavailable: terminal missing.", _label]] };
    if (_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith { [false, format ["%1 garage unavailable: FOB damaged/offline.", _label]] };
    if (_terminal getVariable ["MWF_isUnderAttack", false]) exitWith { [false, format ["%1 garage unavailable: FOB under attack.", _label]] };

    [true, format ["%1 garage ready.", _label]]
};

private _refreshSummary = {
    params ["_baseKey"];
    private _storage = call _getStorage;
    private _storageIndex = [_storage, _baseKey] call _findStorageIndex;
    private _records = if (_storageIndex >= 0) then { + ((_storage # _storageIndex) param [1, [], [[]]]) } else { [] };
    private _summary = [];
    {
        private _className = _x param [0, "", [""]];
        private _displayName = [_className] call _getVehicleDisplayName;
        private _kindText = _x param [6, "Stored", [""]];
        _summary pushBack [_displayName, _className, _kindText];
    } forEach _records;

    private _registry = +(missionNamespace getVariable ["MWF_GarageRegistry", []]);
    private _newRegistry = [];
    {
        private _garageObj = _x param [0, objNull];
        private _garageKey = _x param [1, "", [""]];
        private _baseLabel = _x param [2, "Garage", [""]];
        private _baseType = _x param [3, "MOB", [""]];
        if (!isNull _garageObj) then {
            if (_garageKey isEqualTo _baseKey) then {
                _garageObj setVariable ["MWF_Garage_InventorySummary", + _summary, true];
                _garageObj setVariable ["MWF_Garage_InventoryCount", count _summary, true];
                _garageObj setVariable ["MWF_Garage_BaseLabel", _baseLabel, true];
                _garageObj setVariable ["MWF_Garage_BaseType", _baseType, true];
                _garageObj setVariable ["MWF_Garage_BaseKey", _garageKey, true];
            };
            _newRegistry pushBack [_garageObj, _garageKey, _baseLabel, _baseType];
        };
    } forEach _registry;
    missionNamespace setVariable ["MWF_GarageRegistry", _newRegistry, true];
};

private _resolveBaseForGarage = {
    params ["_garageObj"];
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
    private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "MOB"];
    private _garagePos = getPosATL _garageObj;

    if (!isNull _mainBase && {_garagePos distance2D _mobPos <= 120}) exitWith { [true, "MOB", _mobName, "MOB"] };

    private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _best = [];
    private _bestDist = 1e10;
    {
        private _terminal = _x param [1, objNull];
        private _name = _x param [2, "FOB", [""]];
        if (!isNull _terminal) then {
            private _dist = _garagePos distance2D _terminal;
            if (_dist <= 120 && {_dist < _bestDist}) then {
                _best = [true, "FOB", _name, format ["FOB:%1", _name]];
                _bestDist = _dist;
            };
        };
    } forEach _registry;

    if (_best isEqualTo []) then { [false, "", "", ""] } else { _best }
};

private _findEligibleNearbyVehicle = {
    params ["_garageObj"];
    private _near = nearestObjects [getPosATL _garageObj, ["LandVehicle", "Air"], 5, true];
    private _eligible = _near select {
        private _veh = _x;
        !isNull _veh &&
        {alive _veh} &&
        {!(_veh getVariable ["MWF_isVirtualGarage", false])} &&
        {!(_veh isKindOf "StaticWeapon")} &&
        {!(_veh isKindOf "Ship")}
    };
    if (_eligible isEqualTo []) exitWith { objNull };
    _eligible # 0
};

private _getBluforRefund = {
    params ["_className"];
    private _catalog = [] call MWF_fnc_getVehicleCatalog;
    private _price = -1;
    {
        if ((_x param [0, ""]) != "__META__") then {
            private _entries = _x param [1, [], [[]]];
            private _match = _entries findIf { (_x param [0, "", [""]]) isEqualTo _className };
            if (_match >= 0) exitWith {
                _price = ((_entries # _match) param [1, -1, [0]]);
            };
        };
    } forEach _catalog;
    if (_price < 0) exitWith { -1 };
    floor (_price * 0.5)
};

private _getFixedScrapReward = {
    params ["_veh"];
    if (_veh isKindOf "Air") exitWith { 75 };

    private _cfg = configFile >> "CfgVehicles" >> typeOf _veh;
    private _transportSeats = if (isClass _cfg) then { getNumber (_cfg >> "transportSoldier") } else { 0 };
    private _armored =
        (_veh isKindOf "Tank") ||
        (_veh isKindOf "Wheeled_APC_F") ||
        (_veh isKindOf "APC_Tracked_01_base_F") ||
        (_veh isKindOf "APC_Tracked_02_base_F") ||
        (_veh isKindOf "APC_Tracked_03_base_F") ||
        (_veh isKindOf "AFV_Wheeled_01_base_F") ||
        (_veh isKindOf "AFV_Wheeled_02_base_F") ||
        (_transportSeats > 0 && {_veh isKindOf "LandVehicle" && !(_veh isKindOf "Car")});

    if (_armored) exitWith { 50 };
    25
};

switch (_modeUpper) do {
    case "REGISTER_BUILD": {
        private _resolved = [_garage] call _resolveBaseForGarage;
        if !(_resolved param [0, false]) exitWith {
            deleteVehicle _garage;
            false
        };

        _resolved params ["_ok", "_baseType", "_baseLabel", "_baseKey"];
        _garage allowDamage false;
        _garage setVariable ["MWF_isVirtualGarage", true, true];
        _garage setVariable ["MWF_Garage_BaseType", _baseType, true];
        _garage setVariable ["MWF_Garage_BaseLabel", _baseLabel, true];
        _garage setVariable ["MWF_Garage_BaseKey", _baseKey, true];

        private _registry = +(missionNamespace getVariable ["MWF_GarageRegistry", []]);
        _registry = _registry select { (_x param [0, objNull]) != _garage && {!isNull (_x param [0, objNull])} };
        _registry pushBack [_garage, _baseKey, _baseLabel, _baseType];
        missionNamespace setVariable ["MWF_GarageRegistry", _registry, true];

        [_garage] remoteExec ["MWF_fnc_setupGarageInteractions", 0, true];
        [_baseKey] call _refreshSummary;
        [format ["Virtual Garage online at %1.", _baseLabel]] remoteExec ["systemChat", 0];
        call _requestSave;
        true
    };

    case "STORE": {
        if (isNull _caller || {!alive _caller}) exitWith { false };
        if (vehicle _caller != _caller) exitWith { ["Exit the vehicle before using the garage."] remoteExec ["systemChat", owner _caller]; false };
        if ((_caller distance _garage) > 5) exitWith { ["Move closer to the garage object."] remoteExec ["systemChat", owner _caller]; false };

        private _baseStatus = [_garage] call _getBaseStatus;
        if !(_baseStatus param [0, false]) exitWith { [(_baseStatus param [1, "Garage unavailable."])] remoteExec ["systemChat", owner _caller]; false };

        private _veh = [_garage] call _findEligibleNearbyVehicle;
        if (isNull _veh) exitWith { ["No supported vehicle parked inside the 5m garage zone."] remoteExec ["systemChat", owner _caller]; false };
        if (isEngineOn _veh) exitWith { ["Turn the vehicle engine off before storing it."] remoteExec ["systemChat", owner _caller]; false };
        if ((speed _veh) > 3) exitWith { ["Vehicle must be stationary before storage."] remoteExec ["systemChat", owner _caller]; false };
        if (({ alive _x } count crew _veh) > 0) exitWith { ["Vehicle must be empty before storage."] remoteExec ["systemChat", owner _caller]; false };

        private _baseKey = _garage getVariable ["MWF_Garage_BaseKey", "MOB"];
        private _storage = call _getStorage;
        private _storageIndex = [_storage, _baseKey] call _findStorageIndex;
        private _records = if (_storageIndex >= 0) then { + ((_storage # _storageIndex) param [1, [], [[]]]) } else { [] };

        private _record = [
            typeOf _veh,
            fuel _veh,
            damage _veh,
            + (getObjectTextures _veh),
            _veh getVariable ["MWF_isBought", false],
            _veh getVariable ["MWF_isMobileRespawn", false],
            if (_veh isKindOf "Air") then { "Air asset" } else { if (_veh isKindOf "Tank") then { "Armored asset" } else { "Ground asset" } }
        ];

        deleteVehicle _veh;
        _records pushBack _record;

        if (_storageIndex >= 0) then {
            _storage set [_storageIndex, [_baseKey, _records]];
        } else {
            _storage pushBack [_baseKey, _records];
        };

        [_storage] call _setStorage;
        [_baseKey] call _refreshSummary;
        call _requestSave;

        [["GARAGE", format ["Stored %1 at %2.", [(_record # 0)] call _getVehicleDisplayName, _garage getVariable ["MWF_Garage_BaseLabel", "Garage"]]], "success"] remoteExec ["MWF_fnc_showNotification", owner _caller];
        true
    };

    case "RETRIEVE": {
        if (isNull _caller || {!alive _caller}) exitWith { false };
        if (vehicle _caller != _caller) exitWith { ["Exit the vehicle before using the garage."] remoteExec ["systemChat", owner _caller]; false };
        if ((_caller distance _garage) > 5) exitWith { ["Move closer to the garage object."] remoteExec ["systemChat", owner _caller]; false };

        private _baseStatus = [_garage] call _getBaseStatus;
        if !(_baseStatus param [0, false]) exitWith { [(_baseStatus param [1, "Garage unavailable."])] remoteExec ["systemChat", owner _caller]; false };

        private _baseKey = _garage getVariable ["MWF_Garage_BaseKey", "MOB"];
        private _storage = call _getStorage;
        private _storageIndex = [_storage, _baseKey] call _findStorageIndex;
        if (_storageIndex < 0) exitWith { ["Garage inventory is empty."] remoteExec ["systemChat", owner _caller]; false };

        private _records = + ((_storage # _storageIndex) param [1, [], [[]]]);
        if (_records isEqualTo []) exitWith { ["Garage inventory is empty."] remoteExec ["systemChat", owner _caller]; false };

        private _selected = _extra;
        if !(_selected isEqualType 0) then { _selected = 0; };
        _selected = (_selected max 0) min ((count _records) - 1);

        private _record = _records # _selected;
        _record params ["_className", "_fuel", "_damage", "_textures", "_isBought", "_isMRU"];

        private _garagePos = getPosATL _garage;
        private _spawnPos = [_garagePos, 8, 20, 6, 0, 0.4, 0] call BIS_fnc_findSafePos;
        if (_spawnPos isEqualTo [] || {_spawnPos isEqualTo [0,0,0]}) then {
            _spawnPos = _garagePos vectorAdd [6, 0, 0];
        };

        private _veh = createVehicle [_className, _spawnPos, [], 0, "CAN_COLLIDE"];
        if (isNull _veh) exitWith { [format ["Failed to retrieve %1.", [_className] call _getVehicleDisplayName]] remoteExec ["systemChat", owner _caller]; false };

        _veh setDir (getDir _garage);
        _veh setPosATL _spawnPos;
        _veh setFuel (_fuel max 0 min 1);
        _veh setDamage (_damage max 0 min 1);
        {
            _veh setObjectTextureGlobal [_forEachIndex, _x];
        } forEach _textures;
        if (_isBought) then { _veh setVariable ["MWF_isBought", true, true]; };
        if (_isMRU) then {
            _veh setVariable ["MWF_isMobileRespawn", true, true];
            [_veh] call MWF_fnc_initMobileRespawn;
        };

        _records deleteAt _selected;
        _storage set [_storageIndex, [_baseKey, _records]];
        [_storage] call _setStorage;
        [_baseKey] call _refreshSummary;
        call _requestSave;

        [["GARAGE", format ["Retrieved %1 from %2.", [_className] call _getVehicleDisplayName, _garage getVariable ["MWF_Garage_BaseLabel", "Garage"]]], "success"] remoteExec ["MWF_fnc_showNotification", owner _caller];
        true
    };

    case "SCRAP": {
        if (isNull _caller || {!alive _caller}) exitWith { false };
        if (vehicle _caller != _caller) exitWith { ["Exit the vehicle before using the garage."] remoteExec ["systemChat", owner _caller]; false };
        if ((_caller distance _garage) > 5) exitWith { ["Move closer to the garage object."] remoteExec ["systemChat", owner _caller]; false };

        private _baseStatus = [_garage] call _getBaseStatus;
        if !(_baseStatus param [0, false]) exitWith { [(_baseStatus param [1, "Garage unavailable."])] remoteExec ["systemChat", owner _caller]; false };

        private _veh = [_garage] call _findEligibleNearbyVehicle;
        if (isNull _veh) exitWith { ["No supported vehicle parked inside the 5m garage zone."] remoteExec ["systemChat", owner _caller]; false };
        if (isEngineOn _veh) exitWith { ["Turn the vehicle engine off before scrapping it."] remoteExec ["systemChat", owner _caller]; false };
        if ((speed _veh) > 3) exitWith { ["Vehicle must be stationary before scrapping."] remoteExec ["systemChat", owner _caller]; false };
        if (({ alive _x } count crew _veh) > 0) exitWith { ["Vehicle must be empty before scrapping."] remoteExec ["systemChat", owner _caller]; false };

        private _refund = [typeOf _veh] call _getBluforRefund;
        if (_refund < 0) then {
            _refund = [_veh] call _getFixedScrapReward;
        };

        deleteVehicle _veh;
        [_refund, "SUPPLIES"] call MWF_fnc_addResource;
        call _requestSave;

        [["GARAGE", format ["Scrapped vehicle for %1 Supplies.", _refund]], "success"] remoteExec ["MWF_fnc_showNotification", owner _caller];
        true
    };

    default { false };
};
