/*
    Server-side final purchase. Supplies are deducted only here.
*/
params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (!isServer) exitWith { false };
if (_className isEqualTo "") exitWith { false };

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
if (_supplies < _cost) exitWith {
    [format ["Vehicle purchase failed. Need %1 supplies.", _cost]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};
if (_currentTier < _minTier) exitWith {
    [format ["Vehicle purchase failed. Tier %1 required.", _minTier]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

private _spawnVehicle = createVehicle [_className, [0,0,0], [], 0, "CAN_COLLIDE"];
if (isNull _spawnVehicle) exitWith {
    ["Vehicle purchase failed. Spawn returned null."] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

_spawnVehicle setVariable ["MWF_isBought", true, true];
_spawnVehicle setDir _dir;
_spawnVehicle allowDamage false;
clearWeaponCargoGlobal _spawnVehicle;
clearMagazineCargoGlobal _spawnVehicle;
clearItemCargoGlobal _spawnVehicle;
clearBackpackCargoGlobal _spawnVehicle;

if (_surfaceRule isEqualTo "WATER") then {
    _spawnVehicle setPosASL _posASL;
    _spawnVehicle setVectorUp [0,0,1];
} else {
    private _spawnATL = ASLToATL _posASL;
    _spawnVehicle setPosATL _spawnATL;
    _spawnVehicle setVectorUp (surfaceNormal _spawnATL);
};

private _newSupplies = (_supplies - _cost) max 0;
missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];
missionNamespace setVariable ["MWF_Supply", _newSupplies, true];
if (!isNil "MWF_fnc_updateResourceUI") then { remoteExec ["MWF_fnc_updateResourceUI", -2]; };
if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

[_spawnVehicle] spawn {
    params ["_veh"];
    uiSleep 0.3;
    if (!isNull _veh) then {
        _veh allowDamage true;
        _veh setDamage 0;
    };
};

[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", remoteExecutedOwner];
true
