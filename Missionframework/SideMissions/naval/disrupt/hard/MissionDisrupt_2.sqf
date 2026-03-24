/*
    Author: Theane / ChatGPT
    Template: MissionDisrupt_2
    Category: disrupt
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
    ["missionId", "MissionDisrupt_2"],
    ["title", "Break Forward Command Post"],
    ["description", "Overload a fortified forward command post and interrupt hostile coordination at a strategic level."],
    ["category", "disrupt"],
    ["difficulty", "hard"],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "disrupt_command_hard"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 182],
    ["rewardIntel", 48],
    ["rewardThreat", 13],
    ["rewardTier", 9],
    ["rewardThreatUndercover", 1],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Composition only; no hardcoded props or vehicles."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier when enabled.",
        "Use compositionKey for all props/layouts."
    ]]
];

[_slotData, _caller, "disrupt", "hard", 2, _missionDefinition] call MWF_fnc_executeMissionTemplate;
