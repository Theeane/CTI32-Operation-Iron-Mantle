/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_vehicleMenuPurchase
    Project: Military War Framework

    Description:
    Direct KP-style ghost preview flow for vehicle purchases.
    This bypasses the fragile UI -> helper -> helper handoff and runs the
    local preview session inline, then remoteExecs the final server spawn only
    when the player confirms a valid placement.

    Params (optional):
    [entryArray, terminalObject]
*/

if (!hasInterface) exitWith { false };

params [
    ["_entryOverride", [], [[]]],
    ["_terminalOverride", objNull, [objNull]]
];

if (vehicle player != player) exitWith {
    hint "Exit your vehicle before building.";
    false
};

private _entry = +_entryOverride;
private _terminal = _terminalOverride;

if (_entry isEqualTo []) then {
    private _display = findDisplay 9050;
    if (isNull _display) then {
        _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
    };

    private _entries = missionNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", uiNamespace getVariable ["MWF_VehicleMenu_CurrentEntries", []]];
    private _selectedIndex = -1;

    if (!isNull _display) then {
        private _listCtrl = _display displayCtrl 9052;
        if (!isNull _listCtrl) then {
            _selectedIndex = lbCurSel _listCtrl;
        } else {
            _selectedIndex = uiNamespace getVariable ["MWF_VehicleMenu_SelectedIndex", -1];
        };
    } else {
        _selectedIndex = uiNamespace getVariable ["MWF_VehicleMenu_SelectedIndex", -1];
    };

    if (_selectedIndex < 0 || {_selectedIndex >= count _entries}) exitWith {
        systemChat "Vehicle Menu: select a vehicle first.";
        false
    };

    _entry = +(_entries select _selectedIndex);
    if (isNull _terminal) then {
        _terminal = missionNamespace getVariable ["MWF_VehicleMenu_LastTerminal", uiNamespace getVariable ["MWF_DataHub_ContextTerminal", objNull]];
    };
};

if (_entry isEqualTo []) exitWith { false };

_entry params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_displayName", "", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]],
    ["_iconPath", "", [""]],
    ["_subText", "", [""]],
    ["_state", createHashMap, [createHashMap]]
];

if (_className isEqualTo "") exitWith { false };

private _isLocked = _state getOrDefault ["isLocked", false];
private _canAfford = _state getOrDefault ["canAfford", true];
private _reason = _state getOrDefault ["reason", "Vehicle unavailable."];
if (_isLocked || {!_canAfford}) exitWith {
    systemChat _reason;
    [["VEHICLE MENU", _reason], if (_isLocked) then {"warning"} else {"info"}] call MWF_fnc_showNotification;
    false
};

closeDialog 0;
["CLOSE"] call MWF_fnc_dataHub;
uiSleep 0.05;

[] call MWF_fnc_cleanupVehiclePlacement;

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
_profile params [
    ["_vehicleType", "LAND", [""]],
    ["_surfaceRule", "LAND", [""]],
    ["_previewDistance", 8, [0]],
    ["_previewHeight", 0.2, [0]],
    ["_diameter", 4, [0]],
    ["_safetyRadius", 3, [0]]
];

private _ghostSpot = (markerPos "respawn_west") vectorAdd [0, 0, 1000];
private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith {
    systemChat format ["Ghost preview failed for %1.", _className];
    false
};

_ghost allowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulation false;
_ghost disableCollisionWith player;
if !(isNull _terminal) then { _ghost disableCollisionWith _terminal; };

private _paintGhost = {
    params ["_obj", "_valid"];
    if (isNull _obj) exitWith {};
    private _tex = if (_valid) then {
        '#(rgb,8,8,3)color(0,1,0,0.8)'
    } else {
        '#(rgb,8,8,3)color(1,0,0,0.55)'
    };
    _obj setAlpha (if (_valid) then {0.7} else {0.5});
    for '_i' from 0 to 12 do {
        _obj setObjectTexture [_i, _tex];
    };
};

private _rotation = 0;
private _heightOffset = 0;
private _lastPosASL = getPosASL player;
private _lastDir = getDir player;
private _lastReason = "Placement invalid.";
private _lastValid = false;

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", _profile];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _lastReason];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _lastPosASL];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _lastDir];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", _rotation];
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", _heightOffset];
missionNamespace setVariable ["MWF_GhostPlacement_Active", true];
missionNamespace setVariable ["MWF_GhostPlacement_Ghost", _ghost];
player forceWalk true;

private _idCancel = player addAction ["<t color='#B0FF00'>Cancel Build</t>", { missionNamespace setVariable ["MWF_VehiclePlacement_Command", 3]; }, nil, -725, false, true, "", "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _idRotate = player addAction ["<t color='#B0FF00'>Rotate</t>", { missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", (missionNamespace getVariable ['MWF_VehiclePlacement_Rotation', 0]) + 45]; }, nil, -750, false, false, "", "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _idRaise = player addAction ["<t color='#B0FF00'>Raise</t>", { missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (missionNamespace getVariable ['MWF_VehiclePlacement_HeightOffset', 0]) + 0.2]; }, nil, -765, false, false, "", "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _idLower = player addAction ["<t color='#B0FF00'>Lower</t>", { missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (missionNamespace getVariable ['MWF_VehiclePlacement_HeightOffset', 0]) - 0.2]; }, nil, -766, false, false, "", "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _idPlace = player addAction ["<t color='#B0FF00'>Build</t>", { missionNamespace setVariable ["MWF_VehiclePlacement_Command", 2]; }, nil, -775, false, true, "", "(missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]) && (missionNamespace getVariable ['MWF_VehiclePlacement_IsValid', false])"];

missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _idCancel];
missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _idRotate];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _idRaise];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _idLower];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _idPlace];
missionNamespace setVariable ["MWF_VehiclePlacement_Command", 1];

[_ghost, true] call _paintGhost;
[["VEHICLE PLACEMENT", format ["Ghost build active for %1.", _displayName]], "info"] call MWF_fnc_showNotification;

private _dist = 0.6 * (_diameter max 2);
if (_dist < (_previewDistance max 3.5)) then { _dist = _previewDistance max 3.5; };
_dist = _dist + 1;

while { (missionNamespace getVariable ["MWF_VehiclePlacement_Command", 1]) == 1 && alive player } do {
    _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0];
    _heightOffset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0];

    private _trueDir = 90 - getDir player;
    private _basePos = [
        ((getPos player) select 0) + (_dist * (cos _trueDir)),
        ((getPos player) select 1) + (_dist * (sin _trueDir)),
        0
    ];

    if (_vehicleType isEqualTo "AIR") then {
        _basePos set [2, (getPosATL player) select 2];
    };

    private _actualDir = (getDir player) + _rotation;
    while {_actualDir > 360} do { _actualDir = _actualDir - 360; };
    while {_actualDir < 0} do { _actualDir = _actualDir + 360; };

    private _finalPosATL = [
        _basePos select 0,
        _basePos select 1,
        ((_basePos select 2) + _previewHeight + _heightOffset)
    ];

    _ghost setDir _actualDir;
    _ghost setPosATL _finalPosATL;

    private _validation = [
        "VEHICLE",
        _className,
        ATLToASL _finalPosATL,
        _actualDir,
        createHashMapFromArray [
            ["profile", _profile],
            ["ghost", _ghost],
            ["terminal", _terminal]
        ]
    ] call MWF_fnc_validateGhostPlacement;

    _lastValid = _validation param [0, false];
    _lastReason = _validation param [1, "Placement invalid."];
    _lastPosASL = ATLToASL _finalPosATL;
    _lastDir = _actualDir;

    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _lastValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _lastReason];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", _lastPosASL];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", _lastDir];

    [_ghost, _lastValid] call _paintGhost;
    uiSleep 0.02;
};

private _command = missionNamespace getVariable ["MWF_VehiclePlacement_Command", 3];
[] call MWF_fnc_cleanupVehiclePlacement;
missionNamespace setVariable ["MWF_GhostPlacement_Active", false];
missionNamespace setVariable ["MWF_GhostPlacement_Ghost", objNull];
missionNamespace setVariable ["MWF_VehiclePlacement_Command", nil];
player forceWalk false;

if (_command == 2) then {
    if (_lastValid) then {
        [
            _className,
            _cost,
            _minTier,
            _lastPosASL,
            _lastDir,
            (_profile param [1, "LAND"]),
            _requiredUnlock,
            _isTier5
        ] remoteExec ["MWF_fnc_confirmVehiclePlacement", 2];
        systemChat "Vehicle build request sent to server.";
        true
    } else {
        systemChat _lastReason;
        false
    };
} else {
    hint "Build cancelled.";
    false
};
