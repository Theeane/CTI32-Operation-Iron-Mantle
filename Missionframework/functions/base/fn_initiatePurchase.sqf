/* Author: Theeane
    Description: Checks funds, deducts supplies, and spawns the unit/vehicle.
*/
disableSerialization;
private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _selectedIndex = lbCurSel _listBox;

if (_selectedIndex == -1) exitWith { hint "No item selected!"; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;

// 1. Check Funds
if (GVAR_Economy_Supplies < _cost) exitWith { 
    hint parseText "<t color='#ff0000'>Insufficient Supplies!</t>";
};

// 2. Deduct Cost (Global update)
GVAR_Economy_Supplies = GVAR_Economy_Supplies - _cost;
publicVariable "GVAR_Economy_Supplies";

// 3. Spawn Logic (Simple for now, spawns in front of player)
private _spawnPos = player modelToWorld [0, 10, 0];
if (_classname isKindOf "Man") then {
    // Create Infantry in player's group
    private _unit = (group player) createUnit [_classname, _spawnPos, [], 0, "FORM"];
    hint format["Enlisted: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
} else {
    // Create Vehicle
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    hint format["Purchased: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
};

// 4. Update UI to reflect new supply count
[] call CTI_fnc_updateBuyCategory; // Refresh list colors
