/*
    Author: Theane (AGS Project)
    Description: Adds specific FOB actions to the HQ terminal.
    Language: English
*/

params ["_terminal"];

// 1. Action för att öppna Base Architect (Zeus - Gratis byggande)
_terminal addAction [
    "<t color='#00bbff'>Open Base Architect</t>", 
    {
        [] spawn AGS_fnc_openBaseArchitect;
    },
    [],
    6, 
    true, 
    true, 
    "", 
    "_this distance _target < 3"
];

// 2. Action för att öppna Logistics Menu (Ghost Mode - Fordon som kostar)
_terminal addAction [
    "<t color='#00ff00'>Open Logistics Menu</t>", 
    {
        // Här kallar vi på menyn vi ska bygga (fordon/lådor)
        [] spawn AGS_fnc_openBuildMenu; 
    },
    [],
    5, 
    true, 
    true, 
    "", 
    "_this distance _target < 3"
];

// 3. Vanlig Login (om man behöver logga in på nytt)
_terminal addAction [
    "<t color='#ffffff'>Access Command Network</t>", 
    {
        hint "Network stable. Resources synced.";
    },
    [],
    1, 
    false, 
    true, 
    "", 
    "_this distance _target < 3"
];
