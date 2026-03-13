/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Deposits carried digital currency (Temp Intel) into the HQ Bank (S).
    Language: English
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (isNull _caller) exitWith {};

// 1. Hämta spelarens Temp Intel (Det som visas som +10 i din HUD)
private _tempIntel = _caller getVariable ["KPIN_carriedIntelValue", 0];

// 2. Säkerhetscheck: Har spelaren något att ladda upp?
if (_tempIntel <= 0) exitWith {
    ["TaskFailed", ["", "No digital data detected to upload."]] remoteExec ["BIS_fnc_showNotification", _caller];
};

// 3. Uppdatera den globala potten (HQ Bank)
// Vi använder KPIN_Currency som vi spikade för "S"
private _currentBank = missionNamespace getVariable ["KPIN_Currency", 0];
private _newTotal = _currentBank + _tempIntel;

missionNamespace setVariable ["KPIN_Currency", _newTotal, true];

// 4. Nollställ spelarens Temp Intel (Detta triggar din 10s HUD-fade automatiskt)
_caller setVariable ["KPIN_carriedIntelValue", 0, true];
_caller setVariable ["KPIN_carryingIntel", false, true];

// 5. Visuell Feedback
[
    "TaskSucceeded", 
    ["", format["Data Secured: +%1 S added to HQ Bank.", _tempIntel]]
] remoteExec ["BIS_fnc_showNotification", _caller];

// 6. Persistence (Spara ekonomin)
if (!isNil "KPIN_fnc_requestDelayedSave") then { [] call KPIN_fnc_requestDelayedSave; };

diag_log format ["[KPIN] Economy: %1 deposited %2 S. New HQ Balance: %3 S.", name _caller, _tempIntel, _newTotal];
