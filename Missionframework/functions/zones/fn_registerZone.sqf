/*
    Author: Theane / ChatGPT
    Function: fn_registerZone
    Project: Military War Framework

    Description:
    Normalizes a zone object, ensures required variables exist, and inserts it into the mission zone registry.
*/

if (!isServer) exitWith {objNull};

params [
    ["_zone", objNull, [objNull]]
];

if (isNull _zone) exitWith {objNull};

private _zoneId = toLower (_zone getVariable ["MWF_zoneID", format ["zone_%1", _zone call BIS_fnc_netId]]);
private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
private _zoneName = _zone getVariable ["MWF_zoneName", format ["%1 Zone", _zoneType]];
private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
private _ownerState = toLower (_zone getVariable ["MWF_zoneOwnerState", if (_zone getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
private _isCaptured = _zone getVariable ["MWF_isCaptured", _ownerState isEqualTo "player"];

_zone setVariable ["MWF_zoneID", _zoneId, true];
_zone setVariable ["MWF_zoneType", _zoneType, true];
_zone setVariable ["MWF_zoneName", _zoneName, true];
_zone setVariable ["MWF_zoneRange", _zoneRange, true];
_zone setVariable ["MWF_zoneOwnerState", _ownerState, true];
_zone setVariable ["MWF_isCaptured", _isCaptured, true];
_zone setVariable ["MWF_underAttack", _zone getVariable ["MWF_underAttack", false], true];
_zone setVariable ["MWF_contested", _zone getVariable ["MWF_contested", false], true];
_zone setVariable ["MWF_capProgress", _zone getVariable ["MWF_capProgress", if (_isCaptured) then {100} else {0}], true];

private _registry = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _existingIndex = _registry findIf { !isNull _x && { toLower (_x getVariable ["MWF_zoneID", ""]) isEqualTo _zoneId } };

if (_existingIndex < 0) then {
    _registry pushBack _zone;
} else {
    _registry set [_existingIndex, _zone];
};

missionNamespace setVariable ["MWF_all_mission_zones", _registry, true];

if (!isNil "MWF_fnc_syncZoneMarker") then {
    [_zone] call MWF_fnc_syncZoneMarker;
};

_zone
