/*
    Author: Theane / ChatGPT
    Function: fn_undercoverTalk
    Project: Military War Framework

    Description:
    Handles undercover talk for the economy system.
*/

params ["_enemy"];

// 1. Basic checks
if (isNull _enemy || !alive _enemy) exitWith {};

// 2. Play interaction
player playAction "GestureHi";
sleep 2;

// 3. Success chance (using our scaling intel logic)
private _currentIntel = missionNamespace getVariable ["MWF_CurrentIntel", 0];
private _successChance = [_currentIntel] call MWF_Economy_fnc_getIntelChance;

if (random 100 < _successChance) then {
    // SUCCESS: The soldier "leaks" information
    private _bonusType = selectRandom ["Patrol", "Supply", "General"];
    
    switch (_bonusType) do {
        case "Patrol": {
            _enemy sideChat "Don't go north, the boys are out on a heavy patrol there.";
            // Logic to reveal a nearby group
            [50] spawn MWF_fnc_buyIntel; // We trigger a free "reveal"
        };
        case "Supply": {
            _enemy sideChat "The supply truck is late again, probably stuck at the checkpoint.";
            // Could mark a random supply objective on map
        };
        case "General": {
            _enemy sideChat "I heard the commander is bringing in the heavy armor tomorrow.";
            [MWF_Economy_Intel_CivilianTalk * 2] call MWF_fnc_addIntel; // Double points
        };
    };
    
    _enemy setVariable ["MWF_isQuestioned", true, true];
    ["TaskSucceeded", ["", "Undercover Bonus: Enemy leaked information!"]] call BIS_fnc_showNotification;

} else {
    // FAILURE: Compromised
    _enemy sideChat "Hey! You're that saboteur they warned us about!";
    
    player setVariable ["MWF_isUndercover", false, true];
    player setCaptive false; // Enemies start shooting
    
    ["TaskFailed", ["", "Undercover compromised! Prepare for combat!"]] call BIS_fnc_showNotification;
};
