sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

MWF_fnc_checkUndercover = {
    // Parameters: The player object to check
    params ["_player"];

    // Get the player's current uniform
    private _currentUniform = uniform _player;

    // Check if the player's uniform is in the undercover blacklist
    if (_currentUniform in MWF_Undercover_Blacklist) then {
        // Lock Save Respawn Loadout
        MWF_SaveLoadout_Enabled = false;
        hintSilent "Undercover status: Loadout save is locked due to uniform!";
    } else {
        // Allow Save Respawn Loadout
        MWF_SaveLoadout_Enabled = true;
    };

    // Broadcast the save loadout status globally
    missionNamespace setVariable ["MWF_SaveLoadout_Enabled", MWF_SaveLoadout_Enabled, true];
};
