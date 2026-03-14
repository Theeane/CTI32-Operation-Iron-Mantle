/*
    Author: Theane / ChatGPT
    Function: fn_setupFOBInteractions
    Project: Military War Framework

    Description:
    Handles setup f o b interactions for the core framework layer.
*/

params ["_terminal"];

// 1. Open Base Architect (Zeus Mode - Free building for decor/walls)
_terminal addAction [
    "<t color='#00bbff' size='1.2'>[ FOB ] Open Base Architect</t>", 
    {
        [] spawn MWF_fnc_openBaseArchitect;
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
        [] spawn MWF_fnc_openBuildMenu; 
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
        private _supplies = missionNamespace getVariable ["MWF_res_supplies", 0];
        hint format ["Current FOB Logistics:\nSupplies: %1", _supplies];
    },
    [],
    1, 
    false, 
    true, 
    "", 
    "_this distance _target < 3"
];
