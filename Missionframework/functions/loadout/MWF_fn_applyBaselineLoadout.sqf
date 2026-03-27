/*
    Author: ChatGPT
    Function: MWF_fnc_applyBaselineLoadout
    Project: Military War Framework

    Description:
    Join-loadout baseline. Every fresh join is stripped to uniform-only, regardless of any
    saved respawn loadout. Saved respawn loadouts are only applied from onPlayerRespawn.sqf.
*/

if (!hasInterface) exitWith { false };
if (!alive player) exitWith { false };
if (missionNamespace getVariable ["MWF_BaselineLoadoutApplied", false]) exitWith { false };

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
