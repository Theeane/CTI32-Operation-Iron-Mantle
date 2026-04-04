/*
    Author: OpenAI
    Function: MWF_fnc_getHudStatusData
    Project: Military War Framework

    Description:
    Central status snapshot for terminal and sidebar HUD so both surfaces read the
    exact same economy/progression values.

    Returns:
    HashMap with current HUD/terminal status values.
*/

private _threatRaw = missionNamespace getVariable ["MWF_res_notoriety", missionNamespace getVariable ["MWF_ThreatLevel", 0]];
private _threatBucket = 10 * floor ((0 max (100 min _threatRaw)) / 10);

createHashMapFromArray [
    ["supplies", missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]]],
    ["intel", missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]]],
    ["tempIntel", player getVariable ["MWF_carriedIntelValue", 0]],
    ["freeMainOpCharges", missionNamespace getVariable ["MWF_FreeMainOpCharges", 0]],
    ["worldTier", missionNamespace getVariable ["MWF_WorldTier", 1]],
    ["baseTier", missionNamespace getVariable ["MWF_CurrentTier", 1]],
    ["phase", missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]],
    ["threat", _threatBucket],
    ["debugMode", missionNamespace getVariable ["MWF_DebugMode", false]]
]
