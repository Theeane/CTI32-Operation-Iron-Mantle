/*
    Author: Theane / ChatGPT
    Function: fn_buyIntel
    Project: Military War Framework

    Description:
    Authoritative intel-spend helper using the current digital economy state.
    Can also be used as a free reveal when _revealOnly is true.
*/

params [
    ["_cost", 50, [0]],
    ["_revealOnly", false, [false]],
    ["_requester", objNull, [objNull]]
];

if (!isServer) exitWith {
    private _resolvedRequester = if (isNull _requester && {hasInterface && {!isNull player}}) then { player } else { _requester };
    [_cost, _revealOnly, _resolvedRequester] remoteExecCall ["MWF_fnc_buyIntel", 2];
    true
};

private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
if (!_revealOnly && {_cost > 0} && {_intel < _cost}) exitWith {
    if (!isNull _requester) then {
        [format ["Not enough Intel! Need %1.", _cost]] remoteExec ["hint", owner _requester];
    };
    ["TaskFailed", ["", format ["Not enough Intel! Need %1.", _cost]]] remoteExec ["BIS_fnc_showNotification", 0];
    false
};

if (!_revealOnly && {_cost > 0}) then {
    if (!isNil "MWF_fnc_syncEconomyState") then {
        [-1, _intel - _cost, -1] call MWF_fnc_syncEconomyState;
    } else {
        missionNamespace setVariable ["MWF_res_intel", (_intel - _cost) max 0, true];
        missionNamespace setVariable ["MWF_Intel", (_intel - _cost) max 0, true];
    };
};

private _allEnemyGroups = allGroups select {
    private _side = side _x;
    (_side isEqualTo east) || {_side isEqualTo resistance}
};

if (_allEnemyGroups isEqualTo []) exitWith {
    ["TaskFailed", ["", "No enemy activity detected in the area."]] remoteExec ["BIS_fnc_showNotification", 0];
    false
};

private _targetGroup = selectRandom _allEnemyGroups;
private _leader = leader _targetGroup;
if (isNull _leader) exitWith {
    ["TaskFailed", ["", "Enemy signal was lost before triangulation completed."]] remoteExec ["BIS_fnc_showNotification", 0];
    false
};

private _pos = getPos _leader;
private _mkrName = format ["intel_reveal_%1_%2", round serverTime, floor (random 100000)];
private _mkr = createMarker [_mkrName, _pos];
_mkr setMarkerType "hd_warning";
_mkr setMarkerColor "ColorRed";
_mkr setMarkerText "Estimated Enemy Position";

["TaskSucceeded", ["", if (_revealOnly) then {"Enemy movements revealed on map!"} else {"Intel spent. Enemy movements revealed on map!"}]] remoteExec ["BIS_fnc_showNotification", 0];

[_mkr] spawn {
    params ["_markerName"];
    sleep 300;
    deleteMarker _markerName;
};

true
