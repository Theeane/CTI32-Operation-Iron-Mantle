/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Deposits carried digital currency (Temp Intel) into the HQ Bank (S).
    Language: English
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (isNull _caller) exitWith {};

// 1. Retrieve the player's Temp Intel (The +X value shown in the HUD)
private _tempIntel = _caller getVariable ["KPIN_carriedIntelValue", 0];

// 2. Safety Check: Does the player have anything to upload?
if (_tempIntel <= 0) exitWith {
    ["TaskFailed", ["", "No digital data detected for upload."]] remoteExec ["BIS_fnc_showNotification", _caller];
};

// 3. Update the global HQ Bank (S-Currency)
private _currentBank = missionNamespace getVariable ["KPIN_Currency", 0];
private _newTotal = _currentBank + _tempIntel;

missionNamespace setVariable ["KPIN_Currency", _newTotal, true];

// 4. Reset player's Temp Intel (This triggers the 10s HUD fade automatically)
_caller setVariable ["KPIN_carriedIntelValue", 0, true];
_caller setVariable ["KPIN_carryingIntel", false, true];

// 5. Visual Feedback
[
    "TaskSucceeded", 
    ["", format["Data Secured: +%1 S added to HQ Bank.", _tempIntel]]
] remoteExec ["BIS_fnc_showNotification", _caller];

// 6. Persistence (Triggers a delayed save for the economy)
if (!isNil "KPIN_fnc_requestDelayedSave") then { [] call KPIN_fnc_requestDelayedSave; };

diag_log format ["[KPIN] Economy: %1 deposited %2 S. New HQ Balance: %3 S.", name _caller, _tempIntel, _newTotal];
