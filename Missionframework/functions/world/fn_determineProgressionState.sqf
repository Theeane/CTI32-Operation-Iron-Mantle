/*
    Author: Theane / ChatGPT
    Function: fn_determineProgressionState
    Project: Military War Framework

    Description:
    Converts strategic control metrics into a readable campaign phase label.
*/

if (!isServer) exitWith {"opening"};

params [
    ["_mapControl", 0, [0]],
    ["_capturedCount", 0, [0]],
    ["_capitalCount", 0, [0]],
    ["_contestedCount", 0, [0]],
    ["_underAttackCount", 0, [0]]
];

private _state = "opening";

if (_capturedCount > 0 || _mapControl >= 5) then {
    _state = "foothold";
};

if (_mapControl >= 20) then {
    _state = "expansion";
};

if (_contestedCount > 0 || _underAttackCount > 0) then {
    _state = "contested";
};

if (_mapControl >= 50) then {
    _state = "dominance";
};

if (_capitalCount > 0 || _mapControl >= 80) then {
    _state = "endgame";
};

_state
