/*
    Author: Theane / ChatGPT
    Function: fn_cityMonitor
    Project: Military War Framework

    Description:
    Handles city-building monitoring for the reputation system.
    Called with no argument, it bootstraps all town / capital / factory buildings.
    Called with a building object, it attaches a single HandleDamage listener.
*/

if (!isServer) exitWith {};

params [["_building", objNull, [objNull]]];

private _attachMonitor = {
    params ["_targetBuilding"];
    if (isNull _targetBuilding) exitWith { false };
    if (_targetBuilding getVariable ["MWF_isMonitored", false]) exitWith { false };

    _targetBuilding setVariable ["MWF_isMonitored", true];
    _targetBuilding addEventHandler ["HandleDamage", {
        params ["_unit", "_selection", "_damage", "_source", "_projectile"];

        private _mode = missionNamespace getVariable ["MWF_LockedBuildingMode", 0];
        private _threshold = if (_mode == 0) then { 0.2 } else { 0.9 };

        if (_damage > _threshold && !(_unit getVariable ["MWF_isRuined", false])) then {
            _unit setVariable ["MWF_isRuined", true, true];
            ["ADJUST", -2] call MWF_fnc_civRep;

            private _ruinedBuildings = missionNamespace getVariable ["MWF_CityBuildingStatus", []];
            _ruinedBuildings pushBackUnique (getPosATL _unit);
            missionNamespace setVariable ["MWF_CityBuildingStatus", _ruinedBuildings, true];

            ["SAVE"] call MWF_fnc_saveManager;
            diag_log format ["[KPIN CITY]: Building at %1 reached damage threshold (%2). Penalty applied.", getPosATL _unit, _threshold];
            _unit removeAllEventHandlers "HandleDamage";
        };

        _damage
    }];

    true
};

if (!isNull _building) exitWith {
    [_building] call _attachMonitor
};

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _attachedCount = 0;

{
    if (!isNull _x) then {
        private _zoneType = toLower (_x getVariable ["MWF_zoneType", "town"]);
        if (_zoneType in ["town", "capital", "factory"]) then {
            private _zonePos = getPosWorld _x;
            private _zoneRange = ((_x getVariable ["MWF_zoneRange", 300]) max 120) min 350;
            private _buildings = nearestTerrainObjects [_zonePos, ["HOUSE", "BUILDING"], _zoneRange, false, true];
            {
                if ([_x] call _attachMonitor) then {
                    _attachedCount = _attachedCount + 1;
                };
            } forEach _buildings;
        };
    };
} forEach _zones;

diag_log format ["[KPIN CITY]: Building monitor initialized across %1 structures.", _attachedCount];
