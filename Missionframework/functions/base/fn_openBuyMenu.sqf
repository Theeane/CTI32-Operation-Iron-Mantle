/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: 
    Opens the Master Command UI (as per sketch). 
    Initializes Digital Currency displays and default categories.
*/

disableSerialization;

// 1. Create the dialog (The Master UI from your sketch)
if !(createDialog "IronMantle_BuyMenu") exitWith {
    diag_log "[KPIN Error] Master UI could not be opened.";
};

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

// 2. Fetch Digital Currency & Tier
private _supplies = missionNamespace getVariable ["KPIN_Supplies", 0];
private _intel = missionNamespace getVariable ["KPIN_Intel", 0];
private _tier = missionNamespace getVariable ["KPIN_CurrentTier", 1];

// 3. Update UI Elements (Digital Currency & Tier status)
// Supplies display
(_display displayCtrl 9001) ctrlSetText format["Supplies: %1", _supplies];

// Intel display (Important for the "Intel is digital currency" rule)
// Assuming Ctrl 9005 is your Intel display based on the sketch layout
(_display displayCtrl 9005) ctrlSetText format["Intel: %1", _intel];

// Tier display (To show current Base Upgrade status)
(_display displayCtrl 9006) ctrlSetText format["Base Tier: %1", _tier];

// 4. Default View: Vehicle Menu
// When opening the PC, we default to the first button in your sketch
["Infantry"] spawn KPIN_fnc_updateBuyCategory;

// 5. Grand Op Cooldown Check
// This logic will be used to grey out the "Main Operations" button if cooldown is active
private _lastOpTime = missionNamespace getVariable ["KPIN_LastGrandOpTime", -1800];
private _cooldown = 1800; // 30 minutes in seconds

if (time - _lastOpTime < _cooldown) then {
    // Logic to visually show cooldown on the Grand Ops button (Ctrl 9010)
    private _remaining = floor ((_cooldown - (time - _lastOpTime)) / 60);
    (_display displayCtrl 9010) ctrlSetTooltip format["Grand Ops on cooldown: %1 min left", _remaining];
};

diag_log "[KPIN] Master Command Map opened. Assets initialized.";
