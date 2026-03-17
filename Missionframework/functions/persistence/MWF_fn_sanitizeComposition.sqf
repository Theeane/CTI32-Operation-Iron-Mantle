/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_sanitizeComposition
    Project: Military War Framework (MWF)

    Description:
    Security-oriented composition sanitizer for Zeus build mode. Recursively walks
    a composition-style array and removes all entities that resolve to Man classes,
    while keeping structures, vehicles, props, and malformed/unknown non-unit data intact.

    Input:
        0: Composition/entity array <ARRAY>

    Output:
        <ARRAY> Sanitized composition array with unit entities removed.

    Usage:
        private _clean = [_rawComposition] call MWF_fnc_sanitizeComposition;
*/

if (!isServer) exitWith { [] };

params [
    ["_composition", [], [[]]]
];

private _removedCount = 0;
private _keptCount = 0;
private _malformedCount = 0;

private _sanitizeNode = {
    params ["_node"];

    if (!(_node isEqualType [])) exitWith {
        _keptCount = _keptCount + 1;
        _node
    };

    if (_node isEqualTo []) exitWith { [] };

    private _first = _node param [0, objNull];

    // Treat arrays whose first entry is a classname string as composition entity definitions.
    if (_first isEqualType "") exitWith {
        private _className = _first;

        if (_className isEqualTo "") then {
            _malformedCount = _malformedCount + 1;
            diag_log "[MWF Sanitize] Malformed composition entity encountered with empty classname. Entry skipped.";
            []
        } else {
            private _cfg = configFile >> "CfgVehicles" >> _className;
            if (isClass _cfg && { _className isKindOf ["Man", configFile >> "CfgVehicles"] }) then {
                _removedCount = _removedCount + 1;
                diag_log format ["[MWF Sanitize] Removed unit entity from composition: %1", _className];
                []
            } else {
                _keptCount = _keptCount + 1;
                _node
            };
        };
    };

    // Nested array/grouping. Recurse and preserve structure.
    private _result = [];
    {
        private _cleaned = [_x] call _sanitizeNode;

        if (_cleaned isEqualType [] && { _cleaned isEqualTo [] }) then {
            // Deliberately skip empty removals.
        } else {
            _result pushBack _cleaned;
        };
    } forEach _node;

    _result
};

private _sanitized = [_composition] call _sanitizeNode;

private _totalProcessed = _removedCount + _keptCount + _malformedCount;
diag_log format [
    "[MWF Sanitize] Processed %1 composition node(s). Removed units: %2, kept entities/data: %3, malformed skipped: %4.",
    _totalProcessed,
    _removedCount,
    _keptCount,
    _malformedCount
];

_sanitized
