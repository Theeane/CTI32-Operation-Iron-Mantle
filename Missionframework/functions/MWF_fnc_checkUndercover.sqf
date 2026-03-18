/*
    Author: OpenAI
    Function: MWF_fnc_checkUndercover
    Project: Military War Framework

    Description:
    Central uniform-driven undercover check.
    - OPFOR uniform: military disguise active and respawn-loadout saving blocked.
    - Civilian uniform: civilian disguise only if no vest and no carried weapons.
*/

params [
    ["_player", objNull, [objNull]]
];

if (isNull _player) exitWith { false };

[] call MWF_fnc_buildLoadoutCaches;

private _uniform = uniform _player;
private _opforUniforms = missionNamespace getVariable ["MWF_OpforUniformClasses", []];
private _civilianUniforms = missionNamespace getVariable ["MWF_CivilianUniformClasses", []];

private _hasOpforUniform = _uniform in _opforUniforms;
private _hasCivilianUniform = _uniform in _civilianUniforms;
private _hasVest = (vest _player) != "";
private _armed = (primaryWeapon _player) != "" || {(handgunWeapon _player) != ""} || {(secondaryWeapon _player) != ""};

private _isUndercover = false;
if (_hasOpforUniform) then {
    _isUndercover = true;
} else {
    if (_hasCivilianUniform && {!_hasVest} && {!_armed}) then {
        _isUndercover = true;
    };
};

_player setVariable ["MWF_isUndercover", _isUndercover, true];
missionNamespace setVariable ["MWF_SaveLoadout_Enabled", !_hasOpforUniform, true];

_isUndercover
