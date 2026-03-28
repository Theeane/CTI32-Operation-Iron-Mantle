/*
    Author: Theeane / Gemini
    Function: MWF_fnc_applyBaselineLoadout
    Project: Military War Framework

    Description:
    Strips the player to a baseline state upon joining. 
    Keeps essential navigation tools (Map, Compass, Watch, Radio) but removes 
    all weapons, vests, backpacks, and other items.
*/

params [
    ["_force", false, [false]]
];

if (!hasInterface) exitWith { false };
if (!alive player) exitWith { false };
if (!_force && {missionNamespace getVariable ["MWF_BaselineLoadoutApplied", false]}) exitWith { false };

// 1. Save navigation tools and uniform class
private _essentials = ["ItemMap", "ItemCompass", "ItemWatch", "ItemRadio"];
private _itemsToKeep = assignedItems player select { _x in _essentials };
private _uniformClass = uniform player;

// 2. Full equipment strip
removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;
removeUniform player;

// 3. Restore navigation tools immediately
{
    player linkItem _x;
} forEach _itemsToKeep;

// 4. Re-apply uniform
if (_uniformClass isNotEqualTo "") then {
    player forceAddUniform _uniformClass;
};

// Mark baseline as applied to prevent loops upon rejoin
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", true];

diag_log "[MWF] Baseline loadout applied: Navigation tools preserved, equipment stripped.";
true
