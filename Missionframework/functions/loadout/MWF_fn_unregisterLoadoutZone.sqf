/*
    Author: OpenAI
    Function: MWF_fnc_unregisterLoadoutZone
    Project: Military War Framework

    Description:
    Removes a loadout zone and cleans up any anchor references.
*/

if (!isServer) exitWith { false };

params [["_target", objNull, [objNull]]];
if (isNull _target) exitWith { false };

private _zone = if (_target getVariable ["MWF_isLoadoutZone", false]) then {
    _target
} else {
    _target getVariable ["MWF_LoadoutTrigger", objNull]
};

if (isNull _zone) exitWith { false };

private _anchor = _zone getVariable ["MWF_LoadoutZoneAnchor", objNull];
if (!isNull _anchor) then {
    private _tracker = _anchor getVariable ["MWF_LoadoutZoneTracker", scriptNull];
    if !(_tracker isEqualTo scriptNull) then {
        terminate _tracker;
    };
    _anchor setVariable ["MWF_LoadoutZoneTracker", scriptNull];
    _anchor setVariable ["MWF_LoadoutTrigger", objNull, true];
};

private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
_zones = _zones select { !isNull _x && {_x != _zone} };
missionNamespace setVariable ["MWF_LoadoutZones", _zones, true];

deleteVehicle _zone;
true
