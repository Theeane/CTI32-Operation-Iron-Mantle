/*
    Author: Theeane / Gemini
    Function: MWF_fnc_applyBaselineLoadout
    Project: Military War Framework

    Description:
    Performs a silent equipment strip during the intro sequence. 
    Removes all combat gear (weapons, vests, backpacks, headgear) while 
    preserving the player's uniform and essential navigation tools.
*/

params [
    ["_unit", player, [objNull]],
    ["_force", false, [false]]
];

if (!hasInterface) exitWith { false };
if (isNull _unit || {!alive _unit}) exitWith { false };

// Prevent repeated execution unless forced (to handle rejoin/initial start)
if (!_force && {missionNamespace getVariable ["MWF_BaselineLoadoutApplied", false]}) exitWith { false };

// 1. Identify essentials to keep
// We preserve navigation tools and the current uniform class
private _essentialTools = ["ItemMap", "ItemCompass", "ItemWatch", "ItemRadio"];
private _itemsToKeep = assignedItems _unit select { _x in _essentialTools };
private _currentUniform = uniform _unit;

// 2. Perform the silent strip
// No visual flashes (cutText) are used here to maintain the cinematic experience
removeAllWeapons _unit;
removeAllItems _unit;
removeAllAssignedItems _unit;
removeVest _unit;
removeBackpack _unit;
removeHeadgear _unit;
removeGoggles _unit;

// 3. Restore Uniform and Essential Tools
if (_currentUniform != "") then {
    // forceAddUniform is used to ensure the uniform is applied regardless of side
    _unit forceAddUniform _currentUniform;
};

{
    _unit linkItem _x;
} forEach _itemsToKeep;

// Mark baseline as applied in the missionNamespace
missionNamespace setVariable ["MWF_BaselineLoadoutApplied", true];

diag_log format ["[MWF] Baseline Loadout: %1 has been stripped to uniform and tools.", name _unit];
true