/*
    Author: Theane using gemini
    Function: KPIN_fnc_cityMonitor
    Description: 
    Monitors civilian buildings within Town/Capital zones. Applies reputation penalties 
    based on the locked BuildingDamageMode (Damaged vs Destroyed).
*/

if (!isServer) exitWith {};

params ["_building"];

// Only monitor buildings that haven't been recorded yet
if (_building getVariable ["KPIN_isMonitored", false]) exitWith {};
_building setVariable ["KPIN_isMonitored", true];

_building addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile"];

    private _mode = missionNamespace getVariable ["KPIN_LockedBuildingMode", 0]; // 0: Damaged, 1: Destroyed
    private _threshold = if (_mode == 0) then { 0.2 } else { 0.9 };

    if (_damage > _threshold && alive _unit) then {
        // Penalty for damaging civilian property
        ["ADJUST", -2] call KPIN_fnc_civRep;
        
        // Save the building's unique ID/Position to the status array
        private _status = missionNamespace getVariable ["KPIN_CityBuildingStatus", []];
        _status pushBackUnique (getPosATL _unit);
        missionNamespace setVariable ["KPIN_CityBuildingStatus", _status, true];

        // Remove EH to prevent spamming penalties for the same house
        _unit removeAllEventHandlers "HandleDamage";
        
        diag_log format ["[KPIN CITY]: Building damaged at %1. Reputation Penalty applied.", getPosATL _unit];
    };
    _damage
}];
