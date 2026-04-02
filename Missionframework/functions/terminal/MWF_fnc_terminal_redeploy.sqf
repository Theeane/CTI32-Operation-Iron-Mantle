params [["_mode", "OPEN", [""]], ["_terminal", objNull, [objNull]], ["_caller", objNull, [objNull]]];

switch (toUpper _mode) do {
    case "OPEN": { [_terminal, _caller] call MWF_fnc_openRedeploy };
    default { false };
};
