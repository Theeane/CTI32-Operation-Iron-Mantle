/*
    Author: Theane / ChatGPT
    Template: MissionSupply_2
    Category: supply
    Difficulty: hard

    Description:
    Structured official mission template with fixed per-mission rewards.
    This file must remain mod agnostic:
    - no hardcoded unit classnames
    - no hardcoded vehicle classnames
    - no hardcoded object classnames
    - runtime forces come from presets/tier systems
    - scene dressing comes from composition keys
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

private _missionDefinition = [
    ["missionId", "MissionSupply_2"],
    ["title", "Hijack Armored Resupply"],
    ["description", "Intercept a protected resupply movement and claim its contents before reinforcements lock the route down."],
    ["category", "supply"],
    ["difficulty", "hard"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "supply_armored_hard"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 242],
    ["rewardIntel", 30],
    ["rewardThreat", 10],
    ["rewardTier", 8],
    ["rewardThreatUndercover", 1],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Undercover can still leave trace pressure at this difficulty."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "supply", "hard", 2, _missionDefinition] call MWF_fnc_executeMissionTemplate;
