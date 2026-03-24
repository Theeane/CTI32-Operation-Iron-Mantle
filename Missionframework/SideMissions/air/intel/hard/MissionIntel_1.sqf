/*
    Author: Theane / ChatGPT
    Template: MissionIntel_1
    Category: intel
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
    ["missionId", "MissionIntel_1"],
    ["title", "Infiltrate Signal Station"],
    ["description", "Slip into a high-value signal station and extract strategic information without collapsing the site."],
    ["category", "intel"],
    ["difficulty", "hard"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "intel_signal_hard"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 112],
    ["rewardIntel", 154],
    ["rewardThreat", 7],
    ["rewardTier", 6],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Undercover-friendly high-value objective."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "intel", "hard", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
