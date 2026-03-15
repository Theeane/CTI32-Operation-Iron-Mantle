/*
    Author: Theane / ChatGPT / Gemini
    Function: MWF_fnc_initiatePurchase.sqf
    Project: Military War Framework
    Description: Handles digital currency transactions for Supply and Intel.
*/

params [
    ["_cost", 0, [0]], 
    ["_currencyType", "Supply", [""]]
];

private _success = false;

// 1. Transaction Logic
if (_currencyType == "Supply") then {
    if (MWF_Supply >= _cost) then {
        MWF_Supply = MWF_Supply - _cost;
        publicVariable "MWF_Supply";
        _success = true;
    };
} else {
    if (MWF_Intel >= _cost) then {
        MWF_Intel = MWF_Intel - _cost;
        publicVariable "MWF_Intel";
        _success = true;
    };
};

// 2. Logging and Feedback
if (_success) then {
    diag_log format ["[MWF] SUCCESS: Purchased for %1 %2. Transaction complete.", _cost, _currencyType];
} else {
    private _current = if (_currencyType == "Supply") then {MWF_Supply} else {MWF_Intel};
    diag_log format ["[MWF] ERROR: Insufficient funds. Need %1 %2, have %3.", _cost, _currencyType, _current];
};

// 3. Return status
_success
