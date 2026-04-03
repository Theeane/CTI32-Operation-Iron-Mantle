/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_startGhostPlacement
    Project: Military War Framework

    Description:
    Unified KP-inspired ghost placement session for both vehicle placement and
    physical base-upgrade placement. The preview always stays alive; validation
    only changes state and blocks Build.
*/

if (!hasInterface) exitWith { false };
if (vehicle player != player) exitWith {
    hint "Exit your vehicle before building.";
    false
};

params [
    ["_mode", "vehicle", [""]],
    ["_payload", [], [[]]],
    ["_sourceTerminal", objNull, [objNull]]
];

private _modeUpper = toUpper _mode;
if !(_modeUpper in ["VEHICLE", "BUILD"]) exitWith { false };

// Cleanup previous session if one exists.
private _cleanupIds = missionNamespace getVariable ["MWF_GhostPlacement_ActionIds", []];
{
    if (_x >= 0) then { player removeAction _x; };
} forEach _cleanupIds;
missionNamespace setVariable ["MWF_GhostPlacement_ActionIds", []];
missionNamespace setVariable ["MWF_GhostPlacement_Active", false];
player forceWalk false;
private _oldGhost = missionNamespace getVariable ["MWF_GhostPlacement_Ghost", objNull];
if (!isNull _oldGhost) then { deleteVehicle _oldGhost; };

private _className = "";
private _displayName = "";
private _cost = 0;
private _minTier = 1;
private _requiredUnlock = "";
private _isTier5 = false;
private _profile = [];
private _previewDistance = 8;
private _previewHeight = 0;
private _rotation = 0;
private _heightOffset = 0;

if (_modeUpper isEqualTo "VEHICLE") then {
    if ((count _payload) < 4) exitWith { false };
    _payload params [
        ["_classNameLocal", "", [""]],
        ["_costLocal", 0, [0]],
        ["_minTierLocal", 1, [0]],
        ["_displayNameLocal", "", [""]],
        ["_requiredUnlockLocal", "", [""]],
        ["_isTier5Local", false, [false]]
    ];
    _className = _classNameLocal;
    _cost = _costLocal;
    _minTier = _minTierLocal;
    _displayName = _displayNameLocal;
    _requiredUnlock = _requiredUnlockLocal;
    _isTier5 = _isTier5Local;
    _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
    _previewDistance = _profile param [2, 8];
    _previewHeight = _profile param [3, 0];
} else {
    if ((count _payload) < 2) exitWith { false };
    _payload params [
        ["_classNameLocal", "", [""]],
        ["_costLocal", 0, [0]]
    ];
    _className = _classNameLocal;
    _cost = _costLocal;
    _displayName = getText (configFile >> "CfgVehicles" >> _className >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
    private _diameter = sizeOf _className;
    if (_diameter <= 0) then { _diameter = 6; };
    _previewDistance = ((_diameter * 0.65) max 6) min 14;
    _previewHeight = 0;
};

if (_className isEqualTo "") exitWith { false };
private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { false };

private _ghostSpot = (markerPos "respawn_west") vectorAdd [0,0,1000];
private _ghost = _className createVehicleLocal _ghostSpot;
if (isNull _ghost) exitWith { false };
_ghost setAllowDamage false;
_ghost setVehicleLock "LOCKED";
_ghost enableSimulation false;
_ghost disableCollisionWith player;

private _paintGhost = {
    params ["_ghostObj", "_valid"];
    if (isNull _ghostObj) exitWith {};
    private _color = if (_valid) then {
        "#(rgb,8,8,3)color(0,1,0,0.60)"
    } else {
        "#(rgb,8,8,3)color(1,0,0,0.45)"
    };
    _ghostObj setAlpha (if (_valid) then {0.65} else {0.45});
    for "_i" from 0 to 12 do {
        _ghostObj setObjectTexture [_i, _color];
    };
};
[_ghost, true] call _paintGhost;

missionNamespace setVariable ["MWF_GhostPlacement_Active", true];
missionNamespace setVariable ["MWF_GhostPlacement_Mode", _modeUpper];
missionNamespace setVariable ["MWF_GhostPlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_GhostPlacement_Class", _className];
missionNamespace setVariable ["MWF_GhostPlacement_DisplayName", _displayName];
missionNamespace setVariable ["MWF_GhostPlacement_Cost", _cost];
missionNamespace setVariable ["MWF_GhostPlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_GhostPlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_GhostPlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_GhostPlacement_Profile", _profile];
missionNamespace setVariable ["MWF_GhostPlacement_Rotation", _rotation];
missionNamespace setVariable ["MWF_GhostPlacement_HeightOffset", _heightOffset];
missionNamespace setVariable ["MWF_GhostPlacement_IsValid", false];
missionNamespace setVariable ["MWF_GhostPlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_GhostPlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_GhostPlacement_LastDir", getDir player];
missionNamespace setVariable ["MWF_GhostPlacement_SourceTerminal", _sourceTerminal];
missionNamespace setVariable ["MWF_GhostPlacement_Confirmed", false];
missionNamespace setVariable ["MWF_GhostPlacement_Cancelled", false];

// Legacy mirrors kept alive so older interruption / cleanup paths cannot silently kill the new flow.
missionNamespace setVariable ["MWF_VehiclePlacement_Active", (_modeUpper isEqualTo "VEHICLE")];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", if (_modeUpper isEqualTo "VEHICLE") then {_ghost} else {objNull}];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", _profile];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];

player forceWalk true;

private _rotateAction = player addAction [
    "Rotate (45°)",
    { missionNamespace setVariable ["MWF_GhostPlacement_Rotation", (missionNamespace getVariable ["MWF_GhostPlacement_Rotation", 0]) + 45]; },
    nil, 98, false, true, "",
    "missionNamespace getVariable ['MWF_GhostPlacement_Active', false]"
];
private _raiseAction = player addAction [
    "Raise",
    { missionNamespace setVariable ["MWF_GhostPlacement_HeightOffset", (missionNamespace getVariable ['MWF_GhostPlacement_HeightOffset', 0]) + 0.2]; },
    nil, 97, false, true, "",
    "missionNamespace getVariable ['MWF_GhostPlacement_Active', false]"
];
private _lowerAction = player addAction [
    "Lower",
    { missionNamespace setVariable ["MWF_GhostPlacement_HeightOffset", (missionNamespace getVariable ['MWF_GhostPlacement_HeightOffset', 0]) - 0.2]; },
    nil, 96, false, true, "",
    "missionNamespace getVariable ['MWF_GhostPlacement_Active', false]"
];
private _buildAction = player addAction [
    "Build",
    { missionNamespace setVariable ["MWF_GhostPlacement_Confirmed", true]; },
    nil, 100, false, true, "",
    "missionNamespace getVariable ['MWF_GhostPlacement_Active', false]"
];
private _cancelAction = player addAction [
    "Cancel Build",
    { missionNamespace setVariable ["MWF_GhostPlacement_Cancelled", true]; },
    nil, 99, false, true, "",
    "missionNamespace getVariable ['MWF_GhostPlacement_Active', false]"
];
missionNamespace setVariable ["MWF_GhostPlacement_ActionIds", [_rotateAction, _raiseAction, _lowerAction, _buildAction, _cancelAction]];

[[if (_modeUpper isEqualTo "VEHICLE") then {"VEHICLE PLACEMENT"} else {"BUILD PLACEMENT"}, format ["Ghost build active for %1.", _displayName]], "info"] call MWF_fnc_showNotification;

while {
    missionNamespace getVariable ["MWF_GhostPlacement_Active", false] &&
    !(missionNamespace getVariable ["MWF_GhostPlacement_Confirmed", false]) &&
    !(missionNamespace getVariable ["MWF_GhostPlacement_Cancelled", false]) &&
    alive player
} do {
    private _rotationNow = missionNamespace getVariable ["MWF_GhostPlacement_Rotation", 0];
    private _heightOffsetNow = missionNamespace getVariable ["MWF_GhostPlacement_HeightOffset", 0];
    private _ghostNow = missionNamespace getVariable ["MWF_GhostPlacement_Ghost", objNull];
    if (isNull _ghostNow) exitWith { missionNamespace setVariable ["MWF_GhostPlacement_Cancelled", true]; };

    private _placementDistance = _previewDistance max ((((sizeOf _className) max 2) * 0.6) + 1);
    private _playerDir = getDir player;
    private _targetPos = [
        ((getPosATL player) select 0) + (_placementDistance * sin _playerDir),
        ((getPosATL player) select 1) + (_placementDistance * cos _playerDir),
        (getPosATL player) select 2
    ];
    private _finalPosATL = +_targetPos;
    _finalPosATL set [2, (_finalPosATL select 2) + _previewHeight + _heightOffsetNow];

    _ghostNow setPosATL _finalPosATL;
    _ghostNow setDir (_playerDir + _rotationNow);

    private _context = createHashMapFromArray [
        ["profile", _profile],
        ["ghost", _ghostNow],
        ["terminal", _sourceTerminal]
    ];
    private _validation = [_modeUpper, _className, ATLToASL _finalPosATL, getDir _ghostNow, _context] call MWF_fnc_validateGhostPlacement;
    private _isValid = _validation param [0, false];
    private _reason = _validation param [1, "Placement invalid."];

    missionNamespace setVariable ["MWF_GhostPlacement_LastPosASL", ATLToASL _finalPosATL];
    missionNamespace setVariable ["MWF_GhostPlacement_LastDir", getDir _ghostNow];
    missionNamespace setVariable ["MWF_GhostPlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_GhostPlacement_LastReason", _reason];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", ATLToASL _finalPosATL];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir _ghostNow];
    missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", _isValid];
    missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", _reason];
    [_ghostNow, _isValid] call _paintGhost;

    uiSleep 0.02;
};

private _confirmed = missionNamespace getVariable ["MWF_GhostPlacement_Confirmed", false];
private _cancelled = missionNamespace getVariable ["MWF_GhostPlacement_Cancelled", false];
private _isValid = missionNamespace getVariable ["MWF_GhostPlacement_IsValid", false];
private _lastReason = missionNamespace getVariable ["MWF_GhostPlacement_LastReason", "Placement invalid."];
private _lastPosASL = missionNamespace getVariable ["MWF_GhostPlacement_LastPosASL", getPosASL player];
private _lastDir = missionNamespace getVariable ["MWF_GhostPlacement_LastDir", getDir player];
private _sourceTerminalLocal = missionNamespace getVariable ["MWF_GhostPlacement_SourceTerminal", objNull];

// Cleanup shared state.
private _cleanupIdsNow = missionNamespace getVariable ["MWF_GhostPlacement_ActionIds", []];
{ if (_x >= 0) then { player removeAction _x; }; } forEach _cleanupIdsNow;
missionNamespace setVariable ["MWF_GhostPlacement_ActionIds", []];
player forceWalk false;
private _ghostEnd = missionNamespace getVariable ["MWF_GhostPlacement_Ghost", objNull];
if (!isNull _ghostEnd) then { deleteVehicle _ghostEnd; };
missionNamespace setVariable ["MWF_GhostPlacement_Active", false];
missionNamespace setVariable ["MWF_VehiclePlacement_Active", false];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", objNull];

if (_confirmed && _isValid) then {
    if (_modeUpper isEqualTo "VEHICLE") then {
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
    } else {
        [_className, ASLToATL _lastPosASL, _lastDir, _cost, player] remoteExec ["MWF_fnc_finalizeBuild", 2];
        systemChat "Build request sent to server.";
    };
} else {
    if (_confirmed && !_isValid) then {
        systemChat _lastReason;
    } else {
        hint "Build cancelled.";
    };
};

// Nuke leftover state to avoid stale sessions.
{
    missionNamespace setVariable [_x, nil];
} forEach [
    "MWF_GhostPlacement_Mode",
    "MWF_GhostPlacement_Ghost",
    "MWF_GhostPlacement_Class",
    "MWF_GhostPlacement_DisplayName",
    "MWF_GhostPlacement_Cost",
    "MWF_GhostPlacement_MinTier",
    "MWF_GhostPlacement_RequiredUnlock",
    "MWF_GhostPlacement_IsTier5",
    "MWF_GhostPlacement_Profile",
    "MWF_GhostPlacement_Rotation",
    "MWF_GhostPlacement_HeightOffset",
    "MWF_GhostPlacement_IsValid",
    "MWF_GhostPlacement_LastReason",
    "MWF_GhostPlacement_LastPosASL",
    "MWF_GhostPlacement_LastDir",
    "MWF_GhostPlacement_SourceTerminal",
    "MWF_GhostPlacement_Confirmed",
    "MWF_GhostPlacement_Cancelled",
    "MWF_VehiclePlacement_Class",
    "MWF_VehiclePlacement_Cost",
    "MWF_VehiclePlacement_MinTier",
    "MWF_VehiclePlacement_Profile",
    "MWF_VehiclePlacement_RequiredUnlock",
    "MWF_VehiclePlacement_IsTier5",
    "MWF_VehiclePlacement_IsValid",
    "MWF_VehiclePlacement_LastReason",
    "MWF_VehiclePlacement_LastPosASL",
    "MWF_VehiclePlacement_LastDir"
];

true
