/*
    Author: Theane / ChatGPT
    Function: fn_initCommandPC
    Project: Military War Framework

    Description:
    Handles init command p c for the base system.
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {};

// --- 1. INITIAL SETUP ---
_laptop allowDamage false; // Laptop is invulnerable until the defense logic triggers damage

// --- 2. COMMAND MENU (Buy Menu / Logistics) ---
// Condition: Only available when the base is NOT under attack
private _condPeace = "!(missionNamespace getVariable ['MWF_isUnderAttack', false])";

_laptop addAction [
    "<t color='#00FF00'>[ ACCESS COMMAND NETWORK ]</t>", 
    {
        params ["_target", "_caller"];
        // Opens the UI for buying vehicles, upgrades, and managing the base
        [_target, _caller] spawn MWF_fnc_openBuyMenu; 
    },
    nil, 6, true, true, "", _condPeace
];

// --- 3. INTEL UPLOAD ---
// Transfers Temp Intel (Digital Currency) from player to HQ Bank
private _condIntel = "(player getVariable ['MWF_carriedIntelValue', 0]) > 0";

_laptop addAction [
    "<t color='#00FFFF'>[ UPLOAD SECURED INTEL ]</t>", 
    {
        params ["_target", "_caller"];
        // Process the deposit and clear player's temp intel
        [_target, _caller] call MWF_fnc_depositIntel;
    },
    nil, 10, true, true, "", _condIntel
];

// --- 4. TIER UPGRADE (Direct Access) ---
// Condition: Only shows if the base can be upgraded (handled inside the function)
_laptop addAction [
    "<t color='#FFFF00'>[ UPGRADE BASE TIER ]</t>", 
    {
        params ["_target", "_caller"];
        [_target, _caller] call MWF_fnc_upgradeBaseTier;
    },
    nil, 5, true, true, "", _condPeace
];

// --- 5. LOCKDOWN NOTIFICATION ---
// Visual feedback when the system is disabled due to combat
private _condAttack = "missionNamespace getVariable ['MWF_isUnderAttack', false]";

_laptop addAction [
    "<t color='#FF0000'>[ SYSTEM LOCKDOWN - UNDER ATTACK ]</t>", 
    {
        hint "Critical Error: Command functions disabled during active engagement. Defend the perimeter!";
    },
    nil, 6, true, true, "", _condAttack, 5
];

// --- 6. VISUALS & LOGGING ---
_laptop setObjectTextureGlobal [0, "A3\Structures_F\Items\Electronics\Data\Laptops_01_screen_CO.paa"];
diag_log "[KPIN] Command PC Initialized.";


// --- 7. FOB REPACK CONTROL ---
_laptop addAction [
    "<t color='#ffaa00'>[ AUTHORIZE FOB REPACK ]</t>",
    {
        params ["_target", "_caller"];
        [_target, true] remoteExec ["MWF_fnc_commanderToggleRepack", 2];
    },
    nil, 4, true, true, "", "!(_target getVariable ['MWF_FOB_CanRepack', false])"
];

_laptop addAction [
    "<t color='#ff6600'>[ LOCK FOB REPACK ]</t>",
    {
        params ["_target", "_caller"];
        [_target, false] remoteExec ["MWF_fnc_commanderToggleRepack", 2];
    },
    nil, 4, true, true, "", "_target getVariable ['MWF_FOB_CanRepack', false]"
];

[_laptop] call MWF_fnc_packFOB;
