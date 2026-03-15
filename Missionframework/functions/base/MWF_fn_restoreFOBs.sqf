/*
    Author: Theane / ChatGPT
    Function: fn_restoreFOBs
    Project: Military War Framework

    Description:
    Restores saved FOBs from strategic persistence after campaign load.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_FOBsRestored", false]) exitWith {};

missionNamespace setVariable ["MWF_FOBsRestored", true, true];
missionNamespace setVariable ["MWF_FOB_Registry", [], true];

private _saved = missionNamespace getVariable ["MWF_FOB_Positions", []];
if (_saved isEqualTo []) exitWith {
    diag_log "[MWF FOB] No saved FOBs to restore.";
};

{
    private _posAsl = _x param [0, []];
    private _dir = _x param [1, 0];
    private _displayName = _x param [2, ""];
    private _originType = _x param [3, "TRUCK"];

    if (_posAsl isEqualType [] && {count _posAsl >= 2}) then {
        [objNull, _posAsl, _dir, _displayName, _originType, true] call MWF_fnc_deployFOB;
    };
} forEach _saved;

[] call MWF_fnc_refreshFOBMarkers;

diag_log format ["[MWF FOB] Restored %1 FOB(s) from save.", count _saved];
