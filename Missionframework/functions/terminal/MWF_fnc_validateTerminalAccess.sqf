/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_validateTerminalAccess
    Project: Military War Framework

    Description:
    Centralized terminal lock validator for actions that should be unavailable
    while certain operations are already active.

    Params:
    0: STRING - action key (MISSION_HUB / MAIN_OPERATIONS)

    Returns:
    [BOOL allowed, STRING reason]
*/

params [
    ["_actionType", "", [""]]
];

private _allowed = true;
private _reason = "";

switch (toUpper _actionType) do {
    case "MAIN_OPERATIONS": {
        if (missionNamespace getVariable ["MWF_GrandOperationActive", false]) then {
            _allowed = false;
            _reason = "Main Operations locked during active operation.";
        };
    };

    case "MISSION_HUB": {
        private _activeSideMissions = missionNamespace getVariable ["MWF_ActiveSideMissions", []];
        if !(_activeSideMissions isEqualTo []) then {
            _allowed = false;
            _reason = "Mission Hub locked while missions are active.";
        };
    };
};

[_allowed, _reason]
