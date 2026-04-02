/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_purchaseAsset
    Project: Military War Framework

    Description:
    Handles purchase validation, supply deduction, and asset spawning from the buy menu.
    FOB truck/box assets are restricted to the MOB and initialized as deployables.
*/

disableSerialization;
private _display = findDisplay 9060;
if (isNull _display) then {
    _display = findDisplay 9000;
};
if (isNull _display) exitWith { hint "Buy menu unavailable."; };

private _listBox = _display displayCtrl 9002;
if (isNull _listBox) exitWith { hint "Buy menu unavailable."; };

private _selectedIndex = lbCurSel _listBox;
if (_selectedIndex == -1) exitWith { hint "No item selected."; };

private _classname = _listBox lbData _selectedIndex;
private _cost = _listBox lbValue _selectedIndex;
private _fobTruckClass = missionNamespace getVariable ["MWF_FOB_Truck", "B_Truck_01_Repair_F"];
private _fobBoxClass = missionNamespace getVariable ["MWF_FOB_Box", "B_Slingload_01_Cargo_F"];
private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
private _mobFobPad = missionNamespace getVariable ["MWF_MOB_FobPad", objNull];
private _isFobAsset = (_classname == _fobTruckClass || _classname == _fobBoxClass);

if (_isFobAsset) then {
    if (isNull _mainBase || {player distance _mainBase > 100}) exitWith {
        hint parseText "<t color='#ff0000'>Restricted Area</t><br/>FOB assets can only be purchased at the MOB.";
    };

    if (isNull _mobFobPad) exitWith {
        hint parseText "<t color='#ff0000'>Spawn Pad Missing</t><br/>No MOB FOB pad could be resolved for this purchase.";
    };

    private _spawnPadPos = getPosATL _mobFobPad;
    if ((count (nearestObjects [_spawnPadPos, ["Car", "Air", "Container"], 5])) > 0) exitWith {
        hint parseText "<t color='#ff0000'>Pad Occupied</t><br/>Clear the MOB spawn pad before purchasing a new FOB asset.";
    };

    private _maxFobs = missionNamespace getVariable ["MWF_Param_MaxFOBs", 3];
    private _activeFobs = missionNamespace getVariable ["MWF_FOB_Registry", []];
    if ((count _activeFobs) >= _maxFobs) exitWith {
        hint format ["Purchase failed. FOB limit reached (%1/%2 active).", count _activeFobs, _maxFobs];
    };
};

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
if (_classname isKindOf "Tank" && {_currentTier < 3}) exitWith {
    hint "Tier 3 is required for heavy armor.";
};

private _currentSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_currentSupplies < _cost) exitWith {
    hint "Insufficient supplies for this purchase.";
};

private _newSupplies = _currentSupplies - _cost;
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_newSupplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;

private _spawnPos = [];
private _spawnDir = 0;

if (_isFobAsset) then {
    _spawnPos = getPosATL _mobFobPad;
    _spawnDir = getDir _mobFobPad;
} else {
    private _pads = nearestObjects [player, ["Land_HelipadEmpty_F"], 50];
    if ((count _pads) == 0) exitWith {
        hint "No spawn pad found nearby.";
        []
    };
    _spawnPos = getPosATL (_pads select 0);
    _spawnDir = getDir (_pads select 0);
};

if ((count _spawnPos) == 0) exitWith {};

private _vehicle = createVehicle [_classname, _spawnPos, [], 0, "NONE"];
_vehicle setDir _spawnDir;
_vehicle setPosATL _spawnPos;
_vehicle setVariable ["MWF_isBought", true, true];

if (_isFobAsset) then {
    [_vehicle] remoteExec ["MWF_fnc_initFOB", 0, true];
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
private _respawnHeliClass = missionNamespace getVariable ["MWF_Respawn_Heli", ""];
if (_classname in [_respawnTruckClass, _respawnHeliClass]) then {
    [_vehicle] remoteExecCall ["MWF_fnc_initMobileRespawn", 2];
};

hint format ["Asset delivered: %1", getText (configFile >> "CfgVehicles" >> _classname >> "displayName")];
[] spawn MWF_fnc_updateBuyCategory;
