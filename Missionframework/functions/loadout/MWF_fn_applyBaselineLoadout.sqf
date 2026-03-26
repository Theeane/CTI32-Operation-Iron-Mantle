/*
    Author: ChatGPT
    Function: MWF_fnc_applyBaselineLoadout
    Project: Military War Framework

    Description:
    First-spawn fallback. Strips the player to uniform-only when no saved respawn
    loadout exists yet. A later saved respawn package will override this automatically.
*/

if (!hasInterface) exitWith { false };
if (!alive player) exitWith { false };
if (missionNamespace getVariable ["MWF_BaselineLoadoutApplied", false]) exitWith { false };

private _payload = missionNamespace getVariable ["MWF_SavedRespawnProfile", profileNamespace getVariable ["MWF_SavedRespawnProfile", []]];
if (_payload isEqualType [] && {count _payload >= 4}) exitWith { false };

private _uniformClass = uniform player;
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;
removeUniform player;
if (_uniformClass isNotEqualTo "") then {
    player forceAddUniform _uniformClass;
};

missionNamespace setVariable ["MWF_BaselineLoadoutApplied", true];
true
