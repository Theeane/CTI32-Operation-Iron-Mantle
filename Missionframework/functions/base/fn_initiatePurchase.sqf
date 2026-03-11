/* Author: Theeane / Gemini
    Description: Checks funds, deducts supplies, and spawns the unit/vehicle at the nearest Spawn Pad.
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
    hint parseText "<t color='#ff0000' size='1.2'>Insufficient Supplies!</t><br/>Collect more from zones.";
};

// 2. Determine Spawn Position
// We look for the nearest "Empty Helipad" within 50 meters of the player.
// In your FOB composition, you should include a "Land_HelipadEmpty_F".
private _spawnPos = [];
private _nearPads = nearestObjects [player, ["Land_HelipadEmpty_F"], 50];

if (count _nearPads > 0) then {
    _spawnPos = getPosATL (_nearPads select 0); // Use the closest pad
} else {
    // Fallback: 10 meters in front if no pad is found
    _spawnPos = player modelToWorld [0, 10, 0];
};

// 3. Deduct Cost (Global update)
GVAR_Economy_Supplies = GVAR_Economy_Supplies - _cost;
publicVariable "GVAR_Economy_Supplies";

// 4. Spawn Logic
if (_classname isKindOf "Man") then {
    // Create Infantry in player's group
    private _unit = (group player) createUnit [_classname, _spawnPos, [], 2, "FORM"];
    hint format["Enlisted: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
} else {
    // Create Vehicle at the pad's exact position
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _veh setDir (getDir player); // Optional: Make it face the same way as player
    hint format["Purchased: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
};

// 5. Update UI to reflect new supply count (Using the AGS tag)
[] spawn AGS_fnc_updateBuyCategory; 

diag_log format ["[AGS] Purchase complete: %1 for %2 supplies.", _classname, _cost];
