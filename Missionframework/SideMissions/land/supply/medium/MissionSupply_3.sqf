/*
    Author: OpenAI / ChatGPT
    Template: MissionSupply_3
    Category: supply
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
    ["missionId", "MissionSupply_3"],
    ["title", "Break Convoy Staging Site"],
    ["description", "Seize the staging site of an enemy convoy before it rolls out."],
    ["category", "supply"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['factory', 'town']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "supply_convoy_medium"],
    ["sceneVariant", "convoy"],
    ["objectiveAction", "Secure Supplies"],
    ["completionNote", "Supply cache secured."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 215],
    ["rewardIntel", 22],
    ["rewardThreat", 6],
    ["rewardTier", 3],
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

[_slotData, _caller, "supply", "medium", 3, _missionDefinition] call MWF_fnc_executeMissionTemplate;
