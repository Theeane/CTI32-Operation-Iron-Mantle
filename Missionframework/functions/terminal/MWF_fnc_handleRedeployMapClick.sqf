/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_handleRedeployMapClick
    Project: Military War Framework

    Description:
    Handles map clicks during an active redeploy session. Players are teleported to a
    fixed redeploy target when clicking near a valid FOB/MOB marker.
*/

if (!hasInterface) exitWith { false };

params [
    ["_clickPos", [], [[]]]
];

if !(missionNamespace getVariable ["MWF_Redeploy_Active", false]) exitWith { false };
if (!alive player) exitWith {
    ["CLEANUP", [false]] call MWF_fnc_terminal_redeploy;
    false
};

private _targets = missionNamespace getVariable ["MWF_Redeploy_Targets", []];
private _clickRadius = missionNamespace getVariable ["MWF_Redeploy_ClickRadius", 40];

private _matchIndex = _targets findIf {
    private _targetPos = _x param [2, [0,0,0], [[]]];
    (_targetPos distance2D _clickPos) <= _clickRadius
};

if (_matchIndex < 0) exitWith {
    systemChat format ["Redeploy: click within %1m of a valid marker.", _clickRadius];
    false
};

private _selected = _targets select _matchIndex;
_selected params ["_kind", "_label", "_targetPos"];

private _teleportPos = [_targetPos, 3, 12, 2, 0, 0.25, 0] call BIS_fnc_findSafePos;
if (_teleportPos isEqualTo [] || {_teleportPos isEqualTo [0,0,0]}) then {
    _teleportPos = _targetPos vectorAdd [3, 0, 0];
};

player setPosATL _teleportPos;
openMap [false, false];
["CLEANUP", [false]] call MWF_fnc_terminal_redeploy;

[["REDEPLOY COMPLETE", format ["Redeployed to %1.", _label]], "success"] call MWF_fnc_showNotification;
systemChat format ["Redeployed to %1.", _label];

true
