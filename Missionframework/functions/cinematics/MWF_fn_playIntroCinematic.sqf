/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Reliable local deployment cinematic for a joining player.
    The player is already locked at the MOB/deploy position before this starts.
    Returns true when the camera cleanup path completed normally.
*/

if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith { false };

uiNamespace setVariable ["MWF_IntroCinematicStage", "ENTRY"];
uiNamespace setVariable ["MWF_IntroCinematicActive", true];
missionNamespace setVariable ["MWF_BlockRespawn", true];

private _cleanupObjects = [];
private _cleanupCamera = objNull;
private _failed = false;

private _resolveAnchor = {
    private _anchor = missionNamespace getVariable ["MWF_MOB_Table", missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]]];
    if (isNull _anchor && {!isNil "MWF_MOB_Table"}) then {
        _anchor = MWF_MOB_Table;
    };
    if (isNull _anchor && {!isNil "mob_deploy_pad"}) then {
        _anchor = mob_deploy_pad;
    };
    if (isNull _anchor) then {
        private _markerPos = getMarkerPos "respawn_west";
        if !(_markerPos isEqualTo [0,0,0]) then {
            _anchor = createVehicleLocal ["Logic", _markerPos, [], 0, "CAN_COLLIDE"];
            _cleanupObjects pushBack _anchor;
        };
    };
    if (isNull _anchor) then {
        _anchor = player;
    };
    _anchor
};

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

private _buildAnchorShot = {
    params ["_centerPos", "_dir", "_offset", ["_fov", 0.75]];
    [
        _centerPos vectorAdd ([_offset, _dir] call _rotateOffset),
        _centerPos,
        _fov
    ]
};

private _pickWorldAnchor = {
    private _markerNames = allMapMarkers select {
        (_x find "town_") isEqualTo 0
        || {(_x find "factory_") isEqualTo 0}
        || {(_x find "military_") isEqualTo 0}
        || {(_x find "capital_") isEqualTo 0}
    };

    private _chosenPos = [0, 0, 0];
    if (_markerNames isNotEqualTo []) then {
        _chosenPos = getMarkerPos (selectRandom _markerNames);
    };

    if (_chosenPos isEqualTo [0,0,0]) then {
        private _fobPad = missionNamespace getVariable ["MWF_MOB_FobPad", missionNamespace getVariable ["MWF_FOB_Box_Spawn", objNull]];
        if (!isNull _fobPad) then {
            _chosenPos = getPosATL _fobPad;
        };
    };

    if (_chosenPos isEqualTo [0,0,0]) then {
        _chosenPos = getPosATL player;
    };

    private _logic = createVehicleLocal ["Logic", _chosenPos, [], 0, "CAN_COLLIDE"];
    _cleanupObjects pushBack _logic;
    _logic
};

private _readyDeadline = diag_tickTime + 20;
uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_DISPLAY"];
waitUntil {
    uiSleep 0.05;
    (!isNull findDisplay 46 && {!isNull player} && {alive player}) || {diag_tickTime >= _readyDeadline}
};

if (diag_tickTime >= _readyDeadline) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "WAIT_TIMEOUT"];
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _cleanupObjects;
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    false
};

private _mobAnchor = call _resolveAnchor;
private _mobPos = getPosATL _mobAnchor;
private _mobDir = getDir _mobAnchor;
private _worldAnchor = call _pickWorldAnchor;
private _worldPos = getPosATL _worldAnchor;
private _worldDir = random 360;

private _shots = [
    [_mobPos, _mobDir, [16, -10, 6], 0.80] call _buildAnchorShot,
    [_mobPos, _mobDir, [-12, -15, 7], 0.74] call _buildAnchorShot,
    [_worldPos, _worldDir, [18, -12, 9], 0.78] call _buildAnchorShot,
    [_mobPos, _mobDir, [8, 18, 5], 0.76] call _buildAnchorShot
];

private _cam = "camera" camCreate ((_shots # 0) # 0);
_cleanupCamera = _cam;
if (isNull _cam) exitWith {
    uiNamespace setVariable ["MWF_IntroCinematicStage", "CAMERA_FAIL"];
    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _cleanupObjects;
    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
    false
};

showCinemaBorder false;
_cam cameraEffect ["INTERNAL", "BACK"];
_cam camSetPos ((_shots # 0) # 0);
_cam camSetTarget ((_shots # 0) # 1);
_cam camSetFov ((_shots # 0) # 2);
_cam camCommit 0;

cutText ["", "BLACK FADED", 0];
uiSleep 0.1;
cutText ["", "BLACK IN", 2];

{
    if (!alive player) exitWith { _failed = true; };

    private _camPos = _x # 0;
    private _camTarget = _x # 1;
    private _camFov = _x # 2;

    uiNamespace setVariable ["MWF_IntroCinematicStage", format ["SHOT_%1", _forEachIndex + 1]];
    _cam camPreparePos _camPos;
    _cam camPrepareTarget _camTarget;
    _cam camPrepareFov _camFov;
    _cam camCommitPrepared 6;

    private _timeout = time + 6.5;
    waitUntil {
        uiSleep 0.05;
        camCommitted _cam || {time >= _timeout} || {!alive player}
    };

    if (!alive player) exitWith { _failed = true; };
} forEach _shots;

uiNamespace setVariable ["MWF_IntroCinematicStage", "CLEANUP"];
if (!isNull _cleanupCamera) then {
    _cleanupCamera cameraEffect ["TERMINATE", "BACK"];
    camDestroy _cleanupCamera;
};
player switchCamera "INTERNAL";
cutText ["", "BLACK IN", 0.5];

{
    if (!isNull _x) then { deleteVehicle _x; };
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
