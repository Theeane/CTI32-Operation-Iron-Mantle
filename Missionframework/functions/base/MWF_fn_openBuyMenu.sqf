/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBuyMenu
    Project: Military War Framework

    Description:
    Handles open buy menu for the base system.
    Strict migration from original fn_openBuyMenu.sqf.
*/

disableSerialization;

// 1. Create the dialog
if !(createDialog "IronMantle_BuyMenu") exitWith {
    diag_log "[MWF Error] Master UI could not be opened.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

// 2. Fetch Total Digital Currency (S) & Tier
// Read the shared currency pool instead of separate resource pools
private _currency = missionNamespace getVariable ["MWF_Currency", 0];
private _tier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _hasMobileTech = missionNamespace getVariable ["MWF_Upgrade_MobileRespawn", false];

// 3. Update UI Elements
// S-Currency Display (Visar totalen av Supply + Intel)
(_display displayCtrl 9001) ctrlSetText format["Digital Currency (S): %1", _currency];

// Tier status
(_display displayCtrl 9006) ctrlSetText format["Base Tier: %1", _tier];

// 4. Mobile Tech Status (Visuellt kvitto i menyn)
private _techStatus = if (_hasMobileTech) then {"Mobile Tech: ACTIVE"} else {"Mobile Tech: LOCKED"};
(_display displayCtrl 9005) ctrlSetText _techStatus; // Reuse the Intel field to display tech status

// 5. Default View: Vehicle Menu
// Updated to use the new MWF_fnc_ prefix for the sub-function
["Infantry"] spawn MWF_fnc_updateBuyCategory;

// 6. Grand Op Cooldown Check
private _lastOpTime = missionNamespace getVariable ["MWF_LastGrandOpTime", -1800];
private _cooldown = 1800; 

if (time - _lastOpTime < _cooldown) then {
    private _remaining = floor ((_cooldown - (time - _lastOpTime)) / 60);
    (_display displayCtrl 9010) ctrlSetTooltip format["Grand Ops on cooldown: %1 min left", _remaining];
    // (_display displayCtrl 9010) ctrlEnable false; // Optional: disable the button completely
};

diag_log "[MWF] Master Command Map opened. Currency & Tech initialized.";
