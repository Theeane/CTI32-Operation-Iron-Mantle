/*
    Author: Theane / ChatGPT
    Function: fn_buildThreatResponses
    Project: Military War Framework

    Description:
    Builds a prioritized response queue from threat directives and zone targets.
    Returns an array of hashMaps ordered by priority.
*/

params [
    ["_globalThreatLevel", 0, [0]],
    ["_globalThreatState", "low", [""]],
    ["_priorityTargets", [], [[]]],
    ["_directives", createHashMap, [createHashMap]],
    ["_baseThreat", createHashMap, [createHashMap]]
];

private _queueSortable = [];

{
    private _zoneId = _x getOrDefault ["zoneId", ""];
    private _profile = _x getOrDefault ["responseProfile", "monitor"];
    private _priority = _x getOrDefault ["priorityScore", 0];
    private _type = if (_x getOrDefault ["threatLevel", 0] >= 4) then {"counterattack"} else {"pressure"};
    _queueSortable pushBack [0 - (_priority + 15), _type, _zoneId, _profile, _priority];
} forEach _priorityTargets;

private _enabledResponses = _directives getOrDefault ["enabledResponses", []];
private _roadblockPressure = _directives getOrDefault ["roadblockPressure", 0];
private _hqPressure = _directives getOrDefault ["hqPressure", 0];
private _basePressure = _baseThreat getOrDefault ["basePressure", 0];
private _baseAttackState = _baseThreat getOrDefault ["baseAttackState", "idle"];

if ("qrf" in _enabledResponses) then {
    _queueSortable pushBack [0 - (25 + (_globalThreatLevel * 6)), "qrf", "", _globalThreatState, 25 + (_globalThreatLevel * 6)];
};

if ("patrol_surge" in _enabledResponses) then {
    _queueSortable pushBack [0 - (18 + (_globalThreatLevel * 5)), "patrol_surge", "", "screening", 18 + (_globalThreatLevel * 5)];
};

if ("roadblocks" in _enabledResponses) then {
    _queueSortable pushBack [0 - _roadblockPressure, "roadblock_network", "", "roadblock_pressure", _roadblockPressure];
};

if ("hq_reinforcement" in _enabledResponses) then {
    _queueSortable pushBack [0 - _hqPressure, "hq_reinforcement", "", "hq_pressure", _hqPressure];
};

if ("base_search" in _enabledResponses) then {
    _queueSortable pushBack [0 - _basePressure, "base_search", "", _baseAttackState, _basePressure];
};

if ("base_attack" in _enabledResponses) then {
    _queueSortable pushBack [0 - (_basePressure + 10), "base_attack", "", _baseAttackState, _basePressure + 10];
};

_queueSortable sort true;

private _queue = [];
{
    if (_forEachIndex < 8) then {
        _queue pushBack (createHashMapFromArray [
            ["priority", 0 - (_x param [0, 0, [0]])],
            ["type", _x param [1, "", [""]]],
            ["zoneId", _x param [2, "", [""]]],
            ["profile", _x param [3, "", [""]]],
            ["score", _x param [4, 0, [0]]]
        ]);
    };
} forEach _queueSortable;

_queue
