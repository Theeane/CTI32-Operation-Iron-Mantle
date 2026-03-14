
// Author: Theane / ChatGPT
// Project: Mission War Framework

MWF_fnc_checkUndercover = {
    private["_player", "_uniform"];
    
    _player = _this select 0; // The player object
    _uniform = uniform _player; // Get the uniform of the player
    
    if (_uniform in MWF_Undercover_Blacklist) then {
        // Disable "Save Respawn Loadout" if uniform is on blacklist
        MWF_SaveLoadout_Enabled = false;
        hintSilent "Undercover status: Loadout save is locked due to uniform!";
    } else {
        // Allow "Save Respawn Loadout"
        MWF_SaveLoadout_Enabled = true;
    };
};
