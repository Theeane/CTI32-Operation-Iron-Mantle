params [
    ["_className", "", [""]],
    ["_truepos", [0,0,0], [[]]],
    ["_dir", 0, [0]],
    ["_ghost", objNull, [objNull]],
    ["_sourceTerminal", objNull, [objNull]],
    ["_vehicleType", "LAND", [""]]
];

if (_className isEqualTo "") exitWith { [false, "No vehicle class selected."] };
if (_vehicleType isEqualTo "WATER") then {
    if !(surfaceIsWater _truepos) exitWith { [false, "Boats must be placed in water."] };
} else {
    if (surfaceIsWater _truepos) exitWith { [false, "Vehicle must be placed on land."] };
};

private _dist = 0.6 * (sizeOf _className);
if (_dist < 3.5) then { _dist = 3.5; };
_dist = _dist + 1;
if (_vehicleType isEqualTo "WATER") then { _dist = _dist + 4; };
if (_vehicleType isEqualTo "AIR") then { _dist = _dist + 2; };

private _near = _truepos nearObjects ["AllVehicles", _dist];
if (_vehicleType != "AIR") then {
    _near append (_truepos nearObjects ["Static", _dist]);
};

private _filtered = [];
{
    private _obj = _x;
    if (
        !isNull _obj &&
        {_obj != _ghost} &&
        {_obj != player} &&
        {!(_obj isKindOf "Animal")} &&
        {!(_obj isKindOf "CAManBase")} &&
        {!isPlayer _obj} &&
        {isNull _sourceTerminal || {_obj != _sourceTerminal}}
    ) then {
        _filtered pushBackUnique _obj;
    };
} forEach _near;

if ((count _filtered) > 0) exitWith {
    private _label = getText (configFile >> "CfgVehicles" >> typeOf (_filtered # 0) >> "displayName");
    if (_label isEqualTo "") then { _label = typeOf (_filtered # 0); };
    [false, format ["Placement blocked by %1.", _label]]
};

[true, "Placement valid."]
