/*
    Author: OpenAI / ChatGPT
    Template: MissionIntel_3
    Category: intel
    Difficulty: easy
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
    ["missionId", "MissionIntel_3"],
    ["title", "Grab Courier Terminal"],
    ["description", "Secure a courier handoff terminal and pull whatever was queued for transmission."],
    ["category", "intel"],
    ["difficulty", "easy"],
    ["allowedZoneTypes", ['town', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "intel_courier_terminal_easy"],
    ["sceneVariant", "courier_terminal"],
    ["objectiveAction", "Extract Courier Data"],
    ["completionNote", "Courier terminal data extracted."],
    ["clearRadius", 32],
    ["guardCount", 4],
    ["patrolRadius", 40],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 65],
    ["rewardIntel", 46],
    ["rewardThreat", 4],
    ["rewardTier", 2],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Official authored modern land intel mission. Runtime stays preset-driven, map agnostic, and category-aware."],
    ["assetRules", [
        "Use active OPFOR preset infantry scaled by world tier for site security.",
        "Use active civilian preset ambience only when usesCivilians is true.",
        "Use sceneVariant to shape the runtime prop cluster and objective presentation.",
        "Use compositionKey only as a future composition hook; runtime must remain map agnostic today."
    ]]
];

[_slotData, _caller, "intel", "easy", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
