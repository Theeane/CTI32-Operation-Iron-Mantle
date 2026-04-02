private _external = uiNamespace getVariable ["MWF_RedeployShell_Active", false];
createHashMapFromArray [
    ["mode", "REDEPLOY"],
    ["folder", "ui\Redeploy"],
    ["primaryLabel", "Redeploy"],
    ["primaryEnabled", false],
    ["primaryTooltip", "Redeploy to selected point."],
    ["secondaryLabel", if (_external) then {"Back"} else {"Missions"}],
    ["secondaryEnabled", true],
    ["secondaryTooltip", if (_external) then {"Return to terminal."} else {"Switch to missions."}]
]
