/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Plays a lightweight local intro cinematic near the MOB or player spawn so the rest
    of the mission can finish settling in. Starts as early as possible once the in-world
    view is available and records explicit stage flags for debugging.
*/

if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };

uiNamespace setVariable ["MWF_IntroCinematicStage", "ENTRY"];
uiNamespace setVariable ["MWF_IntroCinematicActive", true];

[] spawn {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_WORLDVIEW"];

    private _deadline = diag_tickTime + 45;
    waitUntil {
        uiSleep 0.1;
        (
            !isNull player && {alive player} && {!visibleMap} && {!dialog} && {!isNull findDisplay 46}
        ) || {diag_tickTime >= _deadline}
    };

    if (diag_tickTime >= _deadline) exitWith {
        uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_TIMEOUT"];
        uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    };

    if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith {
        uiNamespace setVariable ["MWF_IntroCinematicStage", "ALREADY_PLAYED"];
        uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    };

    uiNamespace setVariable ["MWF_IntroCinematicStage", "STARTING"];
    uiNamespace setVariable ["MWF_IntroCinematicPlayed", true];

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
        [16, -9, 5],
        [-12, -14, 6],
        [-10, 12, 7],
        [9, 16, 5]
    ];
    private _shotPositions = _shotOffsets apply { _anchorPos vectorAdd ([_x, _anchorDir] call _rotateOffset) };
    private _shotFovs = [0.8, 0.75, 0.72, 0.78];

    private _cam = "camera" camCreate (_shotPositions # 0);
    if (isNull _cam) exitWith {
        uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_FAIL"];
        uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    };

    uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_ACTIVE"];
    showCinemaBorder false;
    _cam cameraEffect ["INTERNAL", "BACK"];
    _cam camSetPos (_shotPositions # 0);
    _cam camSetTarget _anchor;
    _cam camSetFov (_shotFovs # 0);
    _cam camCommit 0;

    cutText ["", "BLACK FADED", 0];
    sleep 0.1;
    cutText ["", "BLACK IN", 2];

    for "_i" from 1 to ((count _shotPositions) - 1) do {
        uiNamespace setVariable ["MWF_IntroCinematicStage", format ["SHOT_%1", _i]];
        _cam camPreparePos (_shotPositions # _i);
        _cam camPrepareTarget _anchor;
        _cam camPrepareFov (_shotFovs # _i);
        camCommitPrepared 7;

        private _timeout = time + 7.5;
        waitUntil {
            sleep 0.05;
            camCommitted _cam || {time >= _timeout}
        };
    };

    uiNamespace setVariable ["MWF_IntroCinematicStage", "CLEANUP"];
    _cam cameraEffect ["TERMINATE", "BACK"];
    camDestroy _cam;
    player switchCamera "INTERNAL";
    cutText ["", "BLACK IN", 0.5];

    if ((typeOf _anchor) isEqualTo "Logic" && {local _anchor}) then {
        deleteVehicle _anchor;
    };

    uiNamespace setVariable ["MWF_IntroCinematicStage", "COMPLETE"];
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
};

true
