/*
    Author: Theane using gemini
    Function: KPIN_fnc_civRep
    Description: 
    Manages the civilian reputation system, monitors hostility thresholds, 
    and calculates the escalating cost for reputation resets based on past penalties.
*/

if (!isServer) exitWith {};

params [
    ["_mode", "ADJUST"], 
    ["_amount", 0]
];

// --- MODE: ADJUST (Modify current reputation) ---
if (_mode == "ADJUST") exitWith {
    private _oldRep = missionNamespace getVariable ["KPIN_CivRep", 0];
    private _newRep = (_oldRep + _amount) min 100 max -100;

    missionNamespace setVariable ["KPIN_CivRep", _newRep, true];

    // Strict Rule: If dropping into hostility (<= -25) for the first time in this drop, add penalty
    if (_newRep <= -25 && _oldRep > -25) then {
        private _penalties = missionNamespace getVariable ["KPIN_RepPenaltyCount", 0];
        missionNamespace setVariable ["KPIN_RepPenaltyCount", _penalties + 1, true];
        
        diag_log format ["[KPIN REP]: Hostility threshold reached. Penalty Count: %1", _penalties + 1];
        
        // Instant save when penalty count increases
        ["SAVE"] call KPIN_fnc_saveManager;
    };

    // Save on any significant reputation change (abs 5 or more)
    if (abs(_amount) >= 5) then {
        ["SAVE"] call KPIN_fnc_saveManager;
    };

    diag_log format ["[KPIN REP]: Adjusted by %1. Current Reputation: %2", _amount, _newRep];
};

// --- MODE: GET_BRIBE_COST (Calculate the current price for peace) ---
if (_mode == "GET_BRIBE_COST") exitWith {
    private _penalties = missionNamespace getVariable ["KPIN_RepPenaltyCount", 0];
    private _baseCost = 100;
    private _totalCost = _baseCost + (_penalties * 10); // $100 + $10 per penalty
    
    _totalCost
};

// --- MODE: RESET (The Peace Offering logic) ---
if (_mode == "RESET") exitWith {
    missionNamespace setVariable ["KPIN_CivRep", 0, true];
    
    // Trigger the 10-second Clean Slate through the Rebel Manager
    ["REFRESH_ZONES"] spawn KPIN_fnc_rebelManager; 
    
    ["SAVE"] call KPIN_fnc_saveManager;
    diag_log "[KPIN REP]: Reputation reset to neutral via bribe.";
};
