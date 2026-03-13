/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Initializes the Command Laptop. Handles Menu, Upgrades, and Lockdown.
    Language: English
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {};

// --- 1. INITIAL SETUP ---
_laptop allowDamage false; // Laptop is invulnerable until the defense logic triggers damage

// --- 2. COMMAND MENU (Buy Menu / Logistics) ---
// Condition: Only available when the base is NOT under attack
private _condPeace = "!(missionNamespace getVariable ['KPIN_isUnderAttack', false])";

_laptop addAction [
    "<t color='#00FF00'>[ ACCESS COMMAND NETWORK ]</t>", 
    {
        params ["_target", "_caller"];
        // Opens the UI for buying vehicles, upgrades, and managing the base
        [_target, _caller] spawn KPIN_fnc_openBuyMenu; 
    },
    nil, 6, true, true, "", _condPeace
];

// --- 3. INTEL UPLOAD ---
// Transfers Temp Intel (Digital Currency) from player to HQ Bank
private _condIntel = "(player getVariable ['KPIN_carriedIntelValue', 0]) > 0";

_laptop addAction [
    "<t color='#00FFFF'>[ UPLOAD SECURED INTEL ]</t>", 
    {
        params ["_target", "_caller"];
        // Process the deposit and clear player's temp intel
        [_target, _caller] call KPIN_fnc_depositIntel;
    },
    nil, 10, true, true, "", _condIntel
];

// --- 4. TIER UPGRADE (Direct Access) ---
// Condition: Only shows if the base can be upgraded (handled inside the function)
_laptop addAction [
    "<t color='#FFFF00'>[ UPGRADE BASE TIER ]</t>", 
    {
        params ["_target", "_caller"];
        [_target, _caller] call KPIN_fnc_upgradeBaseTier;
    },
    nil, 5, true, true, "", _condPeace
];

// --- 5. LOCKDOWN NOTIFICATION ---
// Visual feedback when the system is disabled due to combat
private _condAttack = "missionNamespace getVariable ['KPIN_isUnderAttack', false]";

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
