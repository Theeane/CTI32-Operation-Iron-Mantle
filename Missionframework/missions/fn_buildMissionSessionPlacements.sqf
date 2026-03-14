/*
    Author: Theane / ChatGPT
    Function: fn_buildMissionSessionPlacements
    Project: Military War Framework

    Description:
    Generates non-persistent session placements for every discovered mission template.
    Placements are randomized per server runtime, remain fixed during the runtime,
    and regenerate on restart.

    Return:
    Array of placement records:
    [missionKey, positionATL, zoneId, zoneName]
*/

if (!isServer) exitWith {[]};

params [
    ["_templates", [], [[]]]
];

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _placements = [];

if (_zones isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_MissionSessionPlacements", [], true];
    []
};

private _pickPlacement = {
    params ["_zone"];

    private _zonePos = getPosWorld _zone;
    private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
    private _safeRadius = (_zoneRange * 0.25) max 40;
    private _spawnRadius = (_zoneRange * 0.7) max 120;
    private _candidate = [_zonePos, _safeRadius, _spawnRadius, 5, 0, 0.3, 0, [], [_zonePos, _zonePos]] call BIS_fnc_findSafePos;

    if (_candidate isEqualTo _zonePos) then {
        private _angle = random 360;
        private _distance = _safeRadius + random ((_spawnRadius - _safeRadius) max 25);
        _candidate = [
            (_zonePos # 0) + ((sin _angle) * _distance),
            (_zonePos # 1) + ((cos _angle) * _distance),
            0
        ];
    };

    _candidate
};

{
    _x params ["_missionKey"];

    private _zone = selectRandom _zones;
    private _zoneId = _zone getVariable ["MWF_zoneID", "unknown_zone"];
    private _zoneName = _zone getVariable ["MWF_zoneName", "Unknown Area"];
    private _position = [_zone] call _pickPlacement;

    _placements pushBack [_missionKey, _position, _zoneId, _zoneName];
} forEach _templates;

missionNamespace setVariable ["MWF_MissionSessionPlacements", _placements, true];
_placements
