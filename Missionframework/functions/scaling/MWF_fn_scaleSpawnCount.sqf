/*
    Author: Theane / ChatGPT
    Function: MWF_fn_scaleSpawnCount
    Project: Military War Framework

    Description:
    Scales a base count by a multiplier while keeping result gameplay-safe.
*/

params [
    ["_baseCount", 0, [0]],
    ["_multiplier", 1, [0]],
    ["_min", 0, [0]],
    ["_max", 1000000, [0]]
];

private _resolvedBase = _baseCount max 0;
private _resolvedMultiplier = _multiplier max 0;
private _scaled = round (_resolvedBase * _resolvedMultiplier);

if (_resolvedBase > 0 && {_resolvedMultiplier > 0} && {_scaled < 1}) then {
    _scaled = 1;
};

(_scaled max _min) min _max
