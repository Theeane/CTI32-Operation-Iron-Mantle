/*
    Author: OpenAI
    Function: MWF_fnc_openLoadoutArsenal
    Project: Military War Framework

    Description:
    Opens a curated Virtual Arsenal that excludes OPFOR uniforms while allowing
    the root global blacklist to remove any supported arsenal class across
    weapons, magazines, items and backpacks.
*/

if (!hasInterface) exitWith { false };
if (missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) then {
    diag_log "[MWF VEHICLE DBG][ARSENAL] arsenal opened during active vehicle placement; forcing cancel";
    systemChat "[MWF DBG] Arsenal opened during placement. Cancelling and refunding vehicle purchase.";
    [] call MWF_fnc_vehicleBuildCancel;
    private _cancelTimeout = diag_tickTime + 3;
    waitUntil {
        uiSleep 0.05;
        !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) || { diag_tickTime > _cancelTimeout }
    };
};
if !(missionNamespace getVariable ["MWF_InLoadoutZone", false]) exitWith {
    hint "Du måste vara i en loadout-zon nära MOB eller FOB för att öppna arsenalen.";
    false
};

[] call MWF_fnc_buildLoadoutCaches;
private _arsenalItems = missionNamespace getVariable ["MWF_ArsenalItemClasses", []];
private _arsenalWeapons = missionNamespace getVariable ["MWF_ArsenalWeaponClasses", []];
private _arsenalMagazines = missionNamespace getVariable ["MWF_ArsenalMagazineClasses", []];
private _arsenalBackpacks = missionNamespace getVariable ["MWF_ArsenalBackpackClasses", []];

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

[_box, _arsenalWeapons, false] call BIS_fnc_addVirtualWeaponCargo;
[_box, _arsenalMagazines, false] call BIS_fnc_addVirtualMagazineCargo;
[_box, _arsenalBackpacks, false] call BIS_fnc_addVirtualBackpackCargo;
[_box, _arsenalItems, false] call BIS_fnc_addVirtualItemCargo;

["Open", [false, _box, player]] call BIS_fnc_arsenal;
true
