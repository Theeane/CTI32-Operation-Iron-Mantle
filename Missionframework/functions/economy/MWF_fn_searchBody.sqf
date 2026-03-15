/*
    Author: Theane / ChatGPT
    Function: fn_searchBody
    Project: Military War Framework

    Description:
    Handles search body for the economy system.
*/

params ["_body"];

// 1. Basic checks
if (isNull _body) exitWith {};
if (_body getVariable ["MWF_isSearched", false]) exitWith {
    ["TaskFailed", ["", "This body has already been searched."]] call BIS_fnc_showNotification;
};

// 2. Mark as searched immediately to prevent spam
_body setVariable ["MWF_isSearched", true, true];

// 3. Play animation for the player
player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

// 4. Calculate find chance using our new economy function
private _currentIntel = missionNamespace getVariable ["MWF_CurrentIntel", 0];
private _findChance = [_currentIntel] call MWF_Economy_fnc_getIntelChance;

// 5. Roll the dice
if ((random 100) <= _findChance) then {
    // Success! Get value from our economy settings
    private _intelGained = MWF_Economy_Intel_EnemySoldier;
    
    // Update global intel (must be done on server or via publicVariable)
    MWF_CurrentIntel = MWF_CurrentIntel + _intelGained;
    publicVariable "MWF_CurrentIntel";
    
    ["TaskSucceeded", ["", format["Found intel documents! (+%1 Intel)", _intelGained]]] call BIS_fnc_showNotification;
    
    // Log for debug
    diag_log format ["[Iron Mantle] Intel found on body. Current total: %1", MWF_CurrentIntel];
} else {
    // Failure
    ["TaskFailed", ["", "No valuable intel found."]] call BIS_fnc_showNotification;
};
