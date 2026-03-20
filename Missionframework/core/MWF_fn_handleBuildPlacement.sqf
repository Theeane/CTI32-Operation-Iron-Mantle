/*
    Author: Theane / ChatGPT
    Function: MWF_fn_handleBuildPlacement
    Project: Military War Framework

    Description:
    Server-side validation and pricing for Zeus base-building placements.
*/

if (!isServer) exitWith {};

params [
    ["_entity", objNull, [objNull]],
    ["_builder", objNull, [objNull]]
];

if (isNull _entity) exitWith {};

private _className = typeOf _entity;
private _check = [_className] call MWF_fnc_isBuildAssetAllowed;
if !(_check # 0) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        [(_check # 1)] remoteExec ["systemChat", owner _builder];
    };
};

private _cost = [_className] call MWF_fnc_getBuildAssetCost;
private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mainBasePos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
private _isHeliUpgrade = (_heliClass isNotEqualTo "") && {_className isEqualTo _heliClass};
private _isJetUpgrade = (_jetClass isNotEqualTo "") && {_className isEqualTo _jetClass};
private _isVirtualGarage = (_garageClass isNotEqualTo "") && {_className isEqualTo _garageClass};

if (_isHeliUpgrade && {!(missionNamespace getVariable ["MWF_Unlock_Heli", false])}) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        ["Helicopter Uplink is locked. Complete Sky Guardian first."] remoteExec ["systemChat", owner _builder];
    };
};

if (_isJetUpgrade && {!(missionNamespace getVariable ["MWF_Unlock_Jets", false])}) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        ["Aircraft Control is locked. Complete Point Blank first."] remoteExec ["systemChat", owner _builder];
    };
};

if ((_isHeliUpgrade || _isJetUpgrade) && {(_entity distance2D _mainBasePos) > 120}) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        ["This upgrade structure can only be built at the MOB."] remoteExec ["systemChat", owner _builder];
    };
};

private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

if (_current < _cost) exitWith {
    deleteVehicle _entity;
    if (!isNull _builder) then {
        [format ["Insufficient supplies to build %1. Required: %2", getText (configFile >> "CfgVehicles" >> _className >> "displayName"), _cost]] remoteExec ["systemChat", owner _builder];
    };
};

[(_cost * -1), "SUPPLIES"] call MWF_fnc_addResource;
_entity setVariable ["MWF_BuildCost", _cost, true];
if (_isVirtualGarage) then {
    _entity setVariable ["MWF_isVirtualGarage", true, true];
};

if (!isNull _builder) then {
    [format ["Asset deployed: -%1 Supplies", _cost]] remoteExec ["systemChat", owner _builder];
};

if (_isHeliUpgrade) then {
    [["BASE UPGRADE ONLINE", "Helicopter uplink constructed. Helicopters are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

if (_isJetUpgrade) then {
    [["BASE UPGRADE ONLINE", "Aircraft control constructed. Planes are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

if (_isVirtualGarage) then {
    [["BASE UPGRADE ONLINE", "Virtual garage marker constructed."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

diag_log format ["[MWF BaseBuild] %1 placed by %2 for %3 supplies.", _className, _builder, _cost];
