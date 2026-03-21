/*
    Author: OpenAI / ChatGPT
    Template: MissionSupply_1
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
    ["missionId", "MissionSupply_1"],
    ["title", "Capture Ammunition Yard"],
    ["description", "Hit a forward ammunition yard and move the stockpile into friendly hands."],
    ["category", "supply"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['factory', 'military']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "supply_ammo_medium"],
    ["sceneVariant", "ammo"],
    ["objectiveAction", "Secure Supplies"],
    ["completionNote", "Supply cache secured."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", false],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 185],
    ["rewardIntel", 18],
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

[_slotData, _caller, "supply", "medium", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
