/*
    Author: Theane / ChatGPT
    Function: fn_wipeSave
    Project: Military War Framework

    Description:
    Handles wipe save for the persistence system.
*/

if (!isServer) exitWith {};

// Define all keys used in persistence to ensure a total wipe
private _keys = [
    "MWF_Save_Zones",
    "MWF_Save_Completion",      // Added to reset the Tier-lock logic
    "MWF_Save_Supplies",
    "MWF_Save_Intel",
    "MWF_Save_CivRep",
    "MWF_Save_RepPenalties",
    "MWF_Save_DestroyedHQs",
    "MWF_Save_DestroyedRoadblocks",
    "MWF_Save_FixedInfra",
    "MWF_Save_BuildingMode",
    "MWF_Save_FOBs",
    "MWF_Save_Tier",
    "MWF_Save_Missions"
];

// Set all keys to nil to wipe them from profileNamespace
{
    profileNamespace setVariable [_x, nil];
} forEach _keys;

// Commit the changes to the profile file
saveProfileNamespace;

diag_log "[KPIN PERSISTENCE]: All campaign data has been wiped. A fresh start is ready.";

// Notify players that a restart is required for the changes to take effect
["Campaign data reset. Please restart the mission for a clean slate.", "systemChat"] remoteExec ["bis_fnc_guiMessage", 0];
