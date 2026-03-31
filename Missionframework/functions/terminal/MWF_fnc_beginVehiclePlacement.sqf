/*
    Debug-instrumented vehicle placement startup.
*/

if (!hasInterface) exitWith { false };
params [["_entry", [], [[]]],["_terminal", objNull, [objNull]]];
systemChat "VM DEBUG: begin placement entered";
diag_log format ["[OIM][VehicleMenu] begin placement entry=%1 terminalNull=%2", _entry, isNull _terminal];
if ((count _entry) < 4) exitWith { systemChat "VM DEBUG: invalid vehicle entry"; false };

systemChat "VM DEBUG: cleanup old placement";
[] call MWF_fnc_cleanupVehiclePlacement;

_entry params [["_className", "", [""]],["_cost", 0, [0]],["_minTier", 1, [0]],["_displayName", "", [""]],["_requiredUnlock", "", [""]],["_isTier5", false, [false]]];
if (_className isEqualTo "") exitWith { systemChat "VM DEBUG: empty classname"; false };
systemChat format ["VM DEBUG: class %1", _className];

private _cfg = configFile >> "CfgVehicles" >> _className;
if !(isClass _cfg) exitWith { systemChat format ["VM DEBUG: unknown class %1", _className]; false };
if (_displayName isEqualTo "") then {
    _displayName = getText (_cfg >> "displayName");
    if (_displayName isEqualTo "") then { _displayName = _className; };
};
systemChat format ["VM DEBUG: profile for %1", _displayName];

private _profile = [_className] call MWF_fnc_getVehiclePlacementProfile;
diag_log format ["[OIM][VehicleMenu] placement profile=%1", _profile];
systemChat "VM DEBUG: profile ok";

private _ghost = _className createVehicleLocal [0, 0, 0];
systemChat format ["VM DEBUG: ghost created null=%1", isNull _ghost];
if (isNull _ghost) exitWith { false };

systemChat "VM DEBUG: ghost setup 1";
_ghost setAllowDamage false;
_ghost enableSimulation false;
systemChat "VM DEBUG: ghost setup 2";
_ghost setAlpha 0.55;
_ghost disableCollisionWith player;
systemChat "VM DEBUG: ghost setup done";

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
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", round ((getDir player) / 45) * 45];
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", 0];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", "Placement preview active."];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", getPosASL player];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", getDir player];
systemChat "VM DEBUG: state set";

private _rotateAction = player addAction ["Rotate (45°)",{ private _rotation = missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0]; missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", _rotation + 45]; },nil,103,false,true,"","missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _raiseAction = player addAction ["Raise",{ private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0]; missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (_offset + 0.5) min 5]; },nil,102,false,true,"","missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _lowerAction = player addAction ["Lower",{ private _offset = missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0]; missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (_offset - 0.5) max -2]; },nil,101,false,true,"","missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _confirmAction = player addAction [format ["<t color='#00FF66'>Confirm Placement: %1 (%2 Supplies)</t>", _displayName, _cost],{ [] call MWF_fnc_confirmVehiclePlacement; },nil,100,false,true,"","missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
private _cancelAction = player addAction ["<t color='#FF5555'>Cancel</t>",{ [] call MWF_fnc_cancelVehiclePlacement; },nil,99,false,true,"","missionNamespace getVariable ['MWF_VehiclePlacement_Active', false]"];
missionNamespace setVariable ["MWF_VehiclePlacement_RotateAction", _rotateAction];
missionNamespace setVariable ["MWF_VehiclePlacement_RaiseAction", _raiseAction];
missionNamespace setVariable ["MWF_VehiclePlacement_LowerAction", _lowerAction];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", _confirmAction];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", _cancelAction];
systemChat "VM DEBUG: actions added";

[] spawn MWF_fnc_updateVehicleGhost;
systemChat "VM DEBUG: update loop started";
true
