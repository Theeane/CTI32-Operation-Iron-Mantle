/*
    Author: OpenAI / ChatGPT
    Template: MissionIntel_3
    Category: intel
    Difficulty: hard
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
    ["title", "Break Encryption Cell"],
    ["description", "Hit a live encryption cell and capture the latest decryption materials intact."],
    ["category", "intel"],
    ["difficulty", "hard"],
    ["allowedZoneTypes", ['military', 'capital', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "intel_encryption_hard"],
    ["sceneVariant", "encryption"],
    ["objectiveAction", "Break Encryption Cell"],
    ["completionNote", "Encryption materials secured."],
    ["clearRadius", 45],
    ["guardCount", 8],
    ["patrolRadius", 70],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 105],
    ["rewardIntel", 115],
    ["rewardThreat", 8],
    ["rewardTier", 4],
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

[_slotData, _caller, "intel", "hard", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
