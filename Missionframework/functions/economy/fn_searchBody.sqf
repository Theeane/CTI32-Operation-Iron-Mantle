/*
    Author: Theeane
    Function: CTI_fnc_searchBody
    Description: 
    Logic for searching a deceased enemy to find intel.
    Uses scaling probability based on current total intel.
*/

params ["_body"];

// 1. Basic checks
if (isNull _body) exitWith {};
if (_body getVariable ["GVAR_isSearched", false]) exitWith {
    ["TaskFailed", ["", "This body has already been searched."]] call BIS_fnc_showNotification;
};

// 2. Mark as searched immediately to prevent spam
_body setVariable ["GVAR_isSearched", true, true];

// 3. Play animation for the player
player playMove "AinvPknlMstpSnonWnonDnon_medic_1";
sleep 4;

// 4. Calculate find chance using our new economy function
private _currentIntel = missionNamespace getVariable ["GVAR_CurrentIntel", 0];
private _findChance = [_currentIntel] call GVAR_Economy_fnc_getIntelChance;

// 5. Roll the dice
if ((random 100) <= _findChance) then {
    // Success! Get value from our economy settings
    private _intelGained = GVAR_Economy_Intel_EnemySoldier;
    
    // Update global intel (must be done on server or via publicVariable)
    GVAR_CurrentIntel = GVAR_CurrentIntel + _intelGained;
    publicVariable "GVAR_CurrentIntel";
    
    ["TaskSucceeded", ["", format["Found intel documents! (+%1 Intel)", _intelGained]]] call BIS_fnc_showNotification;
    
    // Log for debug
    diag_log format ["[Iron Mantle] Intel found on body. Current total: %1", GVAR_CurrentIntel];
} else {
    // Failure
    ["TaskFailed", ["", "No valuable intel found."]] call BIS_fnc_showNotification;
};
