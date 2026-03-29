/*
    Author: Theane / ChatGPT
    Function: fn_registerFOB
    Project: Military War Framework

    Description:
    Registers a live FOB terminal in the active registry, creates/refreshes its marker,
    adds a native Arma respawn position for deploy selection, and updates the strategic
    persistence list used by save/load, threat, and rebel systems.
    Also maintains the shared HUD anchor registry used by clients for 500 m base HUD visibility.
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

private _hudAnchor = _terminal getVariable ["MWF_HUD_Anchor", objNull];
if (isNull _hudAnchor) then {
    _hudAnchor = _terminal;
    _terminal setVariable ["MWF_HUD_Anchor", _hudAnchor, true];
};
if (!isNull _hudAnchor) then {
    _hudAnchor setVariable ["MWF_BaseType", "FOB", true];
    _hudAnchor setVariable ["MWF_HUD_Radius", 500, true];
};

private _existingRespawnId = _terminal getVariable ["MWF_FOB_RespawnId", -1];
if (_existingRespawnId isEqualType 0 && {_existingRespawnId >= 0}) then {
    [west, _existingRespawnId] call BIS_fnc_removeRespawnPosition;
};
private _respawnId = [west, _terminal, _displayName] call BIS_fnc_addRespawnPosition;
_terminal setVariable ["MWF_FOB_RespawnId", _respawnId, true];

_registry pushBack [_markerName, _terminal, _displayName, _originType];
missionNamespace setVariable ["MWF_FOB_Registry", _registry, true];

private _hudRegistry = missionNamespace getVariable ["MWF_HUD_AnchorRegistry", []];
_hudRegistry = _hudRegistry select {
    private _anchor = _x param [0, objNull];
    !isNull _anchor && {_anchor != _hudAnchor}
};
if (!isNull _hudAnchor) then {
    _hudRegistry pushBack [_hudAnchor, "FOB", 500];
};
missionNamespace setVariable ["MWF_HUD_AnchorRegistry", _hudRegistry, true];

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
