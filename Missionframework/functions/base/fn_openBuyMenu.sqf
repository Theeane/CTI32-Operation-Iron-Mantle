/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Opens the Master Command UI. Handles Digital Currency (S) and Tier.
*/

disableSerialization;

// 1. Create the dialog
if !(createDialog "IronMantle_BuyMenu") exitWith {
    diag_log "[KPIN Error] Master UI could not be opened.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

// 2. Fetch Total Digital Currency (S) & Tier
// Vi hämtar den gemensamma valutan istället för separata potter
private _currency = missionNamespace getVariable ["KPIN_Currency", 0];
private _tier = missionNamespace getVariable ["KPIN_CurrentTier", 1];
private _hasMobileTech = missionNamespace getVariable ["KPIN_Upgrade_MobileRespawn", false];

// 3. Update UI Elements
// S-Currency Display (Visar totalen av Supply + Intel)
(_display displayCtrl 9001) ctrlSetText format["Digital Currency (S): %1", _currency];

// Tier status
(_display displayCtrl 9006) ctrlSetText format["Base Tier: %1", _tier];

// 4. Mobile Tech Status (Visuellt kvitto i menyn)
private _techStatus = if (_hasMobileTech) then {"Mobile Tech: ACTIVE"} else {"Mobile Tech: LOCKED"};
(_display displayCtrl 9005) ctrlSetText _techStatus; // Använder Intel-platsen för tech-status

// 5. Default View: Vehicle Menu
["Infantry"] spawn KPIN_fnc_updateBuyCategory;

// 6. Grand Op Cooldown Check
private _lastOpTime = missionNamespace getVariable ["KPIN_LastGrandOpTime", -1800];
private _cooldown = 1800; 

if (time - _lastOpTime < _cooldown) then {
    private _remaining = floor ((_cooldown - (time - _lastOpTime)) / 60);
    (_display displayCtrl 9010) ctrlSetTooltip format["Grand Ops on cooldown: %1 min left", _remaining];
    // (_display displayCtrl 9010) ctrlEnable false; // Valfritt: Gråa ut knappen helt
};

diag_log "[KPIN] Master Command Map opened. Currency & Tech initialized.";
