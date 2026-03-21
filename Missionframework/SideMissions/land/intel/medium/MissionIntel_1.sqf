/*
    Author: OpenAI / ChatGPT
    Template: MissionIntel_1
    Category: intel
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
    ["missionId", "MissionIntel_1"],
    ["title", "Seize Signals Laptop"],
    ["description", "Steal fresh signals data from a staffed relay post."],
    ["category", "intel"],
    ["difficulty", "medium"],
    ["allowedZoneTypes", ['military', 'factory']],
    ["allowUndercover", true],
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],
    ["compositionKey", "intel_signals_medium"],
    ["sceneVariant", "signals"],
    ["objectiveAction", "Download Intel"],
    ["completionNote", "Field intelligence recovered."],
    ["clearRadius", 38],
    ["guardCount", 6],
    ["patrolRadius", 55],
    ["addOfficer", true],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],
    ["rewardSupplies", 70],
    ["rewardIntel", 62],
    ["rewardThreat", 6],
    ["rewardTier", 3],
    ["rewardThreatUndercover", 0],
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],
    ["notes", "Modern authored intel mission runtime site."],
    ["assetRules", [
        "Use active OPFOR preset infantry scaled by world tier for guards.",
        "Use civilians from the active preset when the mission definition enables them.",
        "Use the shared runtime scene for category-specific objective props.",
        "Use compositionKey only as a future composition hook; runtime must remain map agnostic today."
    ]]
];

[_slotData, _caller, "intel", "medium", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
