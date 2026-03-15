/*
    Author: Theane / ChatGPT
    Function: fn_cityMonitor
    Project: Military War Framework

    Description:
    Handles city monitor for the reputation system.
*/

if (!isServer) exitWith {};

params ["_building"];

// Ensure we don't attach multiple listeners to the same building
if (_building getVariable ["MWF_isMonitored", false]) exitWith {};
_building setVariable ["MWF_isMonitored", true];

_building addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile"];

    // 0 = Damaged (20% threshold), 1 = Destroyed (90% threshold)
    private _mode = missionNamespace getVariable ["MWF_LockedBuildingMode", 0]; 
    private _threshold = if (_mode == 0) then { 0.2 } else { 0.9 };

    // Check if damage crosses the threshold and the building isn't already recorded
    if (_damage > _threshold && !(_unit getVariable ["MWF_isRuined", false])) then {
        _unit setVariable ["MWF_isRuined", true, true];

        // 1. Reputation Penalty
        // We apply a flat -2 penalty for civilian property damage
        ["ADJUST", -2] call MWF_fnc_civRep;

        // 2. Record for Persistence
        // We store the position to ensure the building stays damaged/destroyed after restart
        private _ruinedBuildings = missionNamespace getVariable ["MWF_CityBuildingStatus", []];
        _ruinedBuildings pushBackUnique (getPosATL _unit);
        missionNamespace setVariable ["MWF_CityBuildingStatus", _ruinedBuildings, true];

        // 3. Trigger Save
        ["SAVE"] call MWF_fnc_saveManager;

        diag_log format ["[KPIN CITY]: Building at %1 reached damage threshold (%2). Penalty applied.", getPosATL _unit, _threshold];
        
        // Once the threshold is reached and penalty applied, we can stop monitoring this building
        _unit removeAllEventHandlers "HandleDamage";
    };
    
    _damage
}];
