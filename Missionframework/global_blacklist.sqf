// Author: Theane / ChatGPT
// Project: Mission War Framework

/*
    User-facing arsenal blacklist.
    Add classnames here to hide specific items from the Virtual Arsenal.
    Example use cases:
    - tripod/static launchers
    - specific scopes or helmets
    - any other individual arsenal item you do not want available

    Note:
    This file is only for manual arsenal filtering.
    OPFOR uniform filtering is handled separately by the loadout/undercover system.
*/

missionNamespace setVariable ["MWF_GlobalBlacklist", [
    // "launch_O_Vorona_green_F",
    // "B_Static_Designator_01_weapon_F"
], true];
