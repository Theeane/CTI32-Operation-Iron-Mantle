/*
    Author: Theane / ChatGPT
    Function: fn_getMainOperationState
    Project: Military War Framework

    Description:
    Returns the runtime state for a main operation.

    Params:
    0: STRING - operation key
    1: ARRAY  - optional registry entry

    Return:
    HASHMAP
*/

params [
    ["_key", "", [""]],
    ["_entry", [], [[]]]
];

private _registry = if (_entry isEqualTo []) then {
    [] call MWF_fnc_getMainOperationRegistry
} else {
    [_entry]
};

private _record = if (_entry isEqualTo []) then {
    private _idx = _registry findIf { (_x # 0) isEqualTo _key };
    if (_idx >= 0) then { _registry # _idx } else { [] };
} else {
    _entry
};

if (_record isEqualTo []) exitWith {
    createHashMapFromArray [
        ["key", _key],
        ["state", "unknown"],
        ["isAvailable", false],
        ["isActive", false],
        ["isCoolingDown", false],
        ["cooldownRemaining", 0],
        ["readyAt", 0],
        ["readyClockText", "--:--"],
        ["statusText", "Unknown"],
        ["tooltipText", "Operation metadata unavailable."]
    ]
};

_record params [
    ["_recordKey", _key, [""]],
    ["_title", _key, [""]],
    "_description",
    "_functionName",
    "_impactId",
    "_effectType",
    "_effectText",
    "_fallbackText",
    ["_cooldownSeconds", 3600, [0]]
];

private _now = serverTime;
private _cooldownMap = missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap];
if (isNil "_cooldownMap" || { !(_cooldownMap isEqualType createHashMap) }) then {
    _cooldownMap = createHashMap;
};

private _readyAt = _cooldownMap getOrDefault [_recordKey, 0];
private _currentKey = missionNamespace getVariable ["MWF_CurrentGrandOperation", ""];
private _isActive = (missionNamespace getVariable ["MWF_GrandOperationActive", false]) && {_currentKey isEqualTo _recordKey};
private _cooldownRemaining = ((_readyAt - _now) max 0) call BIS_fnc_floor;
private _isCoolingDown = (!_isActive) && {_cooldownRemaining > 0};
private _state = "available";
private _statusText = "Available";
private _tooltip = format ["%1 is ready to accept.", _title];
private _readyClockText = "--:--";

if (_isCoolingDown) then {
    private _minutes = (_cooldownRemaining / 60) call BIS_fnc_floor;
    private _seconds = _cooldownRemaining mod 60;
    private _hours = (_minutes / 60) call BIS_fnc_floor;
    private _displayMinutes = _minutes mod 60;
    private _remainingText = if (_hours > 0) then {
        format ["%1h %2m", _hours, _displayMinutes]
    } else {
        format ["%1m %2s", _displayMinutes, _seconds]
    };

    private _clockHoursTotal = daytime + (_cooldownRemaining / 3600);
    private _dayOffset = floor (_clockHoursTotal / 24);
    private _clockHours = _clockHoursTotal mod 24;
    private _clockHour = floor _clockHours;
    private _clockMinute = floor (((_clockHours - _clockHour) * 60) max 0 min 59);
    _readyClockText = format ["%1:%2", [_clockHour, 2] call BIS_fnc_padNumber, [_clockMinute, 2] call BIS_fnc_padNumber];
    if (_dayOffset > 0) then {
        _readyClockText = format ["%1 (+%2d)", _readyClockText, _dayOffset];
    };

    _statusText = format ["Cooldown | Ready in %1 | ETA %2", _remainingText, _readyClockText];
    _tooltip = format ["%1 is on cooldown. Ready again in %2 at %3.", _title, _remainingText, _readyClockText];
};

if (_isActive) then {
    _state = "active";
    _statusText = "Active";
    _tooltip = format ["%1 is already active.", _title];
} else {
    if (_isCoolingDown) then {
        _state = "cooldown";
    };
};

createHashMapFromArray [
    ["key", _recordKey],
    ["title", _title],
    ["description", _description],
    ["impactId", _impactId],
    ["effectType", _effectType],
    ["effectText", _effectText],
    ["fallbackText", _fallbackText],
    ["cooldownSeconds", _cooldownSeconds],
    ["state", _state],
    ["isAvailable", _state isEqualTo "available"],
    ["isActive", _isActive],
    ["isCoolingDown", _isCoolingDown],
    ["cooldownRemaining", _cooldownRemaining],
    ["readyAt", _readyAt],
    ["readyClockText", _readyClockText],
    ["statusText", _statusText],
    ["tooltipText", _tooltip]
]
