/*
    Author: Theane / ChatGPT
    Function: fn_getMainOperationRegistry
    Project: Military War Framework

    Description:
    Returns the central metadata registry for all land main operations.
    This is the single source of truth for titles, descriptions, effect text,
    fallback text, cooldown, runtime function, and impact identity.

    Return:
    Array of records:
    [key, title, description, functionName, impactId, effectType, effectText, fallbackText, cooldownSeconds, intelCost]
*/

private _registry = [
    [
        "SKY_GUARDIAN",
        "Sky Guardian",
        "Restore aerial detection control and break the enemy's local surveillance grid.",
        "MWF_fnc_op_skyGuardian",
        "sky_guardian",
        "progression",
        "+18 threat / +22 tier progression.",
        "No special fallback. Standard main operation rewards still apply if progression is suppressed elsewhere.",
        3600,
        100
    ],
    [
        "POINT_BLANK",
        "Point Blank",
        "Destroy the missile complex and secure the airfield for allied jet operations.",
        "MWF_fnc_op_pointBlank",
        "point_blank",
        "progression",
        "+22 threat / +28 tier progression and unlocks jet assets.",
        "No special fallback. Standard main operation rewards still apply if progression is suppressed elsewhere.",
        3600,
        150
    ],
    [
        "SEVERED_NERVE",
        "Severed Nerve",
        "Hit the enemy's operational nerve center and force a strategic de-escalation.",
        "MWF_fnc_op_severedNerve",
        "severed_nerve",
        "tier_reduction",
        "Attempts to reduce OPFOR world tier by 1.",
        "If the Tier 3 floor blocks the reduction, the operation converts to Supplies / Intel instead.",
        3600,
        175
    ],
    [
        "STASIS_STRIKE",
        "Stasis Strike",
        "Cripple enemy coordination and temporarily halt strategic escalation.",
        "MWF_fnc_op_stasisStrike",
        "stasis_strike",
        "tier_block",
        "Blocks OPFOR tier progression and main-op threat progression for 60 minutes.",
        "If a block is already active, the operation converts to Supplies / Intel instead of extending the timer.",
        3600,
        200
    ],
    [
        "STEEL_RAIN",
        "Steel Rain",
        "Cripple artillery and armored support to open the battlefield for future pushes.",
        "MWF_fnc_op_steelRain",
        "steel_rain",
        "progression",
        "+20 threat / +24 tier progression.",
        "No special fallback. Standard main operation rewards still apply if progression is suppressed elsewhere.",
        3600,
        125
    ],
    [
        "APEX_PREDATOR",
        "Apex Predator",
        "Break the last strategic strongpoint and drive the war into late-stage escalation.",
        "MWF_fnc_op_apexPredator",
        "apex_predator",
        "progression",
        "+28 threat / +34 tier progression.",
        "No special fallback. Standard main operation rewards still apply if progression is suppressed elsewhere.",
        3600,
        250
    ]
];

missionNamespace setVariable ["MWF_MainOperationRegistry", _registry];
_registry
