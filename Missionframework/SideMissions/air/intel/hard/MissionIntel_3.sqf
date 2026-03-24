/*
    Author: Theane / ChatGPT
    Template: MissionIntel_3
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
    ["missionId", "MissionIntel_3"],
    ["title", "Expose Clandestine Network"],
    ["description", "Map and expose an embedded clandestine network through a layered intelligence operation."],
    ["category", "intel"],
    ["difficulty", "hard"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", true],
    ["compositionKey", "intel_network_hard"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 138],
    ["rewardIntel", 182],
    ["rewardThreat", 9],
    ["rewardTier", 8],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", true],
    ["minCivilianRep", 10],
    ["minRebelRep", 8],
    ["failIfRepTooLow", true],
    ["notes", "Late-game intel scenario that can hook into rebel trust later."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "intel", "hard", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
