/*
    Author: Theane / ChatGPT
    Template: MissionSupply_3
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
    ["missionId", "MissionSupply_3"],
    ["title", "Relieve Rebel Lifeline"],
    ["description", "Deliver or secure supplies tied to a resistance-aligned lifeline under pressure."],
    ["category", "supply"],
    ["difficulty", "hard"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", true],
    ["compositionKey", "supply_rebel_hard"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 256],
    ["rewardIntel", 36],
    ["rewardThreat", 9],
    ["rewardTier", 8],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", true],
    ["minCivilianRep", 5],
    ["minRebelRep", 5],
    ["failIfRepTooLow", true],
    ["notes", "This mission is designed to respect rebel/civil reputation systems."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "supply", "hard", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
