/*
    Author: Theane using Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_wipeSave
    Description: Clears all persistent data related to the campaign.
    Language: English
*/

if (!isServer) exitWith {};

// Define all keys used in persistence
private _keys = [
    "KPIN_Save_Zones",
    "KPIN_Save_Supplies",
    "KPIN_Save_Intel",
    "KPIN_Save_CivRep",
    "KPIN_Save_RepPenalties",
    "KPIN_Save_DestroyedHQs",
    "KPIN_Save_DestroyedRoadblocks",
    "KPIN_Save_FixedInfra",
    "KPIN_Save_BuildingMode",
    "KPIN_Save_FOBs",
    "KPIN_Save_Tier",
    "KPIN_Save_Missions"
];

// Set all keys to nil to wipe them from profileNamespace
{
    profileNamespace setVariable [_x, nil];
} forEach _keys;

saveProfileNamespace;

diag_log "[KPIN PERSISTENCE]: All campaign data has been wiped. A fresh start is ready.";

// Optional: Restart the mission or notify players
// "Campaign data reset. Please restart the mission for a clean slate." remoteExec ["systemChat", 0];
