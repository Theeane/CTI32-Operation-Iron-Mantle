/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_applyBaselineLoadout
    Project: Military War Framework

    Description:
    Strips the player down to a clean tutorial-safe baseline while preserving
    the currently worn uniform. This baseline is only used when no saved
    respawn loadout exists yet.
*/

if (!hasInterface) exitWith { false };
if (isNull player) exitWith { false };
if (!alive player) exitWith { false };

private _uniformClass = uniform player;

removeAllWeapons player;
removeAllItems player;
removeAllAssignedItems player;
removeVest player;
removeBackpack player;
removeHeadgear player;
removeGoggles player;
player removeWeapon (primaryWeapon player);
player removeWeapon (secondaryWeapon player);
player removeWeapon (handgunWeapon player);
player removeWeapon (binocular player);

if (_uniformClass isEqualTo "") then {
    private _fallbackUniform = missionNamespace getVariable ["MWF_Blufor_StarterUniform", "U_B_CombatUniform_mcam"];
    if (_fallbackUniform isNotEqualTo "") then {
        player forceAddUniform _fallbackUniform;
    };
};

true
