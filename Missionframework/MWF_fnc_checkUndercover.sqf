/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_checkUndercover
    Project: Military War Framework

    Description:
    Checks if a player's uniform is blacklisted for undercover operations.
    Disables respawn loadout saving if detected.
*/

params ["_player"];

// Get player's uniform
private _uniform = uniform _player;

// Check blacklist
if (_uniform in MWF_Undercover_Blacklist) then {

    // Disable Save Respawn Loadout
    MWF_SaveLoadout_Enabled = false;
    hintSilent "Undercover status: Loadout save is locked due to uniform!";

} else {

    // Enable Save Respawn Loadout
    MWF_SaveLoadout_Enabled = true;

};