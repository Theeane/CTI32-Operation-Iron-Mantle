/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Handles Base Tier progression. Deducts supplies and unlocks advanced assets.
    Language: English
*/

if (!isServer) exitWith {};

private _currentTier = missionNamespace getVariable ["KPIN_CurrentTier", 1];
private _supplies = missionNamespace getVariable ["KPIN_Supplies", 0];

// Define costs for each tier upgrade
// Tier 1 -> 2: 1500 Supplies
// Tier 2 -> 3: 3500 Supplies
private _upgradeCosts = [0, 1500, 3500]; 
private _nextTier = _currentTier + 1;

// 1. Check if we are already at max level
if (_currentTier >= 3) exitWith {
    ["TaskFailed", ["", "Base is already at Maximum Tier (3)."]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

// 2. Check if we can afford the upgrade
private _cost = _upgradeCosts select _currentTier; // index 1 for tier 2, index 2 for tier 3
if (_supplies < _cost) exitWith {
    [format["Insufficient Supplies! Need %1 for Tier %2.", _cost, _nextTier]] remoteExec ["systemChat", remoteExecutedOwner];
};

// 3. Process the upgrade
_supplies = _supplies - _cost;
missionNamespace setVariable ["KPIN_Supplies", _supplies, true];
missionNamespace setVariable ["KPIN_CurrentTier", _nextTier, true];

// 4. Persistence & Global Announcement
if (!isNil "KPIN_fnc_requestDelayedSave") then { [] call KPIN_fnc_requestDelayedSave; };

[
    "TaskSucceeded", 
    ["", format["Base Upgraded to Tier %1! New assets unlocked.", _nextTier]]
] remoteExec ["BIS_fnc_showNotification", allPlayers];

// 5. Refresh UI for everyone looking at the Command Map
if (!isNil "KPIN_fnc_updateBuyCategory") then { 
    [] remoteExec ["KPIN_fnc_updateBuyCategory", allPlayers]; 
};

diag_log format ["[KPIN] Economy: Base upgraded to Tier %1. Cost: %2 supplies.", _nextTier, _cost];
