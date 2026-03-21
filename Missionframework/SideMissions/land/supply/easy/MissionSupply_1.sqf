/*
    Author: OpenAI / ChatGPT
    Template: MissionSupply_1
    Category: supply
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
    ["missionId", "MissionSupply_1"],
    ["title", "Recover Medical Cache"],
    ["description", "Recover the emergency medical cache before OPFOR relocates it."],
    ["category", "supply"],
    ["difficulty", "easy"],
    ["allowedZoneTypes", ['town', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "supply_medical_easy"],
    ["sceneVariant", "medical"],
    ["objectiveAction", "Secure Supplies"],
    ["completionNote", "Supply cache secured."],
    ["clearRadius", 32],
    ["guardCount", 4],
    ["patrolRadius", 40],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 135],
    ["rewardIntel", 10],
    ["rewardThreat", 4],
    ["rewardTier", 2],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Modern authored supply mission runtime site."],
    ["assetRules", [
        "Use active OPFOR preset infantry scaled by world tier for guards.",
        "Use civilians from the active preset when the mission definition enables them.",
        "Use the shared runtime scene for category-specific objective props.",
        "Use compositionKey only as a future composition hook; runtime must remain map agnostic today."
    ]]
];

[_slotData, _caller, "supply", "easy", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
