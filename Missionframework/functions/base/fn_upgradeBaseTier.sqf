/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Handles Base Tier progression using Digital Currency (S).
    Language: English
*/

if (!isServer) exitWith {};

private _currentTier = missionNamespace getVariable ["KPIN_CurrentTier", 1];
private _currency = missionNamespace getVariable ["KPIN_Currency", 0]; // Ändrat till Currency (S)

// Tier costs (Digital Currency S)
private _upgradeCosts = [0, 1500, 3500]; 
private _nextTier = _currentTier + 1;

// 1. Check if max level
if (_currentTier >= 3) exitWith {
    ["TaskFailed", ["", "Base is already at Maximum Tier (3)."]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

// 2. Check affordability
private _cost = _upgradeCosts select _currentTier;
if (_currency < _cost) exitWith {
    [format["Insufficient S-Currency! Need %1 for Tier %2.", _cost, _nextTier]] remoteExec ["systemChat", remoteExecutedOwner];
};

// 3. Process upgrade
_currency = _currency - _cost;
missionNamespace setVariable ["KPIN_Currency", _currency, true];
missionNamespace setVariable ["KPIN_CurrentTier", _nextTier, true];

// 4. Persistence & Global Announcement
if (!isNil "KPIN_fnc_requestDelayedSave") then { [] call KPIN_fnc_requestDelayedSave; };

[
    "TaskSucceeded", 
    ["", format["Base Upgraded to Tier %1! New assets unlocked.", _nextTier]]
] remoteExec ["BIS_fnc_showNotification", allPlayers];

// 5. Unlock Tier-specific Mobile Assets automatically?
// Om vi vill att Tier 3 ska låsa upp vissa fordon direkt:
if (_nextTier == 3) then {
    // Här kan vi sätta flaggor för t.ex. tyngre fordon om de inte köps separat
};

// 6. Refresh UI
if (!isNil "KPIN_fnc_updateBuyCategory") then { 
    [] remoteExec ["KPIN_fnc_updateBuyCategory", allPlayers]; 
};

diag_log format ["[KPIN] Economy: Base upgraded to Tier %1. Cost: %2 S.", _nextTier, _cost];
