/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Initializes the Command Laptop. Handles Menu, Upgrades, and Lockdown.
    Language: English
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {};

// --- 1. INITIAL SETUP ---
_laptop allowDamage false; // Osårbar tills attack-scriptet slår om den

// --- 2. COMMAND MENU (The main interaction) ---
// Condition: Endast tillgänglig när basen INTE är under attack
private _condPeace = "!(missionNamespace getVariable ['KPIN_isUnderAttack', false])";

_laptop addAction [
    "<t color='#00FF00'>[ ACCESS COMMAND NETWORK ]</t>", 
    {
        // Här öppnar vi din huvudmeny (t.ex. fn_openBuyMenu.sqf eller Mission Menu)
        params ["_target", "_caller"];
        [_target, _caller] spawn KPIN_fnc_openBuyMenu; 
    },
    nil, 6, true, true, "", _condPeace
];

// --- 3. INTEL UPLOAD (Always available) ---
// Condition: Spelaren bär på Intel (Digital Currency/Temp Intel)
private _condIntel = "player getVariable ['KPIN_carryingIntel', false]";

_laptop addAction [
    "<t color='#00FFFF'>[ UPLOAD SECURED INTEL ]</t>", 
    {
        params ["_target", "_caller"];
        [_caller] call KPIN_fnc_depositIntel; // Hanterar digital valuta-överföring
        hint "Intel upload complete. Digital currency added to HQ.";
    },
    nil, 10, true, true, "", _condIntel
];

// --- 4. LOCKDOWN NOTIFICATION ---
// Condition: Visas bara när basen ÄR under attack
private _condAttack = "missionNamespace getVariable ['KPIN_isUnderAttack', false]";

_laptop addAction [
    "<t color='#FF0000'>[ SYSTEM LOCKDOWN - UNDER ATTACK ]</t>", 
    {
        hint "Critical error: Command functions disabled during active engagement. Defend the perimeter!";
    },
    nil, 6, true, true, "", _condAttack
];

// --- 5. VISUALS ---
// Kan lägga till en liten ljuskälla eller skärm-textur här om vi vill senare.
diag_log "[KPIN] Command PC Initialized.";
