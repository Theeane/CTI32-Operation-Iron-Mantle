/*
    Client-side entry for restricted Base Build Zeus.
    Server creates/assigns the curator; client opens the interface when ready.
*/
if (!hasInterface) exitWith {};

params [
    ["_terminal", objNull, [objNull]],
    ["_forcedAnchorPos", [], [[]]]
];

if (!isNull (getAssignedCuratorLogic player)) exitWith {
    systemChat "Base Architect is already active.";
};

private _resolved = [_terminal] call MWF_fnc_resolveBuildAnchor;
private _anchorPos = if (_forcedAnchorPos isEqualType [] && {count _forcedAnchorPos >= 2}) then { +_forcedAnchorPos } else { _resolved param [0, getPosATL player, [[]]] };
if (_anchorPos isEqualTo [] || {_anchorPos isEqualTo [0, 0, 0]}) then {
    _anchorPos = _resolved param [0, getPosATL player, [[]]];
};
if (_anchorPos isEqualTo [] || {_anchorPos isEqualTo [0, 0, 0]}) then {
    _anchorPos = getPosATL player;
};

private _maxRange = 500;
private _sessionId = format ["%1:%2:%3", getPlayerUID player, diag_tickTime, floor (random 1000000)];
player setVariable ["MWF_BaseArchitect_AnchorPos", _anchorPos, true];
player setVariable ["MWF_BaseArchitect_MaxRange", _maxRange, true];
player setVariable ["MWF_BaseArchitect_SessionId", _sessionId, true];
player setVariable ["MWF_BaseArchitect_Active", true, true];
missionNamespace setVariable ["MWF_BaseArchitect_Active", true];

[player, _anchorPos, _maxRange, _sessionId] remoteExecCall ["MWF_fnc_startBuildArchitectServer", 2];
true
