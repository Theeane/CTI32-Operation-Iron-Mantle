/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_refreshFOBMarkers
    Project: Military War Framework

    Description:
    Rebuilds FOB and MRU markers from the current active registries.
*/

if (!isServer) exitWith { false };

{
    deleteMarker _x;
} forEach (allMapMarkers select {
    (_x find "fob_marker_" == 0) || { _x find "mru_marker_" == 0 }
});

private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
private _rebuilt = [];

{
    _x params ["_markerName", "_terminal", ["_displayName", "", [""]], ["_originType", "TRUCK", [""]]];
    if (!isNull _terminal) then {
        private _newMarkerName = format ["fob_marker_%1", round (random 999999)];
        createMarker [_newMarkerName, getPosATL _terminal];
        _newMarkerName setMarkerType "b_hq";
        _newMarkerName setMarkerText _displayName;
        _newMarkerName setMarkerColor "ColorBLUFOR";

        _terminal setVariable ["MWF_FOB_Marker", _newMarkerName, true];
        _rebuilt pushBack [_newMarkerName, _terminal, _displayName, _originType];
    };
} forEach _registry;

missionNamespace setVariable ["MWF_FOB_Registry", _rebuilt, true];

private _respawns = missionNamespace getVariable ["MWF_allMobileRespawns", []];
private _rebuiltRespawns = [];

{
    if (!isNull _x && {alive _x} && {_x getVariable ["MWF_isMobileRespawn", false]} && {_x getVariable ["MWF_respawnAvailable", false]}) then {
        private _markerName = format ["mru_marker_%1", round (random 999999)];
        createMarker [_markerName, getPosATL _x];
        _markerName setMarkerType "b_motor_inf";
        _markerName setMarkerText (_x getVariable ["MWF_MRU_DisplayName", "Mobile Respawn Unit"]);
        _markerName setMarkerColor "ColorBLUFOR";

        _x setVariable ["MWF_MRU_Marker", _markerName, true];
        _rebuiltRespawns pushBack _x;
    };
} forEach _respawns;

missionNamespace setVariable ["MWF_allMobileRespawns", _rebuiltRespawns, true];
true
