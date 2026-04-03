params [
    ["_className", "", [""]],
    ["_truepos", [0, 0, 0], [[]]],
    ["_dist", 4, [0]],
    ["_ghost", objNull, [objNull]],
    ["_sourceTerminal", objNull, [objNull]]
];

if (_className isEqualTo "") exitWith { [false, "Vehicle class missing."] };

private _surfaceRule = if (_className isKindOf "Ship") then { "WATER" } else { "LAND" };
private _playerPos = getPos player;

if (((surfaceIsWater _truepos) || (surfaceIsWater _playerPos)) && { _surfaceRule != "WATER" }) exitWith {
    [false, "This vehicle must be placed on land."]
};
if ((_surfaceRule == "WATER") && { !(surfaceIsWater _truepos) }) exitWith {
    [false, "Watercraft must be placed on water."]
};

private _nearObjects = _truepos nearObjects ["AllVehicles", _dist];
private _nearObjectsWide = _truepos nearObjects ["AllVehicles", 50];
if (_surfaceRule != "WATER") then {
    _nearObjects = _nearObjects + (_truepos nearObjects ["Static", _dist]);
    _nearObjectsWide = _nearObjectsWide + (_truepos nearObjects ["Static", 50]);
};

private _filterObjects = {
    params ["_objects"];
    private _out = [];
    {
        if (!isNull _x && {_x != _ghost} && {_x != player} && {_x != _sourceTerminal}) then {
            private _type = typeOf _x;
            if (!(_x isKindOf "Animal") && !(_type isKindOf "CAManBase") && !(isPlayer _x)) then {
                _out pushBack _x;
            };
        };
    } forEach _objects;
    _out
};

_nearObjects = [_nearObjects] call _filterObjects;
_nearObjectsWide = [_nearObjectsWide] call _filterObjects;

private _unique = [];
{ if !(_x in _unique) then { _unique pushBack _x; }; } forEach _nearObjects;
_nearObjects = _unique;
_unique = [];
{ if !(_x in _unique) then { _unique pushBack _x; }; } forEach _nearObjectsWide;
_nearObjectsWide = _unique;

if ((count _nearObjects) == 0) then {
    {
        private _dist22 = 0.6 * (sizeOf (typeOf _x));
        if (_dist22 < 1) then { _dist22 = 1; };
        if ((_truepos distance _x) < _dist22) then {
            _nearObjects pushBack _x;
        };
    } forEach _nearObjectsWide;
};

if ((count _nearObjects) > 0) exitWith {
    private _label = getText (configFile >> "CfgVehicles" >> typeOf (_nearObjects select 0) >> "displayName");
    if (_label isEqualTo "") then { _label = typeOf (_nearObjects select 0); };
    [false, format ["Placement blocked by %1.", _label]]
};

[true, "Placement valid."]
