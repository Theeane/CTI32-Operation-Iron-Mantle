params [
    ["_className", "", [""]],
    ["_cost", -1, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];
if (!isServer) exitWith { false };
if (_className isEqualTo "") exitWith { false };

private _owner = remoteExecutedOwner;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];

private _unlockSatisfied = switch (toUpper _requiredUnlock) do {
    case "HELI": { ["HELI"] call MWF_fnc_hasProgressionAccess };
    case "JETS": { ["JETS"] call MWF_fnc_hasProgressionAccess };
    case "ARMOR": { ["ARMOR"] call MWF_fnc_hasProgressionAccess };
    default { true };
};
if !_unlockSatisfied exitWith {
    [format ["Vehicle purchase failed. %1 unlock required.", if (_requiredUnlock isEqualTo "") then {"category"} else {_requiredUnlock}]] remoteExec ["systemChat", _owner];
    false
};
if (_isTier5 && {!( ["TIER5"] call MWF_fnc_hasProgressionAccess )}) exitWith {
    ["Vehicle purchase failed. Complete Apex Predator first."] remoteExec ["systemChat", _owner];
    false
};
if (_supplies < _cost) exitWith {
    [format ["Vehicle purchase failed. Need %1 supplies.", _cost]] remoteExec ["systemChat", _owner];
    false
};
if (_currentTier < _minTier) exitWith {
    [format ["Vehicle purchase failed. Tier %1 required.", _minTier]] remoteExec ["systemChat", _owner];
    false
};

private _spawnVehicle = createVehicle [_className, [0,0,0], [], 0, "CAN_COLLIDE"];
if (isNull _spawnVehicle) exitWith {
    ["Vehicle purchase failed. Spawn returned null."] remoteExec ["systemChat", _owner];
    false
};
_spawnVehicle setVariable ["MWF_isBought", true, true];
_spawnVehicle allowDamage false;
_spawnVehicle setDir _dir;
if (_surfaceRule isEqualTo "WATER") then {
    _spawnVehicle setPosASL _posASL;
    _spawnVehicle setVectorUp [0,0,1];
} else {
    private _spawnATL = ASLToATL _posASL;
    _spawnVehicle setPosATL _spawnATL;
    if (_className isKindOf ["Air", configFile >> "CfgVehicles"]) then {
        _spawnVehicle setVectorUp [0,0,1];
    } else {
        _spawnVehicle setVectorUp surfaceNormal _spawnATL;
    };
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
private _respawnHeliClass = missionNamespace getVariable ["MWF_Respawn_Heli", ""];
if ((_respawnTruckClass isNotEqualTo "" && {_className isEqualTo _respawnTruckClass}) || (_respawnHeliClass isNotEqualTo "" && {_className isEqualTo _respawnHeliClass})) then {
    [_spawnVehicle] call MWF_fnc_initMobileRespawn;
};

[_spawnVehicle] spawn {
    params ["_veh"];
    uiSleep 0.5;
    if (!isNull _veh) then { _veh allowDamage true; };
};

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
private _newSupplies = (_supplies - _cost) max 0;
if (!isNil "MWF_fnc_syncEconomyState") then {
    [_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
} else {
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
    missionNamespace setVariable ["MWF_Currency", _newSupplies + _intel, true];
    remoteExec ["MWF_fnc_updateResourceUI", -2];
};
if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", _owner];
true
