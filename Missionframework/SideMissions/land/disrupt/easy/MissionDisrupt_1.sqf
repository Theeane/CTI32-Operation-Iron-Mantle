/*
    Author: OpenAI / ChatGPT
    Template: MissionDisrupt_1
    Category: disrupt
    Difficulty: easy
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
    ["title", "Sabotage Field Generator"],
    ["description", "Take out a field generator powering local OPFOR systems."],
    ["category", "disrupt"],
    ["difficulty", "easy"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", false],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", false],
    ["usesRebels", false],
    ["compositionKey", "disrupt_generator_easy"],
    ["sceneVariant", "generator"],
    ["objectiveAction", "Plant Charges"],
    ["completionNote", "Enemy site sabotaged."],
    ["clearRadius", 32],
    ["guardCount", 4],
    ["patrolRadius", 40],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 105],
    ["rewardIntel", 15],
    ["rewardThreat", 4],
    ["rewardTier", 2],
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

[_slotData, _caller, "disrupt", "easy", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
