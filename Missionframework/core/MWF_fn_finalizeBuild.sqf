/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_finalizeBuild
    Project: Military War Framework

    Description:
    Finalizes a server-side physical base-upgrade build request and synchronizes the shared supply pool.
*/

if (!isServer) exitWith { false };

params [
    ["_className", "", [""]],
    ["_posATL", [0, 0, 0], [[]], 3],
    ["_dir", 0, [0]],
    ["_price", 0, [0]],
    ["_upgradeId", "", [""]]
];

if (_className isEqualTo "") exitWith { false };

private _upgradeKey = toUpper _upgradeId;
private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
private _registry = + (missionNamespace getVariable ["MWF_BuiltUpgradeRegistry", []]);

private _registryIndex = _registry findIf {
    private _existingKey = toUpper ((_x param [0, "", [""]]) call BIS_fnc_trimString);
    private _existingObj = _x param [1, objNull, [objNull]];
    (_existingKey isEqualTo _upgradeKey) && {!isNull _existingObj}
};
if (_registryIndex >= 0) exitWith {
    [format ["Upgrade build rejected: %1 already exists.", _upgradeId]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

switch (_upgradeKey) do {
    case "HELI": {
        if !(_className isEqualTo _heliClass) exitWith {
            ["Upgrade build rejected: invalid Helicopter Uplink class."] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };
        if !(missionNamespace getVariable ["MWF_Unlock_Heli", false]) exitWith {
            ["Helicopter Uplink is locked. Complete Sky Guardian first."] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };
    };
    case "JET": {
        if !(_className isEqualTo _jetClass) exitWith {
            ["Upgrade build rejected: invalid Aircraft Control class."] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };
        if !(missionNamespace getVariable ["MWF_Unlock_Jets", false]) exitWith {
            ["Aircraft Control is locked. Complete Point Blank first."] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };
    };
    default {
        ["Upgrade build rejected: unknown upgrade request."] remoteExec ["systemChat", remoteExecutedOwner];
        false
    };
};

if ((_posATL distance2D _mobPos) > 120) exitWith {
    ["This upgrade structure can only be built at the MOB."] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

private _current = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_current < _price) exitWith {
    [format ["Insufficient supplies. Required: %1", _price]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

private _vehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
if (isNull _vehicle) exitWith {
    [format ["Failed to create upgrade object: %1", _className]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

_vehicle allowDamage false;
_vehicle setDir _dir;
_vehicle setPosATL _posATL;
_vehicle setVectorUp surfaceNormal _posATL;
_vehicle setVariable ["MWF_isPhysicalBaseUpgrade", true, true];
_vehicle setVariable ["MWF_UpgradeId", _upgradeKey, true];
_vehicle setVariable ["MWF_BuildCost", _price, true];
_vehicle setVariable ["MWF_BaseKey", "MOB", true];

_registry = _registry select { !isNull (_x param [1, objNull]) };
_registry pushBack [_upgradeKey, _vehicle, _className];
missionNamespace setVariable ["MWF_BuiltUpgradeRegistry", _registry, true];

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newValue = (_current - _price) max 0;
[_newValue, _intel, _notoriety] call MWF_fnc_syncEconomyState;

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

switch (_upgradeKey) do {
    case "HELI": {
        [["BASE UPGRADE ONLINE", "Helicopter uplink constructed. Helicopters are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
    };
    case "JET": {
        [["BASE UPGRADE ONLINE", "Aircraft control constructed. Planes are now available in the vehicle menu."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
    };
};

true
