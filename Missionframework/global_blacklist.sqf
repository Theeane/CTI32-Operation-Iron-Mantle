// Author: Theane / ChatGPT
// Project: Mission War Framework

/*
    User-facing arsenal blacklist.
    Add any classname here to hide it from the Virtual Arsenal.

    Supported categories:
    - weapons
    - magazines
    - backpacks
    - uniforms / vests / helmets / goggles
    - attachments / NVGs / binoculars
    - any other supported arsenal class that would otherwise be visible

    Example use cases:
    - tripod/static launcher bags
    - one specific weapon from a mod pack
    - a single overpowered scope, helmet or backpack

    Note:
    This file is only for manual arsenal filtering.
    OPFOR uniform filtering is handled separately by the loadout/undercover system.
*/

missionNamespace setVariable ["MWF_GlobalBlacklist", [
    // "launch_O_Vorona_green_F",
    // "B_Static_Designator_01_weapon_F",
    // "B_HMG_01_support_F"
], true];
