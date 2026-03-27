/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Plays a local deployment cinematic for the joining player only.
    The sequence prefers MOB anchors and then adds one world-anchor flyover,
    so players never see the respawn/deploy UI before the cinematic is done.
    Returns true only when the cinematic reached its normal cleanup path.
*/

if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith { false };

uiNamespace setVariable ["MWF_IntroCinematicStage", "ENTRY"];
uiNamespace setVariable ["MWF_IntroCinematicActive", true];
missionNamespace setVariable ["MWF_BlockRespawn", true];

private _deadline = diag_tickTime + 20;
waitUntil {
    uiSleep 0.1;
    (!isNull player && {alive player} && {!visibleMap} && {!dialog} && {!isNull findDisplay 46})
    || {diag_tickTime >= _deadline}
};

if (diag_tickTime >= _deadline) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_TIMEOUT"];
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    false
};

private _cleanupObjects = [];

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

private _mobAnchor = missionNamespace getVariable ["MWF_MOB_Table", objNull];
private _mobPos = [0, 0, 0];
private _mobDir = 0;

if (isNull _mobAnchor) then {
    _mobAnchor = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];
};
if (isNull _mobAnchor && {!isNil "mob_deploy_pad"}) then {
    _mobAnchor = mob_deploy_pad;
};
if (!isNull _mobAnchor) then {
    _mobPos = getPosATL _mobAnchor;
    _mobDir = getDir _mobAnchor;
};
if ((_mobPos isEqualTo [0, 0, 0]) && {markerColor "MWF_MOB_Marker" isNotEqualTo ""}) then {
    _mobPos = getMarkerPos "MWF_MOB_Marker";
    _mobDir = markerDir "MWF_MOB_Marker";
};
if ((_mobPos isEqualTo [0, 0, 0])) then {
    private _mobArea = missionNamespace getVariable ["MWF_MOB", objNull];
    if (!isNull _mobArea) then {
        _mobPos = getPosATL _mobArea;
        _mobDir = getDir _mobArea;
    };
};
if ((_mobPos isEqualTo [0, 0, 0])) then {
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
    if (!isNull _mainBase) then {
        _mobPos = getPosATL _mainBase;
        _mobDir = getDir _mainBase;
    };
};
if ((_mobPos isEqualTo [0, 0, 0])) then {
    _mobPos = getPosATL player;
    _mobDir = getDir player;
};

if (isNull _mobAnchor) then {
    _mobAnchor = createVehicleLocal ["Logic", _mobPos, [], 0, "CAN_COLLIDE"];
    _cleanupObjects pushBack _mobAnchor;
};

private _worldMarkers = allMapMarkers select {
    (_x find "town_") isEqualTo 0
    || {(_x find "factory_") isEqualTo 0}
    || {(_x find "capital_") isEqualTo 0}
    || {(_x find "military_") isEqualTo 0}
};
_worldMarkers = _worldMarkers select {
    private _markerPos = getMarkerPos _x;
    !(_markerPos isEqualTo [0, 0, 0]) && {(_markerPos distance2D _mobPos) > 750}
};

private _worldPos = _mobPos;
private _worldDir = random 360;
private _worldAnchor = _mobAnchor;
if (_worldMarkers isNotEqualTo []) then {
    private _worldMarker = selectRandom _worldMarkers;
    _worldPos = getMarkerPos _worldMarker;
    _worldDir = markerDir _worldMarker;
    _worldAnchor = createVehicleLocal ["Logic", _worldPos, [], 0, "CAN_COLLIDE"];
    _cleanupObjects pushBack _worldAnchor;
};

private _mobShot1Pos = _mobPos vectorAdd ([[18, -12, 6], _mobDir] call _rotateOffset);
private _mobShot2Pos = _mobPos vectorAdd ([[-14, 15, 7], _mobDir] call _rotateOffset);
private _worldShot1Pos = _worldPos vectorAdd ([[24, -20, 14], _worldDir] call _rotateOffset);
private _worldShot2Pos = _worldPos vectorAdd ([[-18, 22, 16], _worldDir] call _rotateOffset);

private _cam = "camera" camCreate _mobShot1Pos;
if (isNull _cam) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_FAIL"];
    { if (!isNull _x) then { deleteVehicle _x; }; } forEach _cleanupObjects;
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    false
};

uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_ACTIVE"];
showCinemaBorder false;
_cam cameraEffect ["INTERNAL", "BACK"];
_cam camSetPos _mobShot1Pos;
_cam camSetTarget _mobAnchor;
_cam camSetFov 0.82;
_cam camCommit 0;

cutText ["", "BLACK FADED", 0];
uiSleep 0.05;
cutText ["", "BLACK IN", 1.5];

private _failed = false;

uiNamespace setVariable ["MWF_IntroCinematicStage", "MOB_SHOT_1"];
uiSleep 4;
if (!alive player) then { _failed = true; };

if (!_failed) then {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "MOB_SHOT_2"];
    _cam camPreparePos _mobShot2Pos;
    _cam camPrepareTarget _mobAnchor;
    _cam camPrepareFov 0.76;
    _cam camCommitPrepared 6;

    private _timeout = time + 6.5;
    waitUntil {
        uiSleep 0.05;
        !alive player || {camCommitted _cam} || {time >= _timeout}
    };

    if (!alive player) then {
        _failed = true;
    };
};

if (!_failed) then {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WORLD_TRANSITION"];
    cutText ["", "BLACK OUT", 0.8];
    uiSleep 0.9;

    _cam camSetPos _worldShot1Pos;
    _cam camSetTarget _worldAnchor;
    _cam camSetFov 0.72;
    _cam camCommit 0;

    cutText ["", "BLACK IN", 1.0];
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WORLD_SHOT_1"];
    uiSleep 4;
    if (!alive player) then {
        _failed = true;
    };
};

if (!_failed) then {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WORLD_SHOT_2"];
    _cam camPreparePos _worldShot2Pos;
    _cam camPrepareTarget _worldAnchor;
    _cam camPrepareFov 0.70;
    _cam camCommitPrepared 6;

    private _timeout2 = time + 6.5;
    waitUntil {
        uiSleep 0.05;
        !alive player || {camCommitted _cam} || {time >= _timeout2}
    };

    if (!alive player) then {
        _failed = true;
    };
};

uiNamespace setVariable ["MWF_IntroCinematicStage", "CLEANUP"];
cutText ["", "BLACK OUT", 1.0];
uiSleep 1.05;
_cam cameraEffect ["TERMINATE", "BACK"];
camDestroy _cam;
player switchCamera "INTERNAL";

{
    if (!isNull _x) then {
        deleteVehicle _x;
    };
} forEach _cleanupObjects;

uiNamespace setVariable ["MWF_IntroCinematicActive", false];
missionNamespace setVariable ["MWF_BlockRespawn", false];

if (_failed) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "FAILED"];
    false
};

uiNamespace setVariable ["MWF_IntroCinematicStage", "COMPLETE"];
uiNamespace setVariable ["MWF_IntroCinematicPlayed", true];
true
