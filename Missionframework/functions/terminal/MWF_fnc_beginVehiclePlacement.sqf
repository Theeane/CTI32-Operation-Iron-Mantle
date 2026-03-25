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
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (_className isEqualTo "") exitWith { false };

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];

private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
private _hasRequiredUpgradeStructure = {
    params [["_requiredUnlockLocal", "", [""]]];
    private _structureClass = switch (toUpper _requiredUnlockLocal) do {
        case "HELI": { missionNamespace getVariable ["MWF_Heli_Tower_Class", ""] };
        case "JETS": { missionNamespace getVariable ["MWF_Jet_Control_Class", ""] };
        default { "" };
    };
    if (_structureClass isEqualTo "") exitWith { false };
    ({ typeOf _x isEqualTo _structureClass } count (nearestObjects [_mobPos, [_structureClass], 120])) > 0
};

private _unlockSatisfied = switch (toUpper _requiredUnlock) do {
    case "HELI": { ["HELI"] call MWF_fnc_hasProgressionAccess };
    case "JETS": { ["JETS"] call MWF_fnc_hasProgressionAccess };
    case "ARMOR": { ["ARMOR"] call MWF_fnc_hasProgressionAccess };
    default { true };
};
if !_unlockSatisfied exitWith {
    systemChat format ["Vehicle locked: %1 unlock required.", if (_requiredUnlock isEqualTo "") then {"category"} else {_requiredUnlock}];
    false
};

if (_isTier5 && {!( ["TIER5"] call MWF_fnc_hasProgressionAccess )}) exitWith {
    systemChat "Vehicle locked: complete Apex Predator first.";
    false
};

if ((toUpper _requiredUnlock) in ["HELI", "JETS"] && {!([_requiredUnlock] call _hasRequiredUpgradeStructure)}) exitWith {
    systemChat format ["Vehicle locked: build the %1 structure at the MOB first.", if ((toUpper _requiredUnlock) isEqualTo "HELI") then {"Helicopter Uplink"} else {"Aircraft Control"}];
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
missionNamespace setVariable ["MWF_SensitiveInteraction_Type", "VEHICLE_PLACEMENT"];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", _ghost];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", _className];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", _cost];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", _minTier];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", _displayName];
missionNamespace setVariable ["MWF_VehiclePlacement_RequiredUnlock", _requiredUnlock];
missionNamespace setVariable ["MWF_VehiclePlacement_IsTier5", _isTier5];
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
