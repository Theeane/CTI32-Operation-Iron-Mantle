/*
    Author: OpenAI
    Function: MWF_fnc_serverPurchasePlacedVehicle
    Project: Military War Framework

    Description:
    Server-authoritative vehicle purchase finalization.
*/

if (!isServer) exitWith {
    _this remoteExecCall ["MWF_fnc_serverPurchasePlacedVehicle", 2];
    false
};

params [
    ["_className", "", [""]],
    ["_cost", 0, [0]],
    ["_minTier", 1, [0]],
    ["_posASL", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_surfaceRule", "LAND", [""]],
    ["_requiredUnlock", "", [""]],
    ["_isTier5", false, [false]],
    ["_requestOwner", 0, [0]]
];

if (_className isEqualTo "") exitWith { false };
if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith { false };

private _fail = {
    params ["_msg"];
    if (_requestOwner > 0) then {
        [["VEHICLE MENU", _msg], "warning"] remoteExecCall ["MWF_fnc_showNotification", _requestOwner];
    };
    false
};

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
if (_currentTier < _minTier) exitWith { [format ["Requires Base Tier %1.", _minTier]] call _fail };

if (_isTier5 && {!( ["TIER5"] call MWF_fnc_hasProgressionAccess )}) exitWith { ["Tier 5 vehicle still locked."] call _fail };

switch (toUpper _requiredUnlock) do {
    case "ARMOR": {
        if !( ["ARMOR"] call MWF_fnc_hasProgressionAccess ) exitWith { ["Armor unlock not completed."] call _fail };
    };
    case "HELI": {
        if !( ["HELI"] call MWF_fnc_hasProgressionAccess ) exitWith { ["Helicopter unlock not completed."] call _fail };
    };
    case "JETS": {
        if !( ["JETS"] call MWF_fnc_hasProgressionAccess ) exitWith { ["Aircraft unlock not completed."] call _fail };
    };
};

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_supplies < _cost) exitWith { [format ["Insufficient Supplies: %1 needed.", _cost]] call _fail };

private _posATL = ASLToATL _posASL;
private _isWater = surfaceIsWater [_posATL select 0, _posATL select 1];
if ((toUpper _surfaceRule) isEqualTo "WATER" && {!_isWater}) exitWith { ["Boat placement invalid."] call _fail };
if ((toUpper _surfaceRule) isEqualTo "LAND" && {_isWater}) exitWith { ["Land vehicle placement invalid."] call _fail };

private _vehicle = createVehicle [_className, _posATL, [], 0, "NONE"];
if (isNull _vehicle) exitWith { ["Server failed to spawn vehicle."] call _fail };

if ((toUpper _surfaceRule) isEqualTo "WATER") then {
    _vehicle setPosASL _posASL;
    _vehicle setVectorUp [0,0,1];
} else {
    _vehicle setPosATL _posATL;
    _vehicle setVectorUp (surfaceNormal position _vehicle);
};
_vehicle setDir _dir;
_vehicle setVehicleLock "UNLOCKED";
_vehicle setVariable ["MWF_isBought", true, true];
clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearItemCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies - _cost, _intel, _notoriety] call MWF_fnc_syncEconomyState;

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
private _respawnHeliClass = missionNamespace getVariable ["MWF_Respawn_Heli", ""];
if (_className in [_respawnTruckClass, _respawnHeliClass]) then {
    [_vehicle] remoteExecCall ["MWF_fnc_initMobileRespawn", 2];
};

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};

if (_requestOwner > 0) then {
    [["VEHICLE MENU", format ["Purchased: %1 (-%2 Supplies)", getText (configFile >> "CfgVehicles" >> _className >> "displayName"), _cost]], "success"] remoteExecCall ["MWF_fnc_showNotification", _requestOwner];
};

true
