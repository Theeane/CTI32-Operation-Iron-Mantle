/*
    Author: OpenAI / ChatGPT
    Template: MissionDisrupt_1
    Category: disrupt
    Difficulty: hard
    Era: modern

    Description:
    Authored modern land mission template.
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
    ["title", "Cripple Radar Service Yard"],
    ["description", "Sabotage a radar support yard that keeps high-end sensors in the fight."],
    ["category", "disrupt"],
    ["difficulty", "hard"],
    ["allowedZoneTypes", ['military', 'capital']],
    ["allowUndercover", false],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "disrupt_radar_service_hard"],
    ["sceneVariant", "radar_service"],
    ["objectiveAction", "Plant Charges"],
    ["completionNote", "Enemy site sabotaged."],
    ["clearRadius", 45],
    ["guardCount", 8],
    ["patrolRadius", 70],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 195],
    ["rewardIntel", 36],
    ["rewardThreat", 8],
    ["rewardTier", 4],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Modern authored disrupt mission runtime site."],
    ["assetRules", [
        "Use active OPFOR preset infantry scaled by world tier for guards.",
        "Use civilians from the active preset when the mission definition enables them.",
        "Use the shared runtime scene for category-specific objective props.",
        "Use compositionKey only as a future composition hook; runtime must remain map agnostic today."
    ]]
];

[_slotData, _caller, "disrupt", "hard", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
