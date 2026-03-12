/*
    Author: Theane using gemini
    Function: KPIN_fnc_cityMonitor
    Description: 
    Monitors civilian building damage in Town and Capital zones. Applies reputation 
    penalties based on the locked BuildingDamageMode (Damaged vs Destroyed) and 
    records ruined structures for persistence.
*/

if (!isServer) exitWith {};

params ["_building"];

// Ensure we don't attach multiple listeners to the same building
if (_building getVariable ["KPIN_isMonitored", false]) exitWith {};
_building setVariable ["KPIN_isMonitored", true];

_building addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile"];

    // 0 = Damaged (20% threshold), 1 = Destroyed (90% threshold)
    private _mode = missionNamespace getVariable ["KPIN_LockedBuildingMode", 0]; 
    private _threshold = if (_mode == 0) then { 0.2 } else { 0.9 };

    // Check if damage crosses the threshold and the building isn't already recorded
    if (_damage > _threshold && !(_unit getVariable ["KPIN_isRuined", false])) then {
        _unit setVariable ["KPIN_isRuined", true, true];

        // 1. Reputation Penalty
        // We apply a flat -2 penalty for civilian property damage
        ["ADJUST", -2] call KPIN_fnc_civRep;

        // 2. Record for Persistence
        // We store the position to ensure the building stays damaged/destroyed after restart
        private _ruinedBuildings = missionNamespace getVariable ["KPIN_CityBuildingStatus", []];
        _ruinedBuildings pushBackUnique (getPosATL _unit);
        missionNamespace setVariable ["KPIN_CityBuildingStatus", _ruinedBuildings, true];

        // 3. Trigger Save
        ["SAVE"] call KPIN_fnc_saveManager;

        diag_log format ["[KPIN CITY]: Building at %1 reached damage threshold (%2). Penalty applied.", getPosATL _unit, _threshold];
        
        // Once the threshold is reached and penalty applied, we can stop monitoring this building
        _unit removeAllEventHandlers "HandleDamage";
    };
    
    _damage
}];
