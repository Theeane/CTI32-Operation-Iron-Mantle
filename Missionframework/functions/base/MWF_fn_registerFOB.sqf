/*
    Author: Theane / ChatGPT
    Function: fn_registerFOB
    Project: Military War Framework

    Description:
    Registers a live FOB terminal in the active registry, creates/refreshes its marker,
    and updates the strategic persistence list used by save/load, threat, and rebel systems.
    Campaign tutorial progression is handled by the deployment pipeline after a successful player-chosen deploy.
*/

if (!isServer) exitWith {[]};

params [
    ["_terminal", objNull, [objNull]],
    ["_displayName", "", [""]],
    ["_originType", "TRUCK", [""]],
    ["_requestSave", true, [true]]
];

if (isNull _terminal) exitWith {[]};

private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
_registry = _registry select { (_x param [1, objNull]) != _terminal };

if (_displayName isEqualTo "") then {
    _displayName = format ["FOB %1", (count _registry) + 1];
};

private _markerName = _terminal getVariable ["MWF_FOB_Marker", ""];
if (_markerName isEqualTo "") then {
    _markerName = format ["fob_marker_%1", round (random 999999)];
};

private _markerPos = getPosATL _terminal;
if ((markerShape _markerName) isEqualTo "") then {
    createMarker [_markerName, _markerPos];
} else {
    _markerName setMarkerPos _markerPos;
};

_markerName setMarkerType "b_hq";
_markerName setMarkerText _displayName;
_markerName setMarkerColor "ColorBLUFOR";

_terminal setVariable ["MWF_isFOB", true, true];
_terminal setVariable ["MWF_FOB_Marker", _markerName, true];
_terminal setVariable ["MWF_FOB_DisplayName", _displayName, true];
_terminal setVariable ["MWF_FOB_OriginType", _originType, true];

_registry pushBack [_markerName, _terminal, _displayName, _originType];
missionNamespace setVariable ["MWF_FOB_Registry", _registry, true];

private _fobPosList = missionNamespace getVariable ["MWF_FOB_Positions", []];
private _posAsl = getPosASL _terminal;
_fobPosList = _fobPosList select {
    private _savedPos = _x param [0, []];
    !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance _posAsl <= 5})
};
_fobPosList pushBack [_posAsl, getDir _terminal, _displayName, _originType];
missionNamespace setVariable ["MWF_FOB_Positions", _fobPosList, true];

if (_requestSave && {!isNil "MWF_fnc_requestDelayedSave"}) then {
    [] call MWF_fnc_requestDelayedSave;
};

[_markerName, _displayName]
