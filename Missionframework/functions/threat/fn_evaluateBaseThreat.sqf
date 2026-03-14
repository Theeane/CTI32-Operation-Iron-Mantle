/*
    Author: Theane / ChatGPT
    Function: fn_evaluateBaseThreat
    Project: Military War Framework

    Description:
    Evaluates strategic pressure against player bases and FOBs.
    Returns a hashMap with base pressure and attack posture data.
*/

params [
    ["_globalThreatLevel", 0, [0]],
    ["_pressureScore", 0, [0]],
    ["_fobPositions", [], [[]]],
    ["_incidentLog", [], [[]]]
];

private _basePositions = [];

{
    private _pos = [];
    if (_x isEqualType []) then {
        private _first = _x param [0, []];
        if (_first isEqualType []) then {
            _pos = _first;
        };
        if (_first isEqualType objNull) then {
            if (!isNull _first) then {
                _pos = getPosWorld _first;
            };
        };
    };

    if ((_pos isEqualType []) && {count _pos >= 2}) then {
        _basePositions pushBack _pos;
    };
} forEach _fobPositions;

private _mobPos = getMarkerPos "respawn_west";
if ((_mobPos isEqualType []) && {count _mobPos >= 2} && {_mobPos distance2D [0,0,0] > 5}) then {
    _basePositions pushBackUnique _mobPos;
};

private _recentBaseIncidents = 0;
{
    private _incidentType = _x param [1, "", [""]];
    if (_incidentType in ["fob_discovered", "base_attack", "base_probe"]) then {
        _recentBaseIncidents = _recentBaseIncidents + (_x param [3, 0, [0]]);
    };
} forEach _incidentLog;

private _basePressure = (_globalThreatLevel * 12) + (_pressureScore * 0.10) + ((count _basePositions) * 4) + (_recentBaseIncidents * 3);
private _attackState = "idle";

switch (true) do {
    case (_basePressure >= 70): { _attackState = "assault_window"; };
    case (_basePressure >= 45): { _attackState = "hunt_window"; };
    case (_basePressure >= 25): { _attackState = "searching"; };
    default { _attackState = "idle"; };
};

createHashMapFromArray [
    ["baseCount", count _basePositions],
    ["basePressure", _basePressure],
    ["baseAttackState", _attackState],
    ["basePositions", _basePositions]
]
