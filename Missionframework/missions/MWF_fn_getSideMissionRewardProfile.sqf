/*
    Author: Theane / ChatGPT
    Function: fn_getSideMissionRewardProfile
    Project: Military War Framework

    Description:
    Returns the current fixed placeholder reward profile for side missions.
    These values are intentionally data-driven so they can be rebalanced later
    without rewriting every mission template.

    Return:
    [suppliesReward, intelReward, threatSeverity, bonusIntelIfUndercover]
*/

params [
    ["_category", "disrupt", [""]],
    ["_difficulty", "easy", [""]]
];

_category = toLower _category;
_difficulty = toLower _difficulty;

private _profile = switch (_category) do {
    case "disrupt": {
        switch (_difficulty) do {
            case "easy": {[80, 20, 2, 15]};
            case "medium": {[120, 35, 3, 20]};
            case "hard": {[180, 50, 4, 25]};
            default {[80, 20, 2, 15]};
        };
    };
    case "supply": {
        switch (_difficulty) do {
            case "easy": {[120, 10, 1, 10]};
            case "medium": {[170, 20, 2, 15]};
            case "hard": {[240, 30, 3, 20]};
            default {[120, 10, 1, 10]};
        };
    };
    case "intel": {
        switch (_difficulty) do {
            case "easy": {[50, 60, 1, 25]};
            case "medium": {[80, 100, 2, 35]};
            case "hard": {[120, 150, 3, 50]};
            default {[50, 60, 1, 25]};
        };
    };
    default {
        [80, 20, 2, 15]
    };
};

_profile
