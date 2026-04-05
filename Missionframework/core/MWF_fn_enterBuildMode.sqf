/*
    Base Build transport/start path.
    Keeps UI impact minimal while using the shared build anchor resolver.
*/
if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];

["CLOSE"] call MWF_fnc_dataHub;
closeDialog 0;

private _resolved = [_terminal] call MWF_fnc_resolveBuildAnchor;
private _anchorPos = _resolved param [0, getPosATL player, [[]]];
private _buildPos = _resolved param [1, getPosATL player, [[]]];

if (_anchorPos isEqualTo [] || {_anchorPos isEqualTo [0,0,0]}) then {
    _anchorPos = getPosATL player;
};
if (_buildPos isEqualTo [] || {_buildPos isEqualTo [0,0,0]}) then {
    _buildPos = _anchorPos vectorAdd [0, -5, 0];
};

private _found = _buildPos findEmptyPosition [1, 12, typeOf player];
if !(_found isEqualTo []) then {
    _buildPos = _found;
};

[_buildPos, _terminal, _anchorPos] spawn {
    params ["_buildPos", "_terminal", "_anchorPos"];

    cutText ["", "BLACK OUT", 0.1];
    uiSleep 0.1;

    player setPosATL _buildPos;
    [_terminal, _anchorPos] call MWF_fnc_openBaseArchitect;

    cutText ["", "BLACK IN", 0.1];
};
