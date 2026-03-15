/*
    Author: Theane / ChatGPT
    Function: fn_depositIntel
    Project: Military War Framework

    Description:
    Handles deposit intel for the base system.
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (isNull _caller) exitWith {};

// 1. Retrieve the player's Temp Intel (The +X value shown in the HUD)
private _tempIntel = _caller getVariable ["MWF_carriedIntelValue", 0];

// 2. Safety Check: Does the player have anything to upload?
if (_tempIntel <= 0) exitWith {
    ["TaskFailed", ["", "No digital data detected for upload."]] remoteExec ["BIS_fnc_showNotification", _caller];
};

// 3. Update the global HQ Bank (S-Currency)
private _currentBank = missionNamespace getVariable ["MWF_Currency", 0];
private _newTotal = _currentBank + _tempIntel;

missionNamespace setVariable ["MWF_Currency", _newTotal, true];

// 4. Reset player's Temp Intel (This triggers the 10s HUD fade automatically)
_caller setVariable ["MWF_carriedIntelValue", 0, true];
_caller setVariable ["MWF_carryingIntel", false, true];

// 5. Visual Feedback
[
    "TaskSucceeded", 
    ["", format["Data Secured: +%1 S added to HQ Bank.", _tempIntel]]
] remoteExec ["BIS_fnc_showNotification", _caller];

// 6. Persistence (Triggers a delayed save for the economy)
if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

diag_log format ["[KPIN] Economy: %1 deposited %2 S. New HQ Balance: %3 S.", name _caller, _tempIntel, _newTotal];
