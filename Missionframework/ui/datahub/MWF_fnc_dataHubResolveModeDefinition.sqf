params [["_mode", "ZONES", [""]]];

private _modeUpper = toUpper _mode;
private _definition = createHashMapFromArray [
    ["mode", _modeUpper],
    ["primaryLabel", "Back"],
    ["primaryEnabled", false],
    ["primaryTooltip", "Back."],
    ["secondaryLabel", "Missions"],
    ["secondaryEnabled", true],
    ["secondaryTooltip", "Switch to missions."],
    ["folder", "ui\\datahub"]
];

switch (_modeUpper) do {
    case "SIDE_MISSIONS": { _definition = [] call MWF_fnc_missionsMode; };
    case "MAIN_OPERATIONS": { _definition = [] call MWF_fnc_mainOperationsMode; };
    case "REDEPLOY": { _definition = [] call MWF_fnc_redeployMode; };
    case "SUPPORT": { _definition = [] call MWF_fnc_buildSupportMode; };
    case "UPGRADES": { _definition = [] call MWF_fnc_baseUpgradesMode; };
    case "BUILD_MENU": { _definition = [] call MWF_fnc_buildMenuMode; };
    case "VEHICLE_MENU": { _definition = [] call MWF_fnc_vehicleMenuMode; };
};

_definition
