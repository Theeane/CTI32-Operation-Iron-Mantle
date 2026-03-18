/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_terminal_mainOperations
    Project: Military War Framework

    Description:
    Lightweight terminal-backed launcher for Grand Operations.
    Uses player actions for selection so a richer UI can be layered on later.
*/

params [
    ["_mode", "OPEN", [""]],
    ["_arg1", objNull, [objNull,0,""]],
    ["_arg2", 0, [0]]
];

private _ops = [
    ["SKY_GUARDIAN", "Sky Guardian", "Restore aerial detection control.", "MWF_fnc_op_skyGuardian"],
    ["POINT_BLANK", "Point Blank", "Break the missile complex and unlock Jets.", "MWF_fnc_op_pointBlank"],
    ["SEVERED_NERVE", "Severed Nerve", "Disrupt the enemy's operational nerve center.", "MWF_fnc_op_severedNerve"],
    ["STASIS_STRIKE", "Stasis Strike", "Freeze enemy momentum with precision.", "MWF_fnc_op_stasisStrike"],
    ["STEEL_RAIN", "Steel Rain", "Cripple enemy artillery and heavy support.", "MWF_fnc_op_steelRain"],
    ["APEX_PREDATOR", "Apex Predator", "Final escalation toward Tier 5 dominance.", "MWF_fnc_op_apexPredator"]
];

switch (toUpper _mode) do {
    case "OPEN": {
        if (!hasInterface) exitWith {};

        private _check = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
        if !(_check param [0, false]) exitWith {
            systemChat (_check param [1, "Main Operations unavailable."]);
            [["MAIN OPERATIONS", (_check param [1, "Main Operations unavailable."])], "warning"] call MWF_fnc_showNotification;
        };

        ["CLOSE"] call MWF_fnc_terminal_mainOperations;

        private _currentOp = missionNamespace getVariable ["MWF_CurrentGrandOperation", ""];
        private _text = "Main Operations<br/>Select a grand operation from the action menu.<br/><br/>";
        {
            _x params ["_key", "_title", "_desc"];
            private _status = ["READY", "ACTIVE"] select ((_currentOp isEqualTo _key) && {missionNamespace getVariable ["MWF_GrandOperationActive", false]});
            _text = _text + format ["%1 [%2]<br/>%3<br/><br/>", toUpper _title, _status, _desc];
        } forEach _ops;
        hintSilent parseText format ["<t size='1.0'>%1</t>", _text];

        private _actionIds = [];
        {
            private _i = _forEachIndex;
            _x params ["", "_title"];
            private _id = player addAction [
                format ["<t color='#7CC8FF'>Start Grand Op: %1</t>", _title],
                { ["START", (_this select 3)] call MWF_fnc_terminal_mainOperations; },
                _i,
                (99 - _i),
                true,
                true,
                "",
                "true"
            ];
            _actionIds pushBack _id;
        } forEach _ops;

        private _closeId = player addAction [
            "<t color='#FF9090'>Close Main Operations</t>",
            { ["CLOSE"] call MWF_fnc_terminal_mainOperations; },
            nil,
            90,
            true,
            true,
            "",
            "true"
        ];
        _actionIds pushBack _closeId;

        missionNamespace setVariable ["MWF_Terminal_MainOps_ActionIds", _actionIds];
        systemChat "Main Operations ready. Use the action menu to start an operation.";
    };

    case "CLOSE": {
        if (!hasInterface) exitWith {};
        {
            player removeAction _x;
        } forEach (missionNamespace getVariable ["MWF_Terminal_MainOps_ActionIds", []]);
        missionNamespace setVariable ["MWF_Terminal_MainOps_ActionIds", []];
        hintSilent "";
    };

    case "START": {
        if (!hasInterface) exitWith {};

        private _index = _arg1;
        if !(_index isEqualType 0) exitWith {};
        if (_index < 0 || {_index >= count _ops}) exitWith {
            systemChat "Invalid Main Operation selection.";
        };

        private _check = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
        if !(_check param [0, false]) exitWith {
            systemChat (_check param [1, "Main Operations unavailable."]);
            [["MAIN OPERATIONS", (_check param [1, "Main Operations unavailable."])], "warning"] call MWF_fnc_showNotification;
        };

        ["CLOSE"] call MWF_fnc_terminal_mainOperations;
        ["START_SERVER", _index, clientOwner] remoteExecCall ["MWF_fnc_terminal_mainOperations", 2];
        systemChat "Main Operations request sent to command.";
    };

    case "START_SERVER": {
        if (!isServer) exitWith {};

        private _index = _arg1;
        private _requestOwner = _arg2;

        if !(_index isEqualType 0) exitWith {};
        if (_index < 0 || {_index >= count _ops}) exitWith {
            ["Invalid Main Operation selection."] remoteExecCall ["systemChat", _requestOwner];
        };

        private _check = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
        if !(_check param [0, false]) exitWith {
            [(_check param [1, "Main Operations unavailable."])] remoteExecCall ["systemChat", _requestOwner];
        };

        private _placements = missionNamespace getVariable ["MWF_GrandOperationSessionPlacements", []];
        if (_placements isEqualTo []) then {
            _placements = [] call MWF_fnc_buildGrandOperationPlacements;
        };

        if (_placements isEqualTo []) exitWith {
            ["No Grand Operation placements available this session."] remoteExecCall ["systemChat", _requestOwner];
        };

        private _placement = _placements # (_index mod (count _placements));
        _placement params ["_placementIndex", "_position", "_zoneId", "_zoneName"];

        private _entry = _ops # _index;
        _entry params ["_key", "_title", "_desc", "_fnName"];

        missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperation", _key, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _title, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", _placement, true];

        private _fn = missionNamespace getVariable [_fnName, objNull];
        if (isNil "_fn" || {_fn isEqualTo objNull}) exitWith {
            missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperation", nil, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", nil, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", nil, true];
            [format ["Grand Operation function not found: %1", _fnName]] remoteExecCall ["systemChat", _requestOwner];
        };

        ["START", _position] call _fn;

        [["MAIN OPERATION", format ["%1 launched in %2.", _title, _zoneName]], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        [format ["Grand Operation started: %1", _title]] remoteExecCall ["systemChat", _requestOwner];
        diag_log format ["[MWF Main Operations] Started %1 at %2 in %3.", _key, _position, _zoneName];
    };
};
