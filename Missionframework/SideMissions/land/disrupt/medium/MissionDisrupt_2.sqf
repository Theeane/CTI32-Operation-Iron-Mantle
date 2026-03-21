/*
    Author: OpenAI / ChatGPT
    Template: MissionDisrupt_2
    Category: disrupt
    Difficulty: medium
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
    ["missionId", "MissionDisrupt_2"],
    ["title", "Sabotage Motor Pool"],
    ["description", "Cripple a motor pool service point before armored vehicles can be turned around."],
    ["category", "disrupt"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", false],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "disrupt_motor_pool_medium"],
    ["sceneVariant", "motor_pool"],
    ["objectiveAction", "Plant Charges"],
    ["completionNote", "Enemy site sabotaged."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 155],
    ["rewardIntel", 28],
    ["rewardThreat", 6],
    ["rewardTier", 3],
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

[_slotData, _caller, "disrupt", "medium", 2, _missionDefinition] call MWF_fnc_executeMissionTemplate;
