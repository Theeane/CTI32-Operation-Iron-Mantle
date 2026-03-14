/*
    Author: Theane / ChatGPT
    Function: fn_updateZoneProgression
    Project: Military War Framework

    Description:
    Recalculates strategic progression values from the authoritative zone registry.
    Kept as a compatibility layer while world progression is the strategic authority.
*/

if (!isServer) exitWith {};

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _capturedZones = [];
private _capturedTowns = 0;
private _capturedCapitals = 0;
private _capturedFactories = 0;
private _capturedMilitary = 0;

{
    private _zone = _x;

    if (!isNull _zone && {_zone getVariable ["MWF_isCaptured", false]}) then {
        _capturedZones pushBack _zone;

        switch (toLower (_zone getVariable ["MWF_zoneType", "town"])) do {
            case "capital": { _capturedCapitals = _capturedCapitals + 1; };
            case "factory": { _capturedFactories = _capturedFactories + 1; };
            case "military": { _capturedMilitary = _capturedMilitary + 1; };
            default { _capturedTowns = _capturedTowns + 1; };
        };
    };
} forEach _zones;

private _totalZones = count _zones;
private _capturedCount = count _capturedZones;
private _mapControl = if (_totalZones > 0) then { (_capturedCount / _totalZones) * 100 } else { 0 };

missionNamespace setVariable ["MWF_captured_zones_list", _capturedZones, true];
missionNamespace setVariable ["MWF_CapturedZoneCount", _capturedCount, true];
missionNamespace setVariable ["MWF_CapturedTownCount", _capturedTowns, true];
missionNamespace setVariable ["MWF_CapturedCapitalCount", _capturedCapitals, true];
missionNamespace setVariable ["MWF_CapturedFactoryCount", _capturedFactories, true];
missionNamespace setVariable ["MWF_CapturedMilitaryCount", _capturedMilitary, true];
missionNamespace setVariable ["MWF_MapControlPercent", _mapControl, true];

if (!isNil "MWF_fnc_markWorldDirty") then {
    ["zone_progression"] call MWF_fnc_markWorldDirty;
} else {
    if (!isNil "MWF_fnc_recalculateWorldState") then {
        [] call MWF_fnc_recalculateWorldState;
    };
};
