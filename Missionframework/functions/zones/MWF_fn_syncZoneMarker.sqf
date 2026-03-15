/*
    Author: Theane / ChatGPT
    Function: fn_syncZoneMarker
    Project: Military War Framework

    Description:
    Synchronizes zone markers and display text from the current authoritative zone state.
*/

if (!isServer) exitWith {};

params [
    ["_zone", objNull, [objNull]]
];

if (isNull _zone) exitWith {};

private _zoneId = _zone getVariable ["MWF_zoneID", _zone call BIS_fnc_netId];
private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
private _zoneName = _zone getVariable ["MWF_zoneName", "Unknown Zone"];
private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
private _zonePos = getPosWorld _zone;
private _ownerState = toLower (_zone getVariable ["MWF_zoneOwnerState", "enemy"]);
private _underAttack = _zone getVariable ["MWF_underAttack", false];
private _contested = _zone getVariable ["MWF_contested", false];
private _markerName = _zone getVariable ["MWF_zoneMarker", ""];
private _textMarkerName = _zone getVariable ["MWF_zoneTextMarker", ""];

if (_markerName isEqualTo "") then {
    private _safeId = [_zoneId, ":", "_"] call BIS_fnc_replaceString;
    _safeId = [_safeId, " ", "_"] call BIS_fnc_replaceString;
    _markerName = format ["MWF_zone_%1", _safeId];

    createMarker [_markerName, _zonePos];
    _zone setVariable ["MWF_zoneMarker", _markerName, true];
};

if (_textMarkerName isEqualTo "") then {
    private _safeIdText = [_zoneId, ":", "_"] call BIS_fnc_replaceString;
    _safeIdText = [_safeIdText, " ", "_"] call BIS_fnc_replaceString;
    _textMarkerName = format ["MWF_zone_text_%1", _safeIdText];

    createMarker [_textMarkerName, _zonePos];
    _zone setVariable ["MWF_zoneTextMarker", _textMarkerName, true];
};

_markerName setMarkerShape "ELLIPSE";
_markerName setMarkerPos _zonePos;
_markerName setMarkerSize [_zoneRange, _zoneRange];
_markerName setMarkerBrush "SolidBorder";
_markerName setMarkerAlpha 0.65;

private _markerColor = "ColorOPFOR";
if (_ownerState isEqualTo "player") then {
    _markerColor = "ColorBLUFOR";
};
if (_contested || _underAttack) then {
    _markerColor = "ColorYellow";
};
_markerName setMarkerColor _markerColor;

_textMarkerName setMarkerType "mil_dot";
_textMarkerName setMarkerPos _zonePos;
_textMarkerName setMarkerColor "ColorBlack";

private _prefix = switch (_zoneType) do {
    case "capital": {"Capital"};
    case "factory": {"Factory"};
    case "military": {"Military"};
    default {"Town"};
};

private _status = switch (_markerColor) do {
    case "ColorBLUFOR": {"Secured"};
    case "ColorYellow": {"Contested"};
    default {"Enemy"};
};

_textMarkerName setMarkerText format ["%1: %2 (%3)", _prefix, _zoneName, _status];
