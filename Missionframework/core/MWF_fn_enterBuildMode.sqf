/*
    Smoothly enters build mode away from the terminal to avoid blocking collisions.
*/
if (!hasInterface) exitWith {};
params [["_terminal", objNull, [objNull]]];
["CLOSE"] call MWF_fnc_dataHub;
closeDialog 0;
private _anchorPos = if (!isNull _terminal) then { getPosATL _terminal } else { private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull]; if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" } };
if (_anchorPos isEqualTo [0,0,0]) then { _anchorPos = getPosATL player; };
private _buildPos = _anchorPos vectorAdd [0,-6,0];
private _found = _buildPos findEmptyPosition [1, 15, typeOf player];
if !(_found isEqualTo []) then { _buildPos = _found; };
cutText ["", "BLACK OUT", 0.25];
sleep 0.25;
player setPosATL _buildPos;
[player] allowDamage false;
[_terminal] call MWF_fnc_openBaseArchitect;
cutText ["", "BLACK IN", 0.25];
[player] spawn { sleep 1; _this allowDamage true; };
