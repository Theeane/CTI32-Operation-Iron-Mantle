/*
    Author: OpenAI / ChatGPT
    Function: fn_applyLeaderAppearance
    Project: Military War Framework

    Description:
    Applies the shared endgame leader appearance layer.
    The preset leader class still controls baseline uniform / weapons / gear.
    This adds the common red beret marker plus optional face / beard polish.
*/
if (!isServer) exitWith { false };

params [
    ["_unit", objNull, [objNull]]
];
if (isNull _unit) exitWith { false };

private _redBeret = missionNamespace getVariable ["MWF_EndgameLeader_RedBeret", "H_Beret_Colonel"];
if (_redBeret isNotEqualTo "" && {isClass (configFile >> "CfgWeapons" >> _redBeret)}) then {
    removeHeadgear _unit;
    _unit addHeadgear _redBeret;
};

private _facePool = [];
private _asczFaces = +(missionNamespace getVariable ["MWF_EndgameLeader_ASCZFaces", []]);
private _vanillaFaces = +(missionNamespace getVariable ["MWF_EndgameLeader_VanillaFaces", []]);

// Prefer ASCZ faces when available, otherwise fallback to vanilla.
{
    if (_x isEqualType "" && {_x != ""}) then { _facePool pushBackUnique _x; };
} forEach _asczFaces;
if (_facePool isEqualTo []) then {
    {
        if (_x isEqualType "" && {_x != ""}) then { _facePool pushBackUnique _x; };
    } forEach _vanillaFaces;
};
if (_facePool isNotEqualTo []) then {
    _unit setFace (selectRandom _facePool);
};

private _beards = +(missionNamespace getVariable ["MWF_EndgameLeader_Beards", []]);
private _beard = if (_beards isEqualTo []) then {""} else {selectRandom _beards};
if (_beard isNotEqualTo "") then {
    if (isClass (configFile >> "CfgGlasses" >> _beard)) then {
        removeGoggles _unit;
        _unit addGoggles _beard;
    } else {
        if (isClass (configFile >> "CfgWeapons" >> _beard)) then {
            removeGoggles _unit;
            _unit addGoggles _beard;
        };
    };
};

true
