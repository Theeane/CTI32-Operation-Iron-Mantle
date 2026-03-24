/*
    Author: Theane / ChatGPT
    Function: fn_readMissionDefinition
    Project: Military War Framework

    Description:
    Reads a side-mission template file as text and extracts the _missionDefinition
    array without executing the template body. This keeps mission-board and
    placement metadata parsing centralized and tolerant of whitespace/layout
    changes around the assignment.
*/

params [
    ["_missionPath", "", [""]]
];

if (_missionPath isEqualTo "" || {!(fileExists _missionPath)}) exitWith { [] };

private _raw = loadFile _missionPath;
if (_raw isEqualTo "") exitWith { [] };

private _token = "_missionDefinition";
private _tokenPos = _raw find _token;
if (_tokenPos < 0) exitWith {
    diag_log format ["[MWF Missions] Mission definition token missing in %1.", _missionPath];
    []
};

private _scanPos = _tokenPos + (count _token);
private _equalPos = -1;
for "_i" from _scanPos to ((count _raw) - 1) do {
    private _ch = _raw select [_i, 1];
    if (_ch isEqualTo "=") exitWith { _equalPos = _i; };
    if !(_ch in [" ", toString [9], toString [10], toString [13]]) exitWith {};
};
if (_equalPos < 0) exitWith {
    diag_log format ["[MWF Missions] Mission definition assignment missing in %1.", _missionPath];
    []
};

private _start = -1;
for "_i" from (_equalPos + 1) to ((count _raw) - 1) do {
    private _ch = _raw select [_i, 1];
    if (_ch isEqualTo "[") exitWith { _start = _i; };
    if !(_ch in [" ", toString [9], toString [10], toString [13]]) exitWith {};
};
if (_start < 0) exitWith {
    diag_log format ["[MWF Missions] Mission definition array start missing in %1.", _missionPath];
    []
};

private _depth = 0;
private _inString = false;
private _end = -1;

for "_i" from _start to ((count _raw) - 1) do {
    private _ch = _raw select [_i, 1];

    if (_ch isEqualTo (toString [34])) then {
        private _escaped = (_i > 0) && {(_raw select [_i - 1, 1]) isEqualTo "\"};
        if (!_escaped) then {
            _inString = !_inString;
        };
    } else {
        if (!_inString) then {
            if (_ch isEqualTo "[") then {
                _depth = _depth + 1;
            } else {
                if (_ch isEqualTo "]") then {
                    _depth = _depth - 1;
                    if (_depth <= 0) exitWith { _end = _i; };
                };
            };
        };
    };
};

if (_end < _start) exitWith {
    diag_log format ["[MWF Missions] Mission definition array end missing in %1.", _missionPath];
    []
};

private _arrayText = _raw select [_start, (_end - _start) + 1];
private _definition = call compile _arrayText;
if !(_definition isEqualType []) exitWith {
    diag_log format ["[MWF Missions] Mission definition parse failed in %1.", _missionPath];
    []
};

_definition
