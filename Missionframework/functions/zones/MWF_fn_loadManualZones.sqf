/*
    Author: Theane / ChatGPT
    Function: fn_loadManualZones
    Project: Military War Framework

    Description:
    Loads mission maker defined zone objects and legacy zone markers into a unified zone object array.
    Uses the presence of a non-empty MWF_zoneType value instead of the looser getVariable-exists check.
*/

if (!isServer) exitWith {[]};

private _manualZones = [];
private _editorZones = entities "Logic" select {
    private _rawType = _x getVariable ["MWF_zoneType", ""];
    (_rawType isEqualType "") && {_rawType isNotEqualTo ""}
};

{
    private _zone = _x;
    private _zonePos = getPosWorld _zone;
    private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
    private _zoneName = _zone getVariable ["MWF_zoneName", format ["%1 Zone", _zoneType]];
    private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
    private _zoneId = _zone getVariable ["MWF_zoneID", format ["%1_%2", _zoneType, _zone call BIS_fnc_netId]];

    _zone setVariable ["MWF_zoneID", toLower _zoneId, true];
    _zone setVariable ["MWF_zoneType", _zoneType, true];
    _zone setVariable ["MWF_zoneName", _zoneName, true];
    _zone setVariable ["MWF_zoneRange", _zoneRange, true];
    _zone setVariable ["MWF_zoneSource", "manual_logic", true];
    _zone setVariable ["MWF_zoneOwnerState", _zone getVariable ["MWF_zoneOwnerState", "enemy"], true];
    _zone setVariable ["MWF_isCaptured", _zone getVariable ["MWF_isCaptured", false], true];
    _zone setVariable ["MWF_underAttack", _zone getVariable ["MWF_underAttack", false], true];
    _zone setVariable ["MWF_contested", _zone getVariable ["MWF_contested", false], true];
    _zone setVariable ["MWF_capProgress", _zone getVariable ["MWF_capProgress", 0], true];
    _zone setPosWorld _zonePos;

    _manualZones pushBackUnique _zone;
} forEach _editorZones;

private _legacyMarkerZones = [];
if (!isNil "MWF_fnc_scanZones") then {
    _legacyMarkerZones = [] call MWF_fnc_scanZones;
};

{
    _manualZones pushBackUnique _x;
} forEach _legacyMarkerZones;

_manualZones
