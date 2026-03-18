/*
    Author: OpenAI
    Function: MWF_fnc_openLoadoutArsenal
    Project: Military War Framework

    Description:
    Opens a curated Virtual Arsenal that excludes OPFOR uniforms while keeping
    all other regular categories available.
*/

if (!hasInterface) exitWith { false };

[] call MWF_fnc_buildLoadoutCaches;
private _arsenalItems = missionNamespace getVariable ["MWF_ArsenalItemClasses", []];

private _box = missionNamespace getVariable ["MWF_LoadoutArsenalBox", objNull];
if (isNull _box) then {
    _box = "B_supplyCrate_F" createVehicleLocal [0, 0, 0];
    _box enableSimulation false;
    _box allowDamage false;
    _box hideObject true;
    missionNamespace setVariable ["MWF_LoadoutArsenalBox", _box];
};

clearWeaponCargo _box;
clearMagazineCargo _box;
clearItemCargo _box;
clearBackpackCargo _box;

[_box, true, false] call BIS_fnc_addVirtualWeaponCargo;
[_box, true, false] call BIS_fnc_addVirtualMagazineCargo;
[_box, true, false] call BIS_fnc_addVirtualBackpackCargo;
[_box, _arsenalItems, false] call BIS_fnc_addVirtualItemCargo;

["Open", [false, _box, player]] call BIS_fnc_arsenal;
true
