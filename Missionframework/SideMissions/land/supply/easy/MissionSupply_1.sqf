/*
    Author: Theane / ChatGPT
    Template: MissionSupply_1
    Category: supply
    Difficulty: easy
    Domain: land
    Era: modern-compatible / mod agnostic

    Gold standard reference template for Missionframework/SideMissions/land/supply/easy/.
    This file is intentionally conservative and should be treated as the pattern
    for future authored or AI-generated supply missions.

    Rules demonstrated here:
    - keep params exactly as [_slotData, _caller]
    - keep naming consistent: MissionSupply_<id>
    - use only structured metadata, never hardcoded world objects or faction classnames
    - use valid known zone tags only
    - fixed rewards only, never randomized
    - rely on compositionKey + preset/tier systems for world dressing and opposition
    - finish with the shared runtime call to MWF_fnc_executeMissionTemplate
*/

params [
    ["_slotData", [], [[]]],
    ["_caller", objNull, [objNull]]
];

private _missionDefinition = [
    ["missionId", "MissionSupply_1"],
    ["title", "Recover Medical Cache"],
    ["description", "Secure a light logistics cache containing medical supplies before OPFOR reclaim or destroy it."],
    ["category", "supply"],
    ["difficulty", "easy"],

    // Placement
    ["allowedZoneTypes", ["town", "roadside"]],
    ["allowUndercover", true],

    // Runtime faction intent only; actual assets come from active presets
    ["usesOpfor", true],
    ["usesBluforSupport", false],
    ["usesCivilians", true],
    ["usesRebels", false],

    // Scene / resolver
    ["compositionKey", "supply_medical_easy"],
    ["enemyTierSource", "worldTier"],
    ["bluforTierSource", "playerBaseTier"],
    ["rebelTierSource", "rebelTier"],

    // Fixed rewards
    ["rewardSupplies", 120],
    ["rewardIntel", 10],
    ["rewardThreat", 4],
    ["rewardTier", 2],
    ["rewardThreatUndercover", 0],

    // Reputation / access
    ["requiresRebelCooperation", false],
    ["minCivilianRep", 0],
    ["minRebelRep", 0],
    ["failIfRepTooLow", false],

    // Authoring notes only
    ["notes", "Baseline easy supply mission. Supplies-first reward profile, stealth-friendly, no special-case runtime assumptions."],
    ["assetRules", [
        "Use OPFOR from preset/opfor scaled by world tier.",
        "Use BLUFOR from preset/blufor scaled by player base tier only when support is enabled.",
        "Use civilians from preset/civilians when enabled.",
        "Use rebels from preset/resistance scaled by rebel tier only when enabled.",
        "Use compositionKey for all props, layout, and scene dressing.",
        "Do not hardcode units, vehicles, props, or buildings in mission definitions."
    ]]
];

[_slotData, _caller, "supply", "easy", 1, _missionDefinition] call MWF_fnc_executeMissionTemplate;
