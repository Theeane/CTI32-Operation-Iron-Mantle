params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0, 0, 0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]]
];

if (!isServer) exitWith { false };
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
    [format ["Vehicle purchase failed. %1 unlock required.", if (_requiredUnlock isEqualTo "") then {"category"} else {_requiredUnlock}]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

if (_isTier5 && { !(["TIER5"] call MWF_fnc_hasProgressionAccess) }) exitWith {
    ["Vehicle purchase failed. Complete Apex Predator first."] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

if ((toUpper _requiredUnlock) in ["HELI", "JETS"] && { !([_requiredUnlock] call _hasRequiredUpgradeStructure) }) exitWith {
    [format ["Vehicle purchase failed. Build the %1 structure at the MOB first.", if ((toUpper _requiredUnlock) isEqualTo "HELI") then {"Helicopter Uplink"} else {"Aircraft Control"}]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

if ((toUpper _requiredUnlock) isEqualTo "HELI") then {
    private _discount = missionNamespace getVariable ["MWF_Perk_HeliDiscount", 1];
    if (_discount < 1) then {
        _cost = round ((_cost * _discount) max 1);
    };
};

if (_supplies < _cost) exitWith {
    [format ["Vehicle purchase failed. Need %1 supplies.", _cost]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

if (_currentTier < _minTier) exitWith {
    [format ["Vehicle purchase failed. Tier %1 required.", _minTier]] remoteExec ["systemChat", remoteExecutedOwner];
    false
};

private _spawnVehicle = createVehicle [_className, [0, 0, 0], [], 0, "CAN_COLLIDE"];
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
    _spawnVehicle setVectorUp [0, 0, 1];
} else {
    _spawnVehicle setPosASL _posASL;
    _spawnVehicle setVectorUp (surfaceNormal (ASLToATL _posASL));
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
private _respawnHeliClass = missionNamespace getVariable ["MWF_Respawn_Heli", ""];
if ((_respawnTruckClass isNotEqualTo "" && {_className isEqualTo _respawnTruckClass}) || (_respawnHeliClass isNotEqualTo "" && {_className isEqualTo _respawnHeliClass})) then {
    [_spawnVehicle] call MWF_fnc_initMobileRespawn;
    [if (_className isEqualTo _respawnHeliClass) then {"Respawn Helicopter deployed."} else {"Mobile Respawn Unit deployed."}] remoteExec ["systemChat", remoteExecutedOwner];
};

[_spawnVehicle] spawn {
    params ["_veh"];
    uiSleep 0.5;
    if (!isNull _veh) then {
        _veh allowDamage true;
    };
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

private _debugMode = missionNamespace getVariable ["MWF_DebugMode", false];
if (!_debugMode && {!isNil "MWF_fnc_saveGame"}) then {
    ["Vehicle Purchase"] call MWF_fnc_saveGame;
} else {
    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };
};

[format ["Vehicle deployed: %1", _className]] remoteExec ["systemChat", remoteExecutedOwner];
true
