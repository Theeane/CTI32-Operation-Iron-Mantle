/*
    Author: Theane / ChatGPT
    Function: fn_upgradeBaseTier
    Project: Military War Framework

    Description:
    Handles upgrade base tier for the base system.
*/

if (!isServer) exitWith {};

private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _currency = missionNamespace getVariable ["MWF_Currency", 0];

// Tier upgrade costs (S-Currency)
// Tier 1 -> 2: 1500 S | Tier 2 -> 3: 3500 S
private _upgradeCosts = [0, 1500, 3500]; 
private _nextTier = _currentTier + 1;

// 1. Check if maximum Tier is already reached
if (_currentTier >= 3) exitWith {
    ["TaskFailed", ["", "Base is already at Maximum Tier (3)."]] remoteExec ["BIS_fnc_showNotification", remoteExecutedOwner];
};

// 2. Check affordability
private _cost = _upgradeCosts select _currentTier;
if (_currency < _cost) exitWith {
    private _msg = format["Insufficient Funds! Need %1 S for Tier %2 upgrade.", _cost, _nextTier];
    [_msg] remoteExec ["systemChat", remoteExecutedOwner];
};

// 3. Process the upgrade
_currency = _currency - _cost;
missionNamespace setVariable ["MWF_Currency", _currency, true];
missionNamespace setVariable ["MWF_CurrentTier", _nextTier, true];

// 4. Persistence (Trigger delayed save for the world state)
if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

// 5. Global Announcement
[
    "TaskSucceeded", 
    ["", format["Base Upgraded to Tier %1! New assets unlocked.", _nextTier]]
] remoteExec ["BIS_fnc_showNotification", -2]; // -2 sends to all clients but not the server

// 6. Optional: Unlock specific mechanics or units
if (_nextTier == 3) then {
    // Logic for Tier 3 specific unlocks (e.g. Heavy Armor, Jets) can be added here
    diag_log "[KPIN] Economy: Strategic Assets (Tier 3) are now online.";
};

// 7. Refresh UI for all players to update locked/unlocked items
if (!isNil "MWF_fnc_updateBuyCategory") then { 
    [] remoteExec ["MWF_fnc_updateBuyCategory", -2]; 
};

diag_log format ["[KPIN] Economy: Base upgraded to Tier %1 by %2. Cost: %3 S.", _nextTier, name (allPlayers select 0), _cost];
