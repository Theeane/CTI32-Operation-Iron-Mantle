/*
    Author: Theane / ChatGPT
    Template: MissionSupply_3
    Category: supply
    Difficulty: easy

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
    ["title", "Escort Salvaged Stock"],
    ["description", "Stabilize and move reclaimed supplies from a soft contact point back into BLUFOR circulation."],
    ["category", "supply"],
    ["difficulty", "easy"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", true],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "supply_salvage_easy"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 138],
    ["rewardIntel", 15],
    ["rewardThreat", 5],
    ["rewardTier", 3],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Optional friendly follow-up can use player base tier assets later."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "supply", "easy", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
