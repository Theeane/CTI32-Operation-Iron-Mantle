/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_applyLeaderAppearance
    Description: Applies shared endgame leader visuals on top of the preset-defined unit class.
*/
params [["_leader", objNull, [objNull]]];

if (isNull _leader) exitWith { false };
if (!local _leader) exitWith { false };

private _beretClass = missionNamespace getVariable ["MWF_EndgameLeaderRedBeretClass", "H_Beret_Red"];
private _vanillaFaces = +(missionNamespace getVariable ["MWF_EndgameLeader_VanillaFaces", []]);
private _asczFaces = +(missionNamespace getVariable ["MWF_EndgameLeader_ASCZFaces", []]);
private _beards = +(missionNamespace getVariable ["MWF_EndgameLeader_Beards", []]);

removeHeadgear _leader;
if (_beretClass isNotEqualTo "") then { _leader addHeadgear _beretClass; };

private _validASCZ = _asczFaces select { _x isEqualType "" && {_x isNotEqualTo ""} && {isClass (configFile >> "CfgFaces" >> "Man_A3" >> _x)} };
private _validVanilla = _vanillaFaces select { _x isEqualType "" && {_x isNotEqualTo ""} };
private _selectedFace = "";
if !(_validASCZ isEqualTo []) then {
    _selectedFace = selectRandom _validASCZ;
} else {
    if !(_validVanilla isEqualTo []) then { _selectedFace = selectRandom _validVanilla; };
};
if (_selectedFace isNotEqualTo "") then { _leader setFace _selectedFace; };

if !(_beards isEqualTo []) then {
    private _beardClass = selectRandom _beards;
    if (_beardClass isEqualType "" && {_beardClass isNotEqualTo ""} && {((_beardClass find "MWF_BEARD_") != 0)}) then {
        removeGoggles _leader;
        if (isClass (configFile >> "CfgGlasses" >> _beardClass)) then {
            _leader addGoggles _beardClass;
        };
    };
};

true
