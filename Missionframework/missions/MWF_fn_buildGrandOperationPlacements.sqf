/*
    Author: Theane / ChatGPT
    Function: fn_buildGrandOperationPlacements
    Project: Military War Framework

    Description:
    Generates session-based, non-persistent placement anchors for grand operations.
    Main operations prefer enemy-held zones and avoid the MOB/FOB staging spaces.
*/

if (!isServer) exitWith {[]};

private _zones = (missionNamespace getVariable ["MWF_all_mission_zones", []]) select { !isNull _x };
private _placements = [];

if (_zones isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", [], true];
    []
};

private _mobRef = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
private _mobPos = if (!isNull _mobRef) then { getPosATL _mobRef } else { getMarkerPos "respawn_west" };
private _fobObjects = (missionNamespace getVariable ["MWF_FOB_Registry", []]) apply { _x param [1, objNull, [objNull]] };
private _fobPositions = (_fobObjects select { !isNull _x }) apply { getPosATL _x };
private _distanceSteps = [
    [1000, 2000],
    [750, 1500],
    [500, 1000],
    [250, 500],
    [100, 100]
];

private _enemyZones = _zones select {
    private _owner = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
    _owner isEqualTo "enemy"
};

private _isValidZone = {
    params ["_zone", "_mobMin", "_fobMin"];
    private _zonePos = getPosATL _zone;
    if ((_mobPos distance2D _zonePos) < _mobMin) exitWith { false };
    ((_fobPositions findIf { (_x distance2D _zonePos) < _fobMin }) < 0)
};

private _candidateZones = [];
{
    _x params ["_mobMin", "_fobMin"];
    _candidateZones = _enemyZones select { [_x, _mobMin, _fobMin] call _isValidZone };
    if (_candidateZones isNotEqualTo []) exitWith {};
} forEach _distanceSteps;

if (_candidateZones isEqualTo []) then {
    _candidateZones = _enemyZones;
};

if (_candidateZones isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_GrandOperationSessionPlacements", [], true];
    []
};

private _anchorsToCreate = ((count _candidateZones) min 3) max 1;
private _shuffledZones = +_candidateZones;
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
