/*
    Author: Theane / ChatGPT
    Function: fn_handleCivilianCasualty
    Project: Military War Framework

    Description:
    Applies a civilian casualty reputation penalty when a civilian death can be
    attributed to a player-controlled actor.

    Parameters:
    0: Civilian unit killed
    1: Resolved player actor (or objNull)
    2: Player UID (optional)
    3: Player name (optional)
*/

if (!isServer) exitWith {};

params [
    ["_killed", objNull, [objNull]],
    ["_actor", objNull, [objNull]],
    ["_uid", "", [""]],
    ["_name", "Unknown", [""]]
];

if (isNull _killed) exitWith {};
if !(_killed isKindOf "CAManBase") exitWith {};
if ((side group _killed) != civilian) exitWith {};
if (_killed getVariable ["MWF_CivCasualtyProcessed", false]) exitWith {};
if (_killed getVariable ["MWF_SuppressCivilianRepPenalty", false]) exitWith {};

_killed setVariable ["MWF_CivCasualtyProcessed", true];

private _penalty = missionNamespace getVariable ["MWF_CivRep_Penalty_CivilianDeath", 2];
_penalty = _penalty max 0;
if (_penalty <= 0) exitWith {};

private _casualties = (missionNamespace getVariable ["MWF_CivilianCasualties", 0]) + 1;
missionNamespace setVariable ["MWF_CivilianCasualties", _casualties, true];

private _pos = getPosATL _killed;
private _locationLabel = "an unknown area";

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _bestZone = objNull;
private _bestDist = 1e10;
{
    if (!isNull _x) then {
        private _zoneRange = _x getVariable ["MWF_zoneRange", 300];
        private _dist = _pos distance2D _x;
        if (_dist <= (_zoneRange * 1.15) && {_dist < _bestDist}) then {
            _bestZone = _x;
            _bestDist = _dist;
        };
    };
} forEach _zones;

if (!isNull _bestZone) then {
    _locationLabel = _bestZone getVariable ["MWF_zoneName", _locationLabel];
} else {
    private _locations = nearestLocations [_pos, ["NameCityCapital", "NameCity", "NameVillage", "NameLocal"], 600];
    if ((count _locations) > 0) then {
        private _label = text (_locations # 0);
        if !(_label isEqualTo "") then {
            _locationLabel = _label;
        };
    };
};

["ADJUST", -_penalty] call MWF_fnc_civRep;

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
} else {
    ["Civilian Casualty"] call MWF_fnc_saveGame;
};

private _message = format ["Civilian casualty reported near %1. Reputation -%2.", _locationLabel, _penalty];
[_message] remoteExec ["systemChat", 0];

if (!isNull _actor && {isPlayer _actor}) then {
    ["TaskFailed", ["", _message]] remoteExec ["BIS_fnc_showNotification", owner _actor];
};

diag_log format [
    "[MWF REP] Civilian casualty penalized. Actor: %1 (%2) | Location: %3 | Penalty: -%4 | Total Casualties: %5 | Pos: %6",
    _name,
    _uid,
    _locationLabel,
    _penalty,
    _casualties,
    _pos
];
