/*
    Author: Theane using gemini
    Function: KPIN_fnc_civRep
    Description: 
    Core reputation engine. Calculates civilian relations, tracks the permanent 
    hostility penalty counter, and manages the cost of reputation resets.
*/

if (!isServer) exitWith {};

params [
    ["_mode", "ADJUST"], 
    ["_amount", 0]
];

// --- MODE: ADJUST ---
// Modifies the current reputation and checks for the permanent penalty threshold
if (_mode == "ADJUST") exitWith {
    private _oldRep = missionNamespace getVariable ["KPIN_CivRep", 0];
    private _newRep = (_oldRep + _amount) min 100 max -100;

    missionNamespace setVariable ["KPIN_CivRep", _newRep, true];

    // Penalty logic: If reputation drops to -25 or lower for the first time in a drop
    if (_newRep <= -25 && _oldRep > -25) then {
        private _penalties = missionNamespace getVariable ["KPIN_RepPenaltyCount", 0];
        missionNamespace setVariable ["KPIN_RepPenaltyCount", _penalties + 1, true];
        
        diag_log format ["[KPIN REP]: Penalty threshold reached. Total Penalties: %1", _penalties + 1];
        
        // Save immediately when penalty count increases
        ["SAVE"] call KPIN_fnc_saveManager;
    };

    // Save on significant changes to ensure state persistence
    if (abs(_amount) >= 5) then {
        ["SAVE"] call KPIN_fnc_saveManager;
    };

    diag_log format ["[KPIN REP]: Adjusted by %1. Current: %2", _amount, _newRep];
};

// --- MODE: GET_BRIBE_COST ---
// Returns the current price for a peace offering: $100 + ($10 * Penalties)
if (_mode == "GET_BRIBE_COST") exitWith {
    private _penalties = missionNamespace getVariable ["KPIN_RepPenaltyCount", 0];
    private _baseCost = 100;
    private _totalCost = _baseCost + (_penalties * 10);
    
    _totalCost
};

// --- MODE: RESET ---
// Resets reputation to neutral and triggers the 10-second Clean Slate logic
if (_mode == "RESET") exitWith {
    missionNamespace setVariable ["KPIN_CivRep", 0, true];
    
    // Trigger the 10-second Void through the Rebel Manager
    ["REFRESH_ZONES"] spawn KPIN_fnc_rebelManager; 
    
    ["SAVE"] call KPIN_fnc_saveManager;
    diag_log "[KPIN REP]: Reputation reset to 0. Peace has been bought.";
};
