/*
    Author: Theane (AGS Project)
    Description: Server-side logic to generate the very first objective 
                 upon framework activation.
    Language: English
*/

if (!isServer) exitWith {};

// Prevent duplicate mission generation if multiple players log in simultaneously
if (missionNamespace getVariable ["AGS_initialMissionActive", false]) exitWith {};
missionNamespace setVariable ["AGS_initialMissionActive", true, true];

uiSleep 2;

// Locate the nearest hostile sector to the base
private _basePos = getMarkerPos "AGS_base_marker";
private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];

if (count _allZones == 0) exitWith { diag_log "AGS Error: No zones found in AGS_all_mission_zones."; };

private _targetZone = [_allZones, _basePos] call BIS_fnc_nearestPosition;

// Create the first Task
[
    west, 
    "task_initial_capture", 
    [
        format ["Infiltrate and capture %1 to establish a resource link. This sector will provide our first steady stream of Supplies.", text _targetZone],
        "Capture First Sector",
        _targetZone
    ], 
    getMarkerPos _targetZone, 
    "CREATED", 
    5, 
    true, 
    "target", 
    true
] call BIS_fnc_taskCreate;

[format ["STRATEGIC UPDATE: Infiltrate %1 to begin the liberation.", text _targetZone]] remoteExec ["systemChat", 0];
