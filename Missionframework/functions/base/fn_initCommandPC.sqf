/* Author: Theeane
    Description: Adds terminal access to the Command PC.
*/
params ["_laptop"];

// Action for Logistics (FOBs)
_laptop addAction ["<t color='#00FF00'>Logistics Map (Base Management)</t>", {
    [_this select 0] spawn CTI_fnc_openCommandMap; // We'll call this the FOB map
}];

// Action for Grand Operations (War Room)
_laptop addAction ["<t color='#FF0000'>Operations Map (War Room)</t>", {
    [_this select 0] spawn CTI_fnc_openOpsMap;
}];
