/*
    Author: Theane / ChatGPT
    Function: fn_registerThreatIncident
    Project: Military War Framework

    Description:
    Registers a strategic threat incident and marks the threat layer dirty.
    Incidents are kept lightweight and capped for Arma-safe synchronization.
*/

if (!isServer) exitWith {false};

params [
    ["_type", "generic", [""]],
    ["_zoneId", "", [""]],
    ["_severity", 1, [0]],
    ["_note", "", [""]]
];

private _log = + (missionNamespace getVariable ["MWF_ThreatIncidentLog", []]);
private _entry = [
    diag_tickTime,
    toLower _type,
    toLower _zoneId,
    _severity max 0,
    _note
];

_log pushBack _entry;

if ((count _log) > 20) then {
    _log = _log select ((count _log) - 20);
};

missionNamespace setVariable ["MWF_ThreatIncidentLog", _log, true];

["incident"] call MWF_fnc_markThreatDirty;
true
