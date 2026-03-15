/*
    Author: Theane / ChatGPT
    Function: fn_initiatePurchase
    Project: Military War Framework

    Description:
    Handles purchase validation, supply deduction, and asset spawning from the buy menu.
*/

disableSerialization;
private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _selectedIndex = lbCurSel _listBox;

if (_selectedIndex == -1) exitWith { hint "No item selected."; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;
private _isFobAsset = (_classname == MWF_FOB_Truck || _classname == MWF_FOB_Box_Transport);

if (_isFobAsset) then {
    if (player distance MWF_MainBase > 100) exitWith {
        hint parseText "<t color='#ff0000'>Restricted Area</t><br/>FOB assets can only be purchased at the MOB.";
    };

    private _spawnPadPos = getPosATL MWF_MOB_FobPad;
    if ((count (nearestObjects [_spawnPadPos, ["Car", "Air", "Container"], 5])) > 0) exitWith {
        hint parseText "<t color='#ff0000'>Pad Occupied</t><br/>Clear the MOB spawn pad before purchasing a new FOB asset.";
    };
};

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
if (_classname isKindOf "Tank" && { _currentTier < 3 }) exitWith {
    hint "Tier 3 is required for heavy armor.";
};

private _currentSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];

if (["CAN_DEPLOY"] call MWF_fnc_baseManager && { _currentSupplies >= _cost }) then {
    private _newSupplies = _currentSupplies - _cost;
    missionNamespace setVariable ["MWF_Economy_Supplies", _newSupplies, true];
    missionNamespace setVariable ["MWF_Supplies", _newSupplies, true];

    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };

    private _spawnPos = if (_isFobAsset) then {
        getPosATL MWF_MOB_FobPad
    } else {
        private _pads = nearestObjects [player, ["Land_HelipadEmpty_F"], 50];
        if ((count _pads) == 0) exitWith {
            hint "No spawn pad found nearby.";
            []
        };
        getPosATL (_pads select 0)
    };

    if ((count _spawnPos) == 0) exitWith {};

    private _vehicle = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
    _vehicle setDir (getDir MWF_MOB_FobPad);

    hint format ["Asset delivered: %1", getText (configFile >> "CfgVehicles" >> _classname >> "displayName")];
    [] spawn MWF_fnc_updateBuyCategory;
} else {
    hint "Purchase failed. Check supplies and FOB limits.";
};
