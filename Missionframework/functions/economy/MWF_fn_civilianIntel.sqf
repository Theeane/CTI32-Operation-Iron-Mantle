/*
    Author: Theane / ChatGPT
    Function: fn_civilianIntel
    Project: Military War Framework

    Description:
    Handles civilian intel for the economy system.
*/

params ["_civ"];

// 1. Basic checks
if (isNull _civ || !alive _civ) exitWith {};

// Check if the civilian has already been questioned or if they are in a "panicked" state
if (_civ getVariable ["MWF_isQuestioned", false]) exitWith {
    ["TaskFailed", ["", "This person has nothing more to say."]] call BIS_fnc_showNotification;
};

// 2. Play interaction animation
player playAction "GestureHi"; // A simple wave or greeting
sleep 2;

// 3. Calculate chance based on team's current Intel reserves
private _currentIntel = missionNamespace getVariable ["MWF_CurrentIntel", 0];
private _findChance = [_currentIntel] call MWF_Economy_fnc_getIntelChance;

// 4. Roll the dice for "Informant Status"
if ((random 100) <= _findChance) then {
    // Success - This civilian is an informant
    private _intelGained = MWF_Economy_Intel_CivilianTalk;
    
    MWF_CurrentIntel = MWF_CurrentIntel + _intelGained;
    publicVariable "MWF_CurrentIntel";
    
    ["TaskSucceeded", ["", format["The civilian shared local intel! (+%1 Intel)", _intelGained]]] call BIS_fnc_showNotification;
    
    // Mark as questioned so they can't be spammed
    _civ setVariable ["MWF_isQuestioned", true, true];
} else {
    // Failure - Just a regular citizen
    private _refusalMessages = [
        "I don't know anything about the enemy.",
        "Please, I just want to be left alone.",
        "I have work to do, go away.",
        "I haven't seen any soldiers around here."
    ];
    
    // Display a random refusal message in the chat
    _civ sideChat (selectRandom _refusalMessages);
    
    // Mark as questioned even on failure to simulate "the well has run dry" in this area
    _civ setVariable ["MWF_isQuestioned", true, true];
};
