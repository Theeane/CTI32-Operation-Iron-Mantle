/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Validates funds, Tier requirements, and Grand Op unlocks before spawning assets.
    Language: English
*/

disableSerialization;
private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _selectedIndex = lbCurSel _listBox;

if (_selectedIndex == -1) exitWith { hint "No item selected!"; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;

// 1. RULE CHECK: Base Tier Requirements
// We fetch the current tier to see if the player is allowed to buy heavy armor
private _currentTier = missionNamespace getVariable ["KPIN_CurrentTier", 1];

if (_classname isKindOf "Tank" && _currentTier < 3) exitWith {
    hint parseText "<t color='#ff0000' size='1.2'>Tier 3 Required!</t><br/>Upgrade your base to purchase Heavy Armor.";
};

// 2. RULE CHECK: Grand Op Unlocks
// Helicopters and Jets require their specific missions to be completed
private _completedMissions = missionNamespace getVariable ["KPIN_completedMissions", []];

if (_classname isKindOf "Helicopter" && !("GrandOp_Heli_Unlock" in _completedMissions)) exitWith {
    hint parseText "<t color='#ff0000' size='1.2'>Air Assets Locked!</t><br/>Complete the Aerial Superiority Grand Op first.";
};

if (_classname isKindOf "Plane" && !("GrandOp_Jet_Unlock" in _completedMissions)) exitWith {
    hint parseText "<t color='#ff0000' size='1.2'>Jet Assets Locked!</t><br/>Complete the Strategic Strike Grand Op first.";
};

// 3. Check Funds
private _currentSupplies = missionNamespace getVariable ["KPIN_Supplies", 0];
if (_currentSupplies < _cost) exitWith { 
    hint parseText "<t color='#ff0000' size='1.2'>Insufficient Supplies!</t><br/>Collect more from zones.";
};

// 4. Determine Spawn Position
private _nearPads = nearestObjects [player, ["Land_HelipadEmpty_F"], 50];
private _spawnPos = if (count _nearPads > 0) then { getPosATL (_nearPads select 0) } else { player modelToWorld [0, 10, 0] };

// 5. Deduct Cost & Sync
_currentSupplies = _currentSupplies - _cost;
missionNamespace setVariable ["KPIN_Supplies", _currentSupplies, true];

if (!isNil "KPIN_fnc_requestDelayedSave") then {
    [] call KPIN_fnc_requestDelayedSave;
};

// 6. Spawn Logic
if (_classname isKindOf "Man") then {
    private _unit = (group player) createUnit [_classname, _spawnPos, [], 2, "FORM"];
    hint format["Enlisted: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
} else {
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _veh setDir (getDir player); 
    hint format["Purchased: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
};

// 7. Update UI
if (!isNil "KPIN_fnc_updateBuyCategory") then {
    [] spawn KPIN_fnc_updateBuyCategory; 
};

diag_log format ["[KPIN] Purchase complete: %1 for %2 supplies.", _classname, _cost];
