/*
    Author: Theane / ChatGPT
    Function: MWF_fn_handleBuildPlacement
    Project: Military War Framework

    Description:
    Server-side validation and pricing for Zeus base-building placements.
    Re-validates placed/edited objects and only charges once per object.
*/

if (!isServer) exitWith {};

params [
    ["_entity", objNull, [objNull]],
    ["_builder", objNull, [objNull]],
    ["_sessionId", "", [""]],
    ["_eventName", "PLACE", [""]]
];

if (isNull _entity) exitWith {};
if (isNull _builder) exitWith {
    deleteVehicle _entity;
};

private _architectActive = _builder getVariable ["MWF_BaseArchitect_Active", false];
private _activeSession = _builder getVariable ["MWF_BaseArchitect_SessionId", ""];
if !(_architectActive) exitWith {
    deleteVehicle _entity;
    ["Build failed: architect session is no longer active."] remoteExec ["systemChat", owner _builder];
};
if (_activeSession isEqualTo "") exitWith {
    deleteVehicle _entity;
    ["Build failed: architect session is missing server validation state."] remoteExec ["systemChat", owner _builder];
};
if (_sessionId isNotEqualTo "" && {!(_sessionId isEqualTo _activeSession)}) exitWith {
    deleteVehicle _entity;
    ["Build failed: architect session mismatch detected."] remoteExec ["systemChat", owner _builder];
};

private _className = typeOf _entity;
private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
if !(_check # 0) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then { [(_check # 1)] remoteExec ["systemChat", owner _builder]; };
};

private _anchorPos = _builder getVariable ["MWF_BaseArchitect_AnchorPos", []];
private _maxRange = _builder getVariable ["MWF_BaseArchitect_MaxRange", 500];
if (_anchorPos isEqualType [] && {(count _anchorPos) >= 2} && {(_entity distance2D _anchorPos) > _maxRange}) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then { [format ["Build failed: structure placed outside architect range (%1m).", _maxRange]] remoteExec ["systemChat", owner _builder]; };
};

private _cost = [_className] call MWF_fnc_getBuildAssetCost;
private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
private _isHeliUpgrade = (_heliClass isNotEqualTo "") && {_className isEqualTo _heliClass};
private _isJetUpgrade = (_jetClass isNotEqualTo "") && {_className isEqualTo _jetClass};
private _isGarageUpgrade = (_garageClass isNotEqualTo "") && {_className isEqualTo _garageClass};

if (_isHeliUpgrade) exitWith { deleteVehicle _entity; if (!isNull _builder) then { ["Helicopter Uplink must be placed through Base Upgrades ghost placement at the MOB."] remoteExec ["systemChat", owner _builder]; }; };
if (_isJetUpgrade) exitWith { deleteVehicle _entity; if (!isNull _builder) then { ["Aircraft Control must be placed through Base Upgrades ghost placement at the MOB."] remoteExec ["systemChat", owner _builder]; }; };
if (_isGarageUpgrade) exitWith { deleteVehicle _entity; if (!isNull _builder) then { ["Virtual Garage must be placed through Base Upgrades ghost placement at the current MOB or FOB."] remoteExec ["systemChat", owner _builder]; }; };

private _alreadyPaid = _entity getVariable ["MWF_BaseBuild_Paid", false];
if (!_alreadyPaid) then {
    private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    if (_current < _cost) exitWith {
        deleteVehicle _entity;
        if (!isNull _builder) then { [format ["Insufficient supplies to build %1. Required: %2", getText (configFile >> "CfgVehicles" >> _className >> "displayName"), _cost]] remoteExec ["systemChat", owner _builder]; };
    };

    [(_cost * -1), "SUPPLIES"] call MWF_fnc_addResource;
    _entity setVariable ["MWF_BuildCost", _cost, true];
    _entity setVariable ["MWF_BaseBuild_Paid", true, true];

    if (!isNull _builder) then { [format ["Asset deployed: -%1 Supplies", _cost]] remoteExec ["systemChat", owner _builder]; };
};

_entity setVariable ["MWF_isBuiltByPlayer", true, true];
_entity setVariable ["MWF_isPermanent", true, true];
_entity setVariable ["MWF_BaseArchitect_BuilderUID", getPlayerUID _builder, true];
_entity setVariable ["MWF_BaseArchitect_AnchorPos", +_anchorPos, true];
_entity setVariable ["MWF_BaseArchitect_MaxRange", _maxRange, true];

if (_eventName isEqualTo "EDIT") then {
    diag_log format ["[MWF BaseBuild] %1 revalidated after edit for %2.", _className, _builder];
} else {
    diag_log format ["[MWF BaseBuild] %1 validated for %2.", _className, _builder];
};
