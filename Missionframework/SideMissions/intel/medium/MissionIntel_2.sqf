/*
    Author: Theane / ChatGPT
    Template: MissionIntel_2
    Category: intel
    Difficulty: medium

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
    ["missionId", "MissionIntel_2"],
    ["title", "Broker Rebel Contact"],
    ["description", "Work through a resistance intermediary to obtain time-sensitive intelligence from a hostile district."],
    ["category", "intel"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['town', 'rural', 'capital']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", true],
    ["compositionKey", "intel_rebel_medium"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 88],
    ["rewardIntel", 118],
    ["rewardThreat", 5],
    ["rewardTier", 4],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", true],
    ["minCivilianRep", 5],
    ["minRebelRep", 5],
    ["failIfRepTooLow", true],
    ["notes", "Mission should respect rebel tier and civilian reputation when fully integrated."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "intel", "medium", 2, _missionDefinition] call MWF_fnc_executeMissionTemplate;
