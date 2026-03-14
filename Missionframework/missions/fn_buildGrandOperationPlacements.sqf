/*
    Author: Theane / ChatGPT
    Function: fn_buildGrandOperationPlacements
    Project: Military War Framework

    Description:
    Generates session-based, non-persistent placement anchors for future grand operations.
    These placements follow the same runtime-only placement rule as side missions.

    Return:
    Array of grand operation placement records:
    [operationIndex, positionATL, zoneId, zoneName]
*/

if (!isServer) exitWith {[]};

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _placements = [];

if (_zones isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", [], true];
    []
};

private _anchorsToCreate = ((count _zones) min 3) max 1;
private _shuffledZones = +_zones;
_shuffledZones = _shuffledZones call BIS_fnc_arrayShuffle;

for "_i" from 0 to (_anchorsToCreate - 1) do {
    private _zone = _shuffledZones # _i;
    private _zonePos = getPosWorld _zone;
    private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
    private _position = [_zonePos, (_zoneRange * 0.2) max 40, (_zoneRange * 0.75) max 120, 5, 0, 0.3, 0, [], [_zonePos, _zonePos]] call BIS_fnc_findSafePos;

    if (_position isEqualTo _zonePos) then {
        _position = +_zonePos;
    };

    _placements pushBack [
        _i,
        _position,
        _zone getVariable ["MWF_zoneID", format ["grandop_zone_%1", _i]],
        _zone getVariable ["MWF_zoneName", "Unknown Area"]
    ];
};

missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", _placements, true];
_placements
