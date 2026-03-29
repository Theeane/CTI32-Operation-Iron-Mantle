/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_registerLoadoutZone
    Project: Military War Framework

    Description:
    Registers a fixed or runtime-spawned loadout trigger zone.
    Supports both static zones and anchor-following zones for mobile respawn assets.
*/

if (!isServer) exitWith { objNull };

params [
    ["_anchor", objNull, [objNull]],
    ["_radius", 50, [0]],
    ["_label", "LOADOUT", [""]],
    ["_existingTrigger", objNull, [objNull]],
    ["_followAnchor", false, [true]]
];

private _trg = _existingTrigger;
if (isNull _trg) then {
    private _center = if (!isNull _anchor) then { getPosATL _anchor } else { [0, 0, 0] };
    _trg = createTrigger ["EmptyDetector", _center, true];
};

if (isNull _trg) exitWith {
    diag_log "[MWF] Loadout Zone: failed to create or resolve trigger.";
    objNull
};

private _centerPos = if (!isNull _anchor) then { getPosATL _anchor } else { getPosATL _trg };
_trg setTriggerArea [_radius, _radius, 0, false, _radius];
_trg setPosATL _centerPos;
_trg setTriggerActivation ["ANYPLAYER", "PRESENT", false];
_trg setTriggerStatements ["this", "", ""];
_trg setVariable ["MWF_isLoadoutZone", true, true];
_trg setVariable ["MWF_LoadoutZoneRadius", _radius, true];
_trg setVariable ["MWF_LoadoutZoneLabel", _label, true];
_trg setVariable ["MWF_LoadoutZoneAnchor", _anchor, true];
_trg setVariable ["MWF_LoadoutZoneFollowAnchor", _followAnchor, true];

if (!isNull _anchor) then {
    _anchor setVariable ["MWF_LoadoutTrigger", _trg, true];
};

private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
_zones = _zones select { !isNull _x };
_zones pushBackUnique _trg;
missionNamespace setVariable ["MWF_LoadoutZones", _zones, true];

if (_followAnchor && {!isNull _anchor}) then {
    private _existingTracker = _anchor getVariable ["MWF_LoadoutZoneTracker", scriptNull];
    if !(_existingTracker isEqualTo scriptNull) then {
        terminate _existingTracker;
    };

    private _tracker = [_anchor, _trg] spawn {
        params ["_anchorObj", "_zoneTrig"];

        while {
            isServer &&
            {!isNull _anchorObj} &&
            {!isNull _zoneTrig} &&
            {_anchorObj getVariable ["MWF_isMobileRespawn", false]}
        } do {
            _zoneTrig setPosATL (getPosATL _anchorObj);
            sleep 1;
        };
    };

    _anchor setVariable ["MWF_LoadoutZoneTracker", _tracker];
};

if (_label isEqualTo "") then { _label = "LOADOUT"; };
diag_log format ["[MWF] Loadout Zone Registered: %1 (radius %2m).", _label, _radius];
_trg
