/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Checks funds, deducts supplies, and spawns the unit/vehicle at the nearest Spawn Pad.
    Language: English
*/

disableSerialization;
private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _selectedIndex = lbCurSel _listBox;

if (_selectedIndex == -1) exitWith { hint "No item selected!"; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;

// 1. Check Funds (Using the correct KPIN variable)
private _currentSupplies = missionNamespace getVariable ["KPIN_Supplies", 0];
if (_currentSupplies < _cost) exitWith { 
    hint parseText "<t color='#ff0000' size='1.2'>Insufficient Supplies!</t><br/>Collect more from zones.";
};

// 2. Determine Spawn Position
// Looks for Land_HelipadEmpty_F within 50 meters
private _spawnPos = [];
private _nearPads = nearestObjects [player, ["Land_HelipadEmpty_F"], 50];

if (count _nearPads > 0) then {
    _spawnPos = getPosATL (_nearPads select 0); 
} else {
    // Fallback: 10 meters in front of player
    _spawnPos = player modelToWorld [0, 10, 0];
};

// 3. Deduct Cost & Sync (Global update)
_currentSupplies = _currentSupplies - _cost;
missionNamespace setVariable ["KPIN_Supplies", _currentSupplies, true];

// Trigger a save request since economy changed
if (!isNil "KPIN_fnc_requestDelayedSave") then {
    [] call KPIN_fnc_requestDelayedSave;
};

// 4. Spawn Logic
if (_classname isKindOf "Man") then {
    private _unit = (group player) createUnit [_classname, _spawnPos, [], 2, "FORM"];
    hint format["Enlisted: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
} else {
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _veh setDir (getDir player); 
    hint format["Purchased: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
};

// 5. Update UI (Using KPIN prefix)
if (!isNil "KPIN_fnc_updateBuyCategory") then {
    [] spawn KPIN_fnc_updateBuyCategory; 
};

diag_log format ["[KPIN] Purchase complete: %1 for %2 supplies.", _classname, _cost];
