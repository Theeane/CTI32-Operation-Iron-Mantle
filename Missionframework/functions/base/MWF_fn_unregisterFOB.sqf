/*
    Author: Theane / ChatGPT
    Function: fn_unregisterFOB
    Project: Military War Framework

    Description:
    Removes a FOB from the active registry and persistence list and cleans up its marker.
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
private _newRegistry = [];
{
    _x params ["_entryMarker", "_entryObject", ["_entryName", "", [""]]];
    private _remove = false;

    if (_markerName != "" && {_entryMarker == _markerName}) then { _remove = true; };
    if (!_remove && {!isNull _target} && {_entryObject == _target}) then { _remove = true; };

    if (_remove) then {
        _displayName = _entryName;
    } else {
        _newRegistry pushBack _x;
    };
} forEach _registry;

missionNamespace setVariable ["MWF_FOB_Registry", _newRegistry, true];

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

if (!isNull _target && {!isNil "MWF_fnc_unregisterLoadoutZone"}) then {
    [_target] call MWF_fnc_unregisterLoadoutZone;
};

if (_requestSave && {!isNil "MWF_fnc_requestDelayedSave"}) then {
    [] call MWF_fnc_requestDelayedSave;
};

true
