/*
    Author: OpenAI / ChatGPT
    Template: MissionIntel_3
    Category: intel
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
    ["missionId", "MissionIntel_3"],
    ["title", "Steal UAV Telemetry"],
    ["description", "Extract UAV telemetry packages from a monitoring node before they are forwarded."],
    ["category", "intel"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "intel_uav_medium"],
    ["sceneVariant", "uav"],
    ["objectiveAction", "Download UAV Telemetry"],
    ["completionNote", "UAV telemetry secured."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 80],
    ["rewardIntel", 74],
    ["rewardThreat", 6],
    ["rewardTier", 3],
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

[_slotData, _caller, "intel", "medium", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
