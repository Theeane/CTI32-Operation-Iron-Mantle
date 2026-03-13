/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_initCommandPC
    Description: Initializes the Command Terminal. Disables strategic functions 
                 during attacks, except for Intel hand-ins.
    Language: English
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {
    diag_log "[KPIN ERROR]: initCommandPC called with null object.";
};

// Condition to check if the terminal is at the MOB (Safe Zone) 
// or if it's a FOB and currently safe (no enemies within 100m)
private _conditionSafe = "
    private _isMOB = _target getVariable ['KPIN_isMOB', false];
    private _isSafe = (count (_target nearEntities [['Man', 'Car', 'Tank'], 100] select {side _x == east || side _x == independent})) == 0;
    _isMOB || _isSafe
";

// 1. ACCESS BUY MENU (Purchase Units & Vehicles)
_laptop addAction [
    "<t color='#00FF00'>[ ACCESS BUY MENU ]</t>", 
    {
        [] spawn KPIN_fnc_openBuyMenu;
    },
    nil, 6, true, true, "", _conditionSafe, 5
];

// 2. LOGISTICS MAP (FOB & Base Management)
_laptop addAction [
    "<t color='#FFFF00'>[ LOGISTICS MAP ]</t>", 
    {
        [_this select 0] spawn KPIN_fnc_openLogisticsMap;
    },
    nil, 5, true, true, "", _conditionSafe, 5
];

// 3. OPERATIONS MAP (War Room / Grand Strategy)
_laptop addAction [
    "<t color='#FF0000'>[ OPERATIONS MAP ]</t>", 
    {
        [_this select 0] spawn KPIN_fnc_openOpsMap;
    },
    nil, 4, true, true, "", _conditionSafe, 5
];

// 4. INTEL HAND-IN (Always available, even under attack)
_laptop addAction [
    "<t color='#00FFFF'>[ DEPOSIT INTEL ]</t>", 
    {
        [] call KPIN_fnc_depositCarriedIntel;
    },
    nil, 10, true, true, "", "true", 5
];

// 5. PERSISTENCE (Manual Save Option for Admins)
_laptop addAction [
    "<t color='#AAAAAA'>[ FORCE WORLD SAVE ]</t>", 
    {
        ["Manual Terminal Save"] remoteExec ["KPIN_fnc_saveGame", 2];
        hint "World State Saved to Profile.";
    },
    nil, 1, true, true, "", "serverCommandAvailable '#kick'", 5
];

_laptop setVariable ["KPIN_isCommandPC", true, true];

diag_log "[KPIN] Logistics: Command PC Initialized. Proximity safety checks active for FOBs.";
