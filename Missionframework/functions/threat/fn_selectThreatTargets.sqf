/*
    Author: Theane / ChatGPT
    Function: fn_selectThreatTargets
    Project: Military War Framework

    Description:
    Builds a prioritized list of strategic threat targets from zone threat summaries.
    Returns an array of hashMaps sorted by descending priority.
*/

params [
    ["_zoneThreatSummaries", [], [[]]],
    ["_maxTargets", 5, [0]]
];

_maxTargets = (_maxTargets max 1) min 10;

private _sortable = [];

{
    private _zoneId = toLower (_x getOrDefault ["zoneId", ""]);
    if (_zoneId != "") then {
        private _priorityScore = _x getOrDefault ["priorityScore", 0];
        private _responseProfile = _x getOrDefault ["responseProfile", "monitor"];
        private _threatLevel = _x getOrDefault ["threatLevel", 0];
        private _threatState = _x getOrDefault ["threatState", "low"];
        private _zoneType = _x getOrDefault ["zoneType", "town"];
        _sortable pushBack [0 - _priorityScore, _zoneId, _zoneType, _threatLevel, _threatState, _responseProfile];
    };
} forEach _zoneThreatSummaries;

_sortable sort true;

private _targets = [];
{
    if (_forEachIndex < _maxTargets) then {
        _targets pushBack (createHashMapFromArray [
            ["zoneId", _x param [1, "", [""]]],
            ["zoneType", _x param [2, "town", [""]]],
            ["threatLevel", _x param [3, 0, [0]]],
            ["threatState", _x param [4, "low", [""]]],
            ["responseProfile", _x param [5, "monitor", [""]]],
            ["priorityScore", 0 - (_x param [0, 0, [0]])]
        ]);
    };
} forEach _sortable;

_targets
