/*
    Author: Theane / ChatGPT
    Function: fn_refreshFOBMarkers
    Project: Military War Framework

    Description:
    Rebuilds FOB markers from the current active registry.
*/

if (!isServer) exitWith {};

{ deleteMarker _x; } forEach (allMapMarkers select { _x find "fob_marker_" == 0 });

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
