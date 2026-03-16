/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_terminal_mainOperations
    Project: Military War Framework

    Description:
    Lightweight terminal backend for Grand Operations.
    Opens a temporary action-driven operation list on the player,
    then starts the selected grand operation on the server.
*/

params [
    ["_mode", "OPEN", [""]],
    ["_arg1", objNull, [objNull, 0, "", []]],
    ["_arg2", -1, [0]]
];

private _modeUpper = toUpper _mode;

private _ops = [
    ["SKY_GUARDIAN",  "Sky Guardian",   "Restore aerial detection control.",               "MWF_fnc_op_skyGuardian"],
    ["POINT_BLANK",   "Point Blank",    "Break the missile complex and unlock Jets.",      "MWF_fnc_op_pointBlank"],
    ["SEVERED_NERVE", "Severed Nerve",  "Disrupt the enemy's operational nerve center.",   "MWF_fnc_op_severedNerve"],
    ["STASIS_STRIKE", "Stasis Strike",  "Freeze enemy momentum with precision disruption.", "MWF_fnc_op_stasisStrike"],
    ["STEEL_RAIN",    "Steel Rain",     "Cripple enemy artillery and heavy support.",      "MWF_fnc_op_steelRain"],
    ["APEX_PREDATOR", "Apex Predator",  "Final escalation path toward Tier 5 dominance.",  "MWF_fnc_op_apexPredator"]
];

switch (_modeUpper) do {
    case "OPEN": {
        if (!hasInterface) exitWith {};

        ["CLOSE"] call MWF_fnc_terminal_mainOperations;

        missionNamespace setVariable ["MWF_MainOperationsCatalog", _ops];
        missionNamespace setVariable ["MWF_MainOperations_Open", true];

        private _activeKey = missionNamespace getVariable ["MWF_CurrentGrandOperation", ""];
        private _lines = [
            "<t size='1.2' color='#FFD966'>Main Operations</t>",
            "<t size='0.95'>Select a grand operation from the action menu.</t>",
            " "
        ];

        private _actionIds = [];
        {
            _x params ["_key", "_title", "_desc"];
            private _status = if (_activeKey isEqualTo _key) then {
                "<t color='#FFAA00'>ACTIVE</t>"
            } else {
                "<t color='#7CFC00'>READY</t>"
            };

            _lines pushBack format ["<t color='#00BFFF'>%1</t> - %2", _title, _status];
            _lines pushBack format ["<t size='0.85'>%1</t>", _desc];
            _lines pushBack " ";

            private _idx = _forEachIndex;
            private _id = player addAction [
                format ["<t color='#FFD966'>Start Grand Op: %1</t>", _title],
                {
                    params ["_target", "_caller", "_actionId", "_arguments"];
                    _arguments params [["_index", -1, [0]]];
                    ["START", _index] call MWF_fnc_terminal_mainOperations;
                },
                [_idx],
                100 - _forEachIndex,
                true,
                true,
                "",
                "alive _this"
            ];
            _actionIds pushBack _id;
        } forEach _ops;

        private _closeId = player addAction [
            "<t color='#CCCCCC'>Close Main Operations</t>",
            { ["CLOSE"] call MWF_fnc_terminal_mainOperations; },
            nil,
            90,
            true,
            true,
            "",
            "alive _this"
        ];
        _actionIds pushBack _closeId;

        missionNamespace setVariable ["MWF_MainOperations_ActionIds", _actionIds];

        hintSilent parseText (_lines joinString "<br/>");
        systemChat "Main Operations ready. Use the action menu to start an operation.";
    };

    case "CLOSE": {
        if (!hasInterface) exitWith {};

        {
            if (_x >= 0) then {
                player removeAction _x;
            };
        } forEach (missionNamespace getVariable ["MWF_MainOperations_ActionIds", []]);

        missionNamespace setVariable ["MWF_MainOperations_ActionIds", []];
        missionNamespace setVariable ["MWF_MainOperations_Open", false];
    };

    case "START": {
        if (!hasInterface) exitWith {};

        private _index = _arg1;
        if !(_index isEqualType 0) exitWith {};
        if (_index < 0 || {_index >= count _ops}) exitWith {
            systemChat "Main Operations: invalid selection.";
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
            ["Main Operations: invalid server selection."] remoteExec ["systemChat", _requestOwner];
        };

        if (missionNamespace getVariable ["MWF_GrandOperationActive", false]) exitWith {
            ["A Grand Operation is already active."] remoteExec ["systemChat", _requestOwner];
        };

        private _placements = +(missionNamespace getVariable ["MWF_GrandOperationSessionPlacements", []]);
        if (_placements isEqualTo [] && {!isNil "MWF_fnc_buildGrandOperationPlacements"}) then {
            _placements = [] call MWF_fnc_buildGrandOperationPlacements;
        };

        if (_placements isEqualTo []) exitWith {
            ["Grand Operations unavailable: no valid strategic placements found."] remoteExec ["systemChat", _requestOwner];
        };

        private _entry = _ops # _index;
        _entry params ["_key", "_title", "_desc", "_fnName"];

        private _placement = _placements # (_index mod (count _placements));
        _placement params ["_placementIndex", "_position", "_zoneId", "_zoneName"];

        private _opFunction = missionNamespace getVariable [_fnName, objNull];
        if (isNil "_opFunction" || {isNull _opFunction}) then {
            [format ["Grand Operation function missing: %1", _fnName]] remoteExec ["systemChat", _requestOwner];
        } else {
            missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperation", _key, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _title, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", _placement, true];

            ["START", _position] call _opFunction;

            [["MAIN OPERATION", format ["%1 launched in %2.", _title, _zoneName]], "info"] remoteExec ["MWF_fnc_showNotification", 0];
            [format ["Grand Operation started: %1", _title]] remoteExec ["systemChat", _requestOwner];
            diag_log format ["[MWF Main Operations] Started %1 at %2 in %3.", _key, _position, _zoneName];
        };
    };
};
