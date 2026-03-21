/*
    Author: OpenAI / ChatGPT
    Template: MissionDisrupt_1
    Category: disrupt
    Difficulty: medium
    Era: modern

    Description:
    Official authored modern land mission template.
    Runtime remains mod agnostic:
    - no hardcoded faction classnames in the template
    - OPFOR / civilians / support come from active presets
    - objective scene is built from category metadata by the shared runtime
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

private _missionDefinition = [
    ["missionId", "MissionDisrupt_1"],
    ["title", "Disable Artillery Power Node"],
    ["description", "Destroy the power node feeding an artillery support site."],
    ["category", "disrupt"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", false],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "disrupt_artillery_power_medium"],
    ["sceneVariant", "artillery_power"],
    ["objectiveAction", "Plant Charges"],
    ["completionNote", "Artillery power node destroyed."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 145],
    ["rewardIntel", 26],
    ["rewardThreat", 6],
    ["rewardTier", 3],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Official authored modern land disrupt mission. Runtime stays preset-driven, map agnostic, and category-aware."],
    ["assetRules", [
        "Use active OPFOR preset infantry scaled by world tier for site security.",
        "Do not hardcode special sabotage assets inside the mission template.",
        "Use sceneVariant to shape the runtime prop cluster and objective presentation.",
        "Use compositionKey only as a future composition hook; runtime must remain map agnostic today."
    ]]
];

[_slotData, _caller, "disrupt", "medium", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
