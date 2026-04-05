/*
    BuildMenu wrapper + mode definition.
    - [] call MWF_fnc_buildMenuMode; returns DataHub mode metadata.
    - [_terminal] spawn MWF_fnc_buildMenuMode; forwards directly into core build mode.
*/

if ((count _this) > 0) exitWith {
    params [["_terminal", objNull, [objNull]]];
    [_terminal] spawn MWF_fnc_enterBuildMode;
    true
};

createHashMapFromArray [
    ["mode", "BUILD_MENU"],
    ["folder", "ui\BuildMenu"],
    ["primaryLabel", "Open Zeus"],
    ["primaryEnabled", false],
    ["primaryTooltip", "Select a build anchor first."],
    ["secondaryLabel", "Back"],
    ["secondaryEnabled", true],
    ["secondaryTooltip", "Return to previous view."]
]
