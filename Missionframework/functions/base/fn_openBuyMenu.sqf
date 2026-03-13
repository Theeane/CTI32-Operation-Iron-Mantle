/*
    Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Opens the Buy Menu and initializes the supply display and the default category.
    Language: English
*/

disableSerialization;

// 1. Create the dialog
if !(createDialog "IronMantle_BuyMenu") exitWith {
    diag_log "[KPIN Error] Could not create Buy Menu dialog.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

// 2. Update the Supply Count Text immediately
private _supplyText = _display displayCtrl 9001;
private _currentSupplies = missionNamespace getVariable ["KPIN_Supplies", 0];
_supplyText ctrlSetText format["Supplies: %1", _currentSupplies];

// 3. Populate the list with the default category (Infantry)
["Infantry"] spawn KPIN_fnc_updateBuyCategory;

diag_log "[KPIN] Buy Menu opened successfully.";
