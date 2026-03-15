/*
    Author: Theane / ChatGPT
    Function: MWF_fn_initZones
    Project: Military War Framework

    Description:
    Starts zone capture loops for all registered zone objects.
*/

if (!isServer) exitWith {};

private _registeredZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _startedCount = 0;

{
    private _zone = _x;

    if (!isNull _zone) then {
        if !(_zone getVariable ["MWF_zoneCaptureStarted", false]) then {
            _zone setVariable ["MWF_zoneCaptureStarted", true, true];
            [_zone] spawn MWF_fnc_zoneCapture;
            _startedCount = _startedCount + 1;
        };
    };
} forEach _registeredZones;

diag_log format ["[MWF Zones] Started capture loops for %1 zones.", _startedCount];
