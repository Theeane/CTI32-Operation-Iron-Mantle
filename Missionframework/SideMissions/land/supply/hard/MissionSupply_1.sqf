/*
    Author: OpenAI / ChatGPT
    Template: MissionSupply_1
    Category: supply
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
    ["missionId", "MissionSupply_1"],
    ["title", "Overrun Armored Supply Node"],
    ["description", "Crack a hardened armored resupply point and capture what survives the fight."],
    ["category", "supply"],
    ["difficulty", "hard"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "supply_armor_node_hard"],
    ["sceneVariant", "armor_node"],
    ["objectiveAction", "Secure Supplies"],
    ["completionNote", "Supply cache secured."],
    ["clearRadius", 45],
    ["guardCount", 8],
    ["patrolRadius", 70],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 255],
    ["rewardIntel", 28],
    ["rewardThreat", 8],
    ["rewardTier", 4],
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

[_slotData, _caller, "supply", "hard", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
