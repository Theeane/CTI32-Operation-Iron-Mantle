/*
    Author: Theane / ChatGPT
    Function: MWF_fn_getScalingProfile
    Project: Military War Framework

    Description:
    Resolves the selected player-scaling bracket into a simple gameplay profile.
    This is session-only and is intentionally not persisted across restarts.
*/

params [
    ["_bracket", missionNamespace getVariable ["MWF_PlayerScalingBracket", 1], [0]]
];

switch ((_bracket max 0) min 3) do {
    case 0: {
        createHashMapFromArray [
            ["bracket", 0],
            ["uiLabel", "1-8 Players (Small Group)"],
            ["aiMultiplier", 0.75],
            ["pressureMultiplier", 0.80],
            ["patrolDensityMultiplier", 0.85],
            ["qrfIntervalMultiplier", 1.15],
            ["zoneEnemyMultiplier", 0.80],
            ["zoneCivilianMultiplier", 0.90],
            ["fobAssaultGroupMultiplier", 0.85],
            ["fobAssaultUnitMultiplier", 0.85],
            ["recommendedUnitCap", 80]
        ]
    };
    case 2: {
        createHashMapFromArray [
            ["bracket", 2],
            ["uiLabel", "17-24 Players (Large Group)"],
            ["aiMultiplier", 1.20],
            ["pressureMultiplier", 1.15],
            ["patrolDensityMultiplier", 1.15],
            ["qrfIntervalMultiplier", 0.90],
            ["zoneEnemyMultiplier", 1.20],
            ["zoneCivilianMultiplier", 1.05],
            ["fobAssaultGroupMultiplier", 1.15],
            ["fobAssaultUnitMultiplier", 1.15],
            ["recommendedUnitCap", 120]
        ]
    };
    case 3: {
        createHashMapFromArray [
            ["bracket", 3],
            ["uiLabel", "25-32 Players (Full Scale)"],
            ["aiMultiplier", 1.40],
            ["pressureMultiplier", 1.30],
            ["patrolDensityMultiplier", 1.25],
            ["qrfIntervalMultiplier", 0.80],
            ["zoneEnemyMultiplier", 1.35],
            ["zoneCivilianMultiplier", 1.10],
            ["fobAssaultGroupMultiplier", 1.30],
            ["fobAssaultUnitMultiplier", 1.25],
            ["recommendedUnitCap", 150]
        ]
    };
    default {
        createHashMapFromArray [
            ["bracket", 1],
            ["uiLabel", "9-16 Players (Medium Group)"],
            ["aiMultiplier", 1.00],
            ["pressureMultiplier", 1.00],
            ["patrolDensityMultiplier", 1.00],
            ["qrfIntervalMultiplier", 1.00],
            ["zoneEnemyMultiplier", 1.00],
            ["zoneCivilianMultiplier", 1.00],
            ["fobAssaultGroupMultiplier", 1.00],
            ["fobAssaultUnitMultiplier", 1.00],
            ["recommendedUnitCap", 100]
        ]
    };
};
