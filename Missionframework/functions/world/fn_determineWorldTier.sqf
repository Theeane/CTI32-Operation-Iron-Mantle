/*
    Author: Theane / ChatGPT
    Function: fn_determineWorldTier
    Project: Military War Framework

    Description:
    Converts strategic world-control metrics into a stable campaign world tier.
    This tier is separate from base purchase tier and is intended for world, threat,
    and mission systems.
*/

if (!isServer) exitWith {1};

params [
    ["_mapControl", 0, [0]],
    ["_capturedCount", 0, [0]],
    ["_capitalCount", 0, [0]],
    ["_factoryCount", 0, [0]],
    ["_militaryCount", 0, [0]]
];

private _tier = 1;

if (_capturedCount >= 2 || _mapControl >= 10) then {
    _tier = 2;
};

if (_mapControl >= 25 || _factoryCount >= 1 || _militaryCount >= 1) then {
    _tier = 3;
};

if (_mapControl >= 50 || _factoryCount >= 2 || _militaryCount >= 2) then {
    _tier = 4;
};

if (_mapControl >= 75 || _capitalCount >= 1) then {
    _tier = 5;
};

_tier
