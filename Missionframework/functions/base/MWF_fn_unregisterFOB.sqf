/*
    Author: Theane / ChatGPT
    Function: fn_unregisterFOB
    Project: Military War Framework

    Description:
    Removes a FOB from the active registry and persistence list, cleans up its marker,
    and removes its native Arma respawn position.
*/

if (!isServer) exitWith {false};

params [
    ["_target", objNull, [objNull]],
    ["_markerName", "", [""]],
    ["_requestSave", true, [true]]
];

private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
private _matchPos = if (!isNull _target) then { getPosASL _target } else { [] };

if (_markerName isEqualTo "" && {!isNull _target}) then {
    _markerName = _target getVariable ["MWF_FOB_Marker", ""];
};

private _displayName = "";
private _removedObject = _target;
private _newRegistry = [];
{
    _x params ["_entryMarker", "_entryObject", ["_entryName", "", [""]]];
    private _remove = false;

    if (_markerName != "" && {_entryMarker == _markerName}) then { _remove = true; };
    if (!_remove && {!isNull _target} && {_entryObject == _target}) then { _remove = true; };

    if (_remove) then {
        _displayName = _entryName;
        if (isNull _removedObject) then {
            _removedObject = _entryObject;
        };
    } else {
        _newRegistry pushBack _x;
    };
} forEach _registry;

missionNamespace setVariable ["MWF_FOB_Registry", _newRegistry, true];

if (!isNull _removedObject) then {
    private _respawnId = _removedObject getVariable ["MWF_FOB_RespawnId", -1];
    if (_respawnId isEqualType 0 && {_respawnId >= 0}) then {
        [west, _respawnId] call BIS_fnc_removeRespawnPosition;
        _removedObject setVariable ["MWF_FOB_RespawnId", -1, true];
    };
};

if (_markerName != "" && {!((markerShape _markerName) isEqualTo "")}) then {
    deleteMarker _markerName;
};

private _fobPosList = missionNamespace getVariable ["MWF_FOB_Positions", []];
if (!(_matchPos isEqualTo [])) then {
    _fobPosList = _fobPosList select {
        private _savedPos = _x param [0, []];
        !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance _matchPos <= 5})
    };
} else {
    if (_displayName != "") then {
        _fobPosList = _fobPosList select { (_x param [2, ""]) != _displayName };
    };
};
missionNamespace setVariable ["MWF_FOB_Positions", _fobPosList, true];

if (!isNull _removedObject && {!isNil "MWF_fnc_unregisterLoadoutZone"}) then {
    [_removedObject] call MWF_fnc_unregisterLoadoutZone;
};

if (_requestSave && {!isNil "MWF_fnc_requestDelayedSave"}) then {
    [] call MWF_fnc_requestDelayedSave;
};

true
