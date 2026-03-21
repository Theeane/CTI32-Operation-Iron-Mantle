/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_terminal_mainOperations
    Project: Military War Framework

    Description:
    Lightweight terminal-backed launcher for Grand Operations.
    Uses the central main-operation registry so UI and runtime consume the same metadata.
*/

params [
    ["_mode", "OPEN", [""]],
    ["_arg1", objNull, [objNull,0,""]],
    ["_arg2", 0, [0]]
];

private _ops = [] call MWF_fnc_getMainOperationRegistry;

switch (toUpper _mode) do {
    case "OPEN": {
        if (!hasInterface) exitWith {};

        private _check = ["MAIN_OPERATIONS"] call MWF_fnc_validateTerminalAccess;
        if !(_check param [0, false]) exitWith {
            private _reason = _check param [1, "Main Operations unavailable."];
            systemChat _reason;
            [["MAIN OPERATIONS", _reason], "warning"] call MWF_fnc_showNotification;
        };

        ["CLOSE"] call MWF_fnc_terminal_mainOperations;

        private _freeCharges = missionNamespace getVariable ["MWF_FreeMainOpCharges", 0];
        private _text = format ["Main Operations<br/>Select a grand operation from the action menu.<br/><t size='0.85'>Intel jackpot charges: %1</t><br/><br/>", _freeCharges];
        {
            _x params ["_key", "_title", "_desc", "_fnName", "_impactId", "_effectType", "_effectText", "_fallbackText"];
            private _state = [_key, _x] call MWF_fnc_getMainOperationState;
            private _detailLine = format ["<t size='0.85'>Effect: %1</t>", _effectText];
            if !(_fallbackText isEqualTo "") then {
                _detailLine = _detailLine + format ["<br/><t size='0.85'>Fallback: %1</t>", _fallbackText];
            };

            _text = _text + format [
                "%1 [%2]<br/>%3<br/>%4<br/><t size='0.85'>%5</t><br/><br/>",
                toUpper _title,
                toUpper (_state getOrDefault ["state", "unknown"]),
                _desc,
                _detailLine,
                _state getOrDefault ["tooltipText", ""]
            ];
        } forEach _ops;

        hintSilent parseText format ["<t size='1.0'>%1</t>", _text];

        private _actionIds = [];
        {
            private _i = _forEachIndex;
            _x params ["_key", "_title"];
            private _state = [_key, _x] call MWF_fnc_getMainOperationState;
            private _label = if (_state getOrDefault ["isAvailable", false]) then {
                format ["<t color='#7CC8FF'>Start Grand Op: %1</t>", _title]
            } else {
                format ["<t color='#C8A070'>%1 (%2)</t>", _title, _state getOrDefault ["statusText", "Unavailable"]]
            };

            private _id = player addAction [
                _label,
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
        [["MAIN OPERATIONS", "Action menu ready. Locked entries show cooldown or availability reasons."], "info"] call MWF_fnc_showNotification;
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
            private _reason = _check param [1, "Main Operations unavailable."];
            systemChat _reason;
            [["MAIN OPERATIONS", _reason], "warning"] call MWF_fnc_showNotification;
        };

        private _entry = _ops # _index;
        _entry params ["_key", "_title"];
        private _state = [_key, _entry] call MWF_fnc_getMainOperationState;
        if !(_state getOrDefault ["isAvailable", false]) exitWith {
            private _reason = _state getOrDefault ["tooltipText", "Operation unavailable."];
            systemChat _reason;
            [["MAIN OPERATIONS", _reason], "warning"] call MWF_fnc_showNotification;
        };

        ["CLOSE"] call MWF_fnc_terminal_mainOperations;
        ["START_SERVER", _index, clientOwner] remoteExecCall ["MWF_fnc_terminal_mainOperations", 2];
        [["MAIN OPERATIONS", format ["Request sent: %1", _title]], "info"] call MWF_fnc_showNotification;
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

        private _entry = _ops # _index;
        _entry params ["_key", "_title", "_desc", "_fnName"];
        private _state = [_key, _entry] call MWF_fnc_getMainOperationState;
        if !(_state getOrDefault ["isAvailable", false]) exitWith {
            [(_state getOrDefault ["tooltipText", "Operation unavailable."])] remoteExecCall ["systemChat", _requestOwner];
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

        missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperation", _key, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _title, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", _placement, true];

        private _freeCharges = missionNamespace getVariable ["MWF_FreeMainOpCharges", 0];
        private _usedFreeCharge = _freeCharges > 0;
        if (_usedFreeCharge) then {
            missionNamespace setVariable ["MWF_FreeMainOpCharges", (_freeCharges - 1) max 0, true];
        };

        private _fn = missionNamespace getVariable [_fnName, objNull];
        if (isNil "_fn" || {_fn isEqualTo objNull}) exitWith {
            missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
            [format ["Grand Operation function not found: %1", _fnName]] remoteExecCall ["systemChat", _requestOwner];
        };

        if (isNil "MWF_fnc_mainOperationRuntime") exitWith {
            missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
            missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
            missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
            ["Main operation runtime bridge is unavailable."] remoteExecCall ["systemChat", _requestOwner];
        };

        ["START", [_key, _fnName, _title, _position, _requestOwner]] call MWF_fnc_mainOperationRuntime;

        [["MAIN OPERATION", format ["%1 launched in %2.%3", _title, _zoneName, if (_usedFreeCharge) then {" Intel breakthrough charge consumed."} else {""}]], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        [format ["Grand Operation started: %1", _title]] remoteExecCall ["systemChat", _requestOwner];
        diag_log format ["[MWF Main Operations] Started %1 at %2 in %3.", _key, _position, _zoneName];
    };
};
