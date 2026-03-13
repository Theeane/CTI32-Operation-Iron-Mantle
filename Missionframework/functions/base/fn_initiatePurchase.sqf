/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Handles purchases with specific MOB-only logic for FOB assets.
    Language: English
*/

disableSerialization;
private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _selectedIndex = lbCurSel _listBox;

if (_selectedIndex == -1) exitWith { hint "No item selected!"; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;

// 1. IDENTIFY FOB ASSETS
private _isFobAsset = (_classname == KPIN_FOB_Truck || _classname == KPIN_FOB_Box_Transport);

// 2. MOB-ONLY RULE FOR FOBs
if (_isFobAsset) then {
    // Check distance to MOB (Main Base)
    if (player distance KPIN_MainBase > 100) exitWith {
        hint parseText "<t color='#ff0000'>Restricted Area</t><br/>FOB Assets can only be commissioned at the MOB.";
        breakOut "purchase";
    };

    // Check if the specific MOB Spawn Pad is occupied
    private _spawnPos = getPosATL KPIN_MOB_FobPad;
    if (count (nearestObjects [_spawnPos, ["Car", "Air", "Container"], 5]) > 0) exitWith {
        hint parseText "<t color='#ff0000'>Pad Occupied</t><br/>Clear the MOB Spawn Pad before commissioning a new FOB.";
        breakOut "purchase";
    };
};

// 3. TIER & GRAND OP CHECKS (Same as before...)
private _currentTier = missionNamespace getVariable ["KPIN_CurrentTier", 1];
if (_classname isKindOf "Tank" && _currentTier < 3) exitWith {
    hint "Tier 3 Required for Heavy Armor.";
};

// 4. ECONOMY & LIMIT CHECK
if (["CAN_DEPLOY"] call KPIN_fnc_baseManager && { (missionNamespace getVariable ["KPIN_Supplies", 0]) >= _cost }) then {
    
    // Deduct Funds
    private _newSupplies = (missionNamespace getVariable ["KPIN_Supplies", 0]) - _cost;
    missionNamespace setVariable ["KPIN_Supplies", _newSupplies, true];
    [] call KPIN_fnc_requestDelayedSave;

    // 5. SPAWN LOGIC
    private _spawnPos = if (_isFobAsset) then { getPosATL KPIN_MOB_FobPad } else { (nearestObjects [player, ["Land_HelipadEmpty_F"], 50] select 0) };
    
    private _veh = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _veh setDir (getDir KPIN_MOB_FobPad);
    
    hint format["Asset Delivered to Pad: %1", getText(configFile >> "CfgVehicles" >> _classname >> "displayName")];
    [] spawn KPIN_fnc_updateBuyCategory;
} else {
    hint "Purchase failed: Check funds or FOB limits.";
};
