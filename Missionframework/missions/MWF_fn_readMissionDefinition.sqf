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
private _stringQuote = "";
private _end = -1;

for "_i" from _start to ((count _raw) - 1) do {
    private _ch = _raw select [_i, 1];

    if (_inString) then {
        private _escaped = (_i > 0) && {(_raw select [_i - 1, 1]) isEqualTo "\"};
        if (!_escaped && {_ch isEqualTo _stringQuote}) then {
            _inString = false;
            _stringQuote = "";
        };
    } else {
        if (_ch in [toString [34], "'"]) then {
            _inString = true;
            _stringQuote = _ch;
        } else {
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

private _sanitizeOutsideStrings = {
    params ["_source"];

    private _result = "";
    private _inside = false;
    private _quote = "";

    for "_i" from 0 to ((count _source) - 1) do {
        private _ch = _source select [_i, 1];

        if (_inside) then {
            private _escaped = (_i > 0) && {(_source select [_i - 1, 1]) isEqualTo "\"};
            if (!_escaped && {_ch isEqualTo _quote}) then {
                _inside = false;
                _quote = "";
            };
            _result = _result + " ";
        } else {
            if (_ch in [toString [34], "'"]) then {
                _inside = true;
                _quote = _ch;
                _result = _result + " ";
            } else {
                _result = _result + _ch;
            };
        };
    };

    _result
};

private _sanitized = [_arrayText] call _sanitizeOutsideStrings;

if (
    (_sanitized find ";") >= 0
    || {(_sanitized find "{") >= 0}
    || {(_sanitized find "}") >= 0}
    || {(_sanitized find "(") >= 0}
    || {(_sanitized find ")") >= 0}
) exitWith {
    diag_log format ["[MWF Missions] Mission definition contains non-data tokens in %1.", _missionPath];
    []
};

private _allowedWords = ["true", "false", "nil", "null", "any"];
private _currentWord = "";
private _invalidWord = false;

for "_i" from 0 to ((count _sanitized) - 1) do {
    private _ch = _sanitized select [_i, 1];
    private _lower = toLower _ch;
    private _code = (toArray _lower) param [0, -1];
    private _isLetter = ((_code >= 97) && {_code <= 122}) || {_ch isEqualTo "_"};

    if (_isLetter) then {
        _currentWord = _currentWord + _lower;
    } else {
        if !(_currentWord isEqualTo "") then {
            if !(_currentWord in _allowedWords) exitWith {
                _invalidWord = true;
            };
            _currentWord = "";
        };
    };
};

if (!_invalidWord && {!(_currentWord isEqualTo "")}) then {
    if !(_currentWord in _allowedWords) then {
        _invalidWord = true;
    };
};

if (_invalidWord) exitWith {
    diag_log format ["[MWF Missions] Mission definition contains executable keywords in %1.", _missionPath];
    []
};

private _definition = parseSimpleArray _arrayText;
if !(_definition isEqualType []) exitWith {
    diag_log format ["[MWF Missions] Mission definition parse failed in %1.", _missionPath];
    []
};

private _isSimpleValue = {};
_isSimpleValue = {
    params ["_value"];

    if (_value isEqualType "") exitWith { true };
    if (_value isEqualType 0) exitWith { true };
    if (_value isEqualType false) exitWith { true };

    if (_value isEqualType []) exitWith {
        private _ok = true;
        {
            if !([_x] call _isSimpleValue) exitWith {
                _ok = false;
            };
        } forEach _value;
        _ok
    };

    false
};

private _valid = true;
{
    if !(
        _x isEqualType []
        && {count _x isEqualTo 2}
        && {(_x select 0) isEqualType ""}
        && {[(_x select 1)] call _isSimpleValue}
    ) exitWith {
        _valid = false;
    };
} forEach _definition;

if (!_valid) exitWith {
    diag_log format ["[MWF Missions] Mission definition validation failed in %1.", _missionPath];
    []
};

_definition
