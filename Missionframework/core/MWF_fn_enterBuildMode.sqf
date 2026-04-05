/*
    Minimal stage-1 button wake-up path for Base Build.
    Scope intentionally kept tiny so startup systems, cinematics, and loadouts stay untouched.
*/
if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];

["CLOSE"] call MWF_fnc_dataHub;
closeDialog 0;

private _anchorPos = if (!isNull _terminal) then {
    getPosATL _terminal
} else {
    getPosATL player
};

if (_anchorPos isEqualTo [0,0,0]) then {
    _anchorPos = getPosATL player;
};

private _buildPos = _anchorPos vectorAdd [0, -5, 0];
private _found = _buildPos findEmptyPosition [1, 12, typeOf player];
if !(_found isEqualTo []) then {
    _buildPos = _found;
};

[_buildPos, _terminal] spawn {
    params ["_buildPos", "_terminal"];

    cutText ["", "BLACK OUT", 0.1];
    uiSleep 0.1;

    player setPosATL _buildPos;
    [_terminal] call MWF_fnc_openBaseArchitect;

    cutText ["", "BLACK IN", 0.1];
};
