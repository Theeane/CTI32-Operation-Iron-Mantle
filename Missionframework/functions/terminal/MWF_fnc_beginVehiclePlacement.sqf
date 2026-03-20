/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_beginVehiclePlacement
    Project: Military War Framework

    Description:
    Starts local-only ghost placement for a preset-driven vehicle purchase.
    The real vehicle is only created after confirmation on the server.
*/

if (!hasInterface) exitWith { false };

params [
    ["_entry", [], [[]]],
    ["_terminal", objNull, [objNull]]
];

if ((count _entry) < 4) exitWith { false };

[] call MWF_fnc_cleanupVehiclePlacement;

_entry params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_displayName", "", [""]],
    ["_category", "", [""]],
    ["_lockReason", "", [""]]
];

if (_className isEqualTo "") exitWith { false };

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_PlayerBaseTier", missionNamespace getVariable ["MWF_CurrentTier", 1]];

if (_lockReason isNotEqualTo "") exitWith {
    systemChat _lockReason;
    [
        ["VEHICLE LOCKED", _lockReason],
        "warning"
    ] call MWF_fnc_showNotification;
    false
};

if (_supplies < _cost) exitWith {
    [format ["Insufficient Supplies: %1 needed.", _cost]] call BIS_fnc_showSubtitle;
    false
};

if (_currentTier < _minTier) exitWith {
    systemChat format ["Vehicle locked: Base Tier %1 required.", _minTier];
    false
};

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
private _ghost = _className createVehicleLocal [0, 0, 0];

_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setVehicleLock "LOCKED";
_ghost setAlpha 0.45;
_ghost disableCollisionWith player;

missionNamespace setVariable ["MWF_VehiclePlacement_Active", true];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", _profile];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", getDir player];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement not yet validated."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];

private _confirmAction = player addAction [
    format ["<t color='#00FF66'>Confirm Vehicle Build: %1 (%2 Supplies)</t>", _displayName, _cost],
    { [] call MWF_fnc_confirmVehiclePlacement; },
    nil,
    100,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

private _cancelAction = player addAction [
    "<t color='#FF5555'>Cancel Vehicle Build</t>",
    { [] call MWF_fnc_cancelVehiclePlacement; },
    nil,
    99,
    false,
    true,
    "",
    "missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"
];

missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];

[
    ["VEHICLE PLACEMENT", format ["Ghost build active for %1. Confirm or cancel from the action menu.", _displayName]],
    "info"
] call MWF_fnc_showNotification;

[] spawn MWF_fnc_updateVehicleGhost;
true
