/*
    Author: OpenAI / ChatGPT
    Function: fn_getEffectiveEnemyTier
    Project: Military War Framework

    Description:
    Resolves the enemy-content tier after applying the persistent world-tier multiplier.
    This affects OPFOR and rebel content selection only. It does not modify BLUFOR systems
    and does not alter world-tier progression itself.
*/

params [
    ["_baseTier", missionNamespace getVariable ["MWF_WorldTier", 1], [0]]
];

private _resolvedBase = (_baseTier max 1) min 5;
private _multiplier = missionNamespace getVariable ["MWF_WorldTierMultiplier", 1];
private _effective = round (_resolvedBase * (_multiplier max 0.1));
(_effective max 1) min 5
