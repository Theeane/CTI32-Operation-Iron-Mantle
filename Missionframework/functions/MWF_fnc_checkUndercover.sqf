/*
    Author: Theeane / Gemini Guide
    Function: MWF_fnc_checkUndercover
    Project: Military War Framework
    Description: 
    Checks if a player is wearing a blacklisted uniform (military gear).
    If undercover, certain restrictions like loadout saving are toggled.
*/

params [
    ["_player", objNull, [objNull]]
];

if (isNull _player) exitWith { false };

// 1. Get current uniform
private _currentUniform = uniform _player;

// 2. Fetch blacklist (safely fallback to empty array if not defined)
private _blacklist = missionNamespace getVariable ["MWF_Undercover_Blacklist", []];

// 3. Determine status
private _isDetected = (_currentUniform in _blacklist);
private _saveEnabled = true;

if (_isDetected) then {
    // Player is wearing military gear - Not Undercover
    _saveEnabled = false;
    
    // Optional: Notify player if they just changed into military gear
    if (hasInterface && {player == _player}) then {
        // hintSilent "Undercover status: Lost (Military uniform detected)";
    };
} else {
    // Player is wearing civilian gear - Undercover
    _saveEnabled = true;
};

// 4. Update and Broadcast status
// We use a broadcasted variable so the server/other systems know the player's status
_player setVariable ["MWF_isUndercover", !_isDetected, true];

// Handle Loadout Save restriction (Project specific rule)
missionNamespace setVariable ["MWF_SaveLoadout_Enabled", _saveEnabled, true];

diag_log format ["[MWF] Undercover Check: %1 (Uniform: %2) - Undercover: %3", name _player, _currentUniform, !_isDetected];

!_isDetected