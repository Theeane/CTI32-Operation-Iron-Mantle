/*
    Author: Theane / ChatGPT
    Function: MWF_fn_buildMode
    Project: Military War Framework

    Description:
    Handles local build placement preview and commits the purchase through the shared economy system.
*/

params [
    ["_className", "", [""]],
    ["_price", 0, [0]]
];

if (!hasInterface) exitWith {}; 
if (_className isEqualTo "") exitWith {};

private _currentSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
if (_currentSupplies < _price) exitWith {
    diag_log parseText "<t color='#ff0000'>Not enough Supplies!</t>";
};

private _ghost = _className createVehicleLocal [0, 0, 0];
_ghost setAllowDamage false;
_ghost enableSimulation false;
_ghost setVectorUp surfaceNormal getPosATL player;
_ghost setAlpha 0.6;

private _confirmed = false;
private _aborted = false;
private _rotation = getDir player;

dia...