/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupGarageInteractions
    Project: Military War Framework

    Description:
    Adds local scroll-menu actions to a virtual garage object.
*/

params [["_garage", objNull, [objNull]]];

if (!hasInterface) exitWith { false };
if (isNull _garage) exitWith { false };

private _existing = _garage getVariable ["MWF_Garage_ActionIds", []];
if !(_existing isEqualTo []) exitWith { true };

private _ids = [];
private _condOnFoot = "alive _this && vehicle _this == _this && (_this distance _target) <= 5";

_ids pushBack (_garage addAction [
    "<t color='#66CCFF'>[ GARAGE ] Status / Selected Vehicle</t>",
    { ["STATUS", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 10, true, true, "", _condOnFoot
]);

_ids pushBack (_garage addAction [
    "<t color='#99DDFF'>[ GARAGE ] Previous Stored Vehicle</t>",
    { ["PREV", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 9, true, true, "", _condOnFoot
]);

_ids pushBack (_garage addAction [
    "<t color='#99DDFF'>[ GARAGE ] Next Stored Vehicle</t>",
    { ["NEXT", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 8.9, true, true, "", _condOnFoot
]);

_ids pushBack (_garage addAction [
    "<t color='#00FF66'>[ GARAGE ] Retrieve Selected Vehicle</t>",
    { ["REQUEST_RETRIEVE", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 8, true, true, "", _condOnFoot
]);

_ids pushBack (_garage addAction [
    "<t color='#FFFF66'>[ GARAGE ] Store Nearby Vehicle</t>",
    { ["REQUEST_STORE", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 7, true, true, "", _condOnFoot
]);

_ids pushBack (_garage addAction [
    "<t color='#FFAA66'>[ GARAGE ] Scrap Nearby Vehicle</t>",
    { ["REQUEST_SCRAP", _target, _this select 1, 0] call MWF_fnc_garageSystem; },
    nil, 6, true, true, "", _condOnFoot
]);

_garage setVariable ["MWF_Garage_ActionIds", _ids, true];
true
