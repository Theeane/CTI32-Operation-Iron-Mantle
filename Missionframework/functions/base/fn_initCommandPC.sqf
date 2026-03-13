/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Initializes the Command Terminal (PC). Adds access to the Buy Menu, Logistics, and Operations.
    Language: English
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {
    diag_log "[KPIN Error] initCommandPC called with null object.";
};

// 1. ACCESS BUY MENU (Purchase Units & Vehicles)
_laptop addAction [
    "<t color='#00FF00'>[ ACCESS BUY MENU ]</t>", 
    {
        [] spawn KPIN_fnc_openBuyMenu;
    },
    nil, 6, true, true, "", "true", 5
];

// 2. LOGISTICS MAP (FOB & Base Management)
_laptop addAction [
    "<t color='#FFFF00'>[ LOGISTICS MAP ]</t>", 
    {
        [_this select 0] spawn KPIN_fnc_openCommandMap;
    },
    nil, 5, true, true, "", "true", 5
];

// 3. OPERATIONS MAP (War Room / Grand Strategy)
_laptop addAction [
    "<t color='#FF0000'>[ OPERATIONS MAP ]</t>", 
    {
        [_this select 0] spawn KPIN_fnc_openOpsMap;
    },
    nil, 4, true, true, "", "true", 5
];

// Mark the object as a Command PC for other systems
_laptop setVariable ["KPIN_isCommandPC", true, true];

diag_log "[KPIN] Command PC Initialized with Buy Menu and Strategic Maps.";
