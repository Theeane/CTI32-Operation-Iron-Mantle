/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_showNotification
    Project: Military War Framework

    Description:
    Shared notification wrapper with lightweight style support and
    concise debug-feed output when debug mode is enabled.
*/

params [
    ["_payload", [], [[]]],
    ["_style", "info", [""]]
];

private _title = "MWF";
private _message = "";

if (_payload isEqualType []) then {
    _title = _payload param [0, "MWF"];
    _message = _payload param [1, ""];
} else {
    _message = str _payload;
};

private _styleKey = toLower _style;
private _titleColor = switch (_styleKey) do {
    case "success": { "#8DFF8D" };
    case "warning": { "#FFD27A" };
    case "error": { "#FF8A8A" };
    default { "#9AD8FF" };
};

private _feedTag = switch (_styleKey) do {
    case "success": { "[SUCCESS]" };
    case "warning": { "[WARN]" };
    case "error": { "[ERROR]" };
    default { "[INFO]" };
};

hintSilent parseText format [
    "<t size='1.1' color='%1'>%2</t><br/><t size='0.95'>%3</t>",
    _titleColor,
    _title,
    _message
];

if (missionNamespace getVariable ["MWF_DebugMode", false]) then {
    private _debugLine = format ["%1 %2: %3", _feedTag, _title, _message];
    systemChat _debugLine;
    diag_log format ["[MWF DEBUG FEED] %1", _debugLine];
};
