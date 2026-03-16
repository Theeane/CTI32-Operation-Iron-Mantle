/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBuyMenu
    Project: Military War Framework

    Description:
    Opens the procurement UI against the authoritative digital economy.
    Supplies are used for procurement, while Intel remains a separate strategic pool.
*/

disableSerialization;

createDialog "IronMantle_BuyMenu";
if !(dialog) exitWith {
    diag_log "[MWF Error] Master UI could not be opened.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];

(_display displayCtrl 9001) ctrlSetText format ["Supplies: %1 | Intel: %2", _supplies, _intel];

["Infantry"] spawn MWF_fnc_updateBuyCategory;

diag_log "[MWF] Master Command Map opened. Digital economy initialized.";
