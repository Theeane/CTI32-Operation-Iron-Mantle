/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_clearRespawnLoadoutProfile
    Project: Military War Framework

    Description:
    Clears the locally cached respawn loadout from mission/ui/profile namespace.
*/

if (!hasInterface) exitWith { false };

missionNamespace setVariable ["MWF_SavedRespawnProfile", nil];
uiNamespace setVariable ["MWF_SavedRespawnProfile", nil];
profileNamespace setVariable ["MWF_SavedRespawnProfile", nil];
saveProfileNamespace;
true
