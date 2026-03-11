/*
    Author: Theeane / Gemini
    Description: 
    Opens the Iron Mantle Buy Menu and initializes the supply display 
    and the default category (Infantry).

    Usage: [] spawn AGS_fnc_openBuyMenu;
*/

disableSerialization;

// 1. Create the dialog
if !(createDialog "IronMantle_BuyMenu") exitWith {
    diag_log "[AGS Error] Could not create Buy Menu dialog.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

// 2. Update the Supply Count Text immediately
private _supplyText = _display displayCtrl 9001;
_supplyText ctrlSetText format["Supplies: %1", GVAR_Economy_Supplies];

// 3. Populate the list with the default category (Infantry)
// We use spawn to ensure the listbox exists before the script tries to fill it
["Infantry"] spawn AGS_fnc_updateBuyCategory;

diag_log "[AGS] Buy Menu opened successfully.";
