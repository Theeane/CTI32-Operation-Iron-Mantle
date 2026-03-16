/*
    Author: Theane / ChatGPT
    Function: MWF_fn_getBuildAssetCost
    Project: Military War Framework

    Description:
    Derives a dynamic supply cost for Zeus base-building assets using generic size
    scanning instead of a hardcoded flat price.
*/

params [["_input", "", ["", objNull]]];

private _className = if (_input isEqualType objNull) then {
    if (isNull _input) then { "" } else { typeOf _input };
} else {
    _input;
};

if (_className isEqualTo "") exitWith { 25 };

private _diameter = sizeOf _className;
private _width = _diameter max 1;
private _length = _diameter max 1;
private _height = 2;
private _probe = objNull;

try {
    _probe = createSimpleObject [_className, [0, 0, 0], true];
} catch {
    _probe = objNull;
};

if (!isNull _probe) then {
    private _bb = boundingBoxReal _probe;
    if ((count _bb) >= 2) then {
        private _min = _bb # 0;
        private _max = _bb # 1;
        _width = abs ((_max # 0) - (_min # 0)) max 1;
        _length = abs ((_max # 1) - (_min # 1)) max 1;
        _height = abs ((_max # 2) - (_min # 2)) max 1;
        _diameter = _diameter max (_width max _length);
    };
    deleteVehicle _probe;
};

private _volumeHint = (_width * _length * ((_height min 6) max 1));
private _cost = ceil ((_diameter * 1.25) + (sqrt _volumeHint));

if (_className isKindOf ["House", configFile >> "CfgVehicles"] || {_className isKindOf ["Building", configFile >> "CfgVehicles"]}) then {
    _cost = _cost + 10;
};

if (_className isKindOf ["StaticWeapon", configFile >> "CfgVehicles"]) then {
    _cost = _cost + 15;
};

_cost max 5 min 150
