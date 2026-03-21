/*
    Author: Theane / ChatGPT
    Function: fn_getMainOperationState
    Project: Military War Framework

    Description:
    Returns the runtime state for a main operation, including cooldown,
    placeholder Intel cost, and whether a free-charge will make the next
    operation cost-free.

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
        ["tooltipText", "Operation metadata unavailable."],
        ["intelCost", 0],
        ["effectiveIntelCost", 0],
        ["freeChargeAvailable", false],
        ["canAfford", false]
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
    ["_cooldownSeconds", 3600, [0]],
    ["_intelCost", 0, [0]]
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

private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _freeCharges = missionNamespace getVariable ["MWF_FreeMainOpCharges", 0];
private _freeChargeAvailable = _freeCharges > 0;
private _effectiveIntelCost = if (_freeChargeAvailable) then { 0 } else { _intelCost max 0 };
private _canAfford = _freeChargeAvailable || {_currentIntel >= _effectiveIntelCost};

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
    } else {
        if (!_canAfford) then {
            _state = "insufficient_intel";
            _statusText = format ["Requires %1 Intel", _effectiveIntelCost];
            _tooltip = format ["%1 requires %2 Intel. Current Intel: %3.", _title, _effectiveIntelCost, _currentIntel];
        } else {
            if (_freeChargeAvailable && {_intelCost > 0}) then {
                _statusText = format ["Available | FREE (%1 charge)", _freeCharges];
                _tooltip = format ["%1 is ready. A stored intel breakthrough makes this launch free.", _title];
            } else {
                _statusText = if (_intelCost > 0) then {
                    format ["Available | Cost: %1 Intel", _effectiveIntelCost]
                } else {
                    "Available"
                };
                _tooltip = if (_intelCost > 0) then {
                    format ["%1 is ready to accept for %2 Intel.", _title, _effectiveIntelCost]
                } else {
                    format ["%1 is ready to accept.", _title]
                };
            };
        };
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
    ["tooltipText", _tooltip],
    ["intelCost", _intelCost max 0],
    ["effectiveIntelCost", _effectiveIntelCost max 0],
    ["freeChargeAvailable", _freeChargeAvailable],
    ["freeChargeCount", _freeCharges max 0],
    ["canAfford", _canAfford]
]
