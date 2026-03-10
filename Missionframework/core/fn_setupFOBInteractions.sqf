/*
    Author: Theane (AGS Project)
    Description: Adds Build and Architect actions to the FOB HQ terminal.
    Language: English
*/

params ["_terminal"];

// 1. Open Base Architect (Zeus Mode - Free building for decor/walls)
_terminal addAction [
    "<t color='#00bbff' size='1.2'>[ FOB ] Open Base Architect</t>", 
    {
        [] spawn AGS_fnc_openBaseArchitect;
    },
    [],
    10, 
    true, 
    true, 
    "", 
    "_this distance _target < 3"
];

// 2. Open Logistics Menu (Ghost Mode - Vehicles/Crates that cost Supplies)
_terminal addAction [
    "<t color='#00ff00' size='1.2'>[ FOB ] Open Logistics Menu</t>", 
    {
        // Placeholder for the Menu UI we are building
        [] spawn AGS_fnc_openBuildMenu; 
    },
    [],
    9, 
    true, 
    true, 
    "", 
    "_this distance _target < 3"
];

// 3. Status Check (Optional)
_terminal addAction [
    "<t color='#ffffff'>Check Resource Levels</t>", 
    {
        private _supplies = missionNamespace getVariable ["AGS_res_supplies", 0];
        hint format ["Current FOB Logistics:\nSupplies: %1", _supplies];
    },
    [],
    1, 
    false, 
    true, 
    "", 
    "_this distance _target < 3"
];
