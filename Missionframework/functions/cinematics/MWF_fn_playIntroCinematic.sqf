/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Plays a lightweight local intro cinematic near the MOB or player spawn so the rest
    of the mission can finish settling in. Exposes local stage flags so client-side
    failures can be debugged directly in-game.
*/

uiNamespace setVariable ["MWF_IntroCallAttempted", true];
uiNamespace setVariable ["MWF_IntroCinematicStage", "ENTRY"];

if (!hasInterface) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "NO_INTERFACE"];
    false
};
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "ALREADY_PLAYED"];
    false
};

private _joinWindow = 900;
if ((serverTime > 0) && {serverTime > _joinWindow}) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "JOIN_WINDOW_EXPIRED"];
    false
};

uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_WORLD"];
private _waitDeadline = diag_tickTime + 30;
waitUntil {
    uiSleep 0.1;
    (
        !isNull player &&
        {alive player} &&
        {!visibleMap} &&
        {!dialog} &&
        {!isNull findDisplay 46}
    ) || {diag_tickTime >= _waitDeadline}
};

if (diag_tickTime >= _waitDeadline) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_TIMEOUT"];
    false
};

if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "ALREADY_PLAYED_AFTER_WAIT"];
    false
};

uiNamespace setVariable ["MWF_IntroCinematicPlayed", true];
uiNamespace setVariable ["MWF_IntroCinematicStage", "STARTED"];

private _anchor = missionNamespace getVariable ["MWF_MOB_Table", missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]]];
if (isNull _anchor) then {
    private _markerPos = getMarkerPos "respawn_west";
    if !(_markerPos isEqualTo [0,0,0]) then {
        _anchor = createVehicleLocal ["Logic", _markerPos, [], 0, "CAN_COLLIDE"];
    } else {
        _anchor = player;
    };
};

private _anchorPos = getPosATL _anchor;
private _anchorDir = getDir _anchor;

private _rotateOffset = {
    params ["_offset", ["_dir", 0, [0]]];
    private _x = _offset param [0, 0, [0]];
    private _y = _offset param [1, 0, [0]];
    private _z = _offset param [2, 0, [0]];
    [
        (_x * cos _dir) - (_y * sin _dir),
        (_x * sin _dir) + (_y * cos _dir),
        _z
    ]
};

private _shotOffsets = [
    [18, -10, 6],
    [-14, -16, 7],
    [-12, 14, 8],
    [10, 18, 6]
];
private _shotPositions = _shotOffsets apply { _anchorPos vectorAdd ([_x, _anchorDir] call _rotateOffset) };
private _shotFovs = [0.78, 0.74, 0.70, 0.76];

private _cam = "camera" camCreate (_shotPositions # 0);
if (isNull _cam) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_CREATE_FAILED"];
    false
};

showCinemaBorder false;
_cam cameraEffect ["INTERNAL", "BACK"];
_cam camSetPos (_shotPositions # 0);
_cam camSetTarget _anchor;
_cam camSetFov (_shotFovs # 0);
_cam camCommit 0;

cutText ["", "BLACK FADED", 0];
uiNamespace setVariable ["MWF_IntroCinematicStage", "BLACK_IN"];
sleep 0.1;
cutText ["", "BLACK IN", 2];

[] spawn {
    sleep 10;
    titleText [localize "STR_MWF_INTRO_WELCOME", "PLAIN", 0.75];
    sleep 4.25;
    titleFadeOut 0.75;

    sleep 0.75;
    titleText [localize "STR_MWF_MISSION_TITLE", "PLAIN", 0.75];
    sleep 9.25;
    titleFadeOut 0.75;
};

for "_i" from 1 to ((count _shotPositions) - 1) do {
    uiNamespace setVariable ["MWF_IntroCinematicStage", format ["SHOT_%1", _i]];
    _cam camPreparePos (_shotPositions # _i);
    _cam camPrepareTarget _anchor;
    _cam camPrepareFov (_shotFovs # _i);
    camCommitPrepared 10;

    private _timeout = time + 10.5;
    waitUntil {
        sleep 0.05;
        camCommitted _cam || {time >= _timeout}
    };
};

_cam cameraEffect ["TERMINATE", "BACK"];
camDestroy _cam;
player switchCamera "INTERNAL";
cutText ["", "BLACK IN", 0.5];

if ((typeOf _anchor) isEqualTo "Logic" && {local _anchor}) then {
    deleteVehicle _anchor;
};

uiNamespace setVariable ["MWF_IntroCinematicStage", "COMPLETE"];
true
