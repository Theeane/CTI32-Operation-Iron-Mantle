/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Reliable local orbital intro cinematic.
    Runs once per client session after continue/join, strips the player's gear
    during the camera move, and exits on a black screen so the engine can hand
    over to the respawn menu cleanly.
*/

if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicActive", false]) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith { false };

uiNamespace setVariable ["MWF_IntroCinematicActive", true];
missionNamespace setVariable ["MWF_BlockRespawn", true];

private _cleanupObjects = [];
private _cam = objNull;
private _gearWipeDone = false;

private _cleanup = {
    params [["_keepBlack", true, [true]]];

    if (!isNull _cam) then {
        _cam cameraEffect ["TERMINATE", "BACK"];
        camDestroy _cam;
    };

    player switchCamera "INTERNAL";

    if (!_keepBlack) then {
        cutText ["", "BLACK IN", 0.35];
    };

    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach _cleanupObjects;

    uiNamespace setVariable ["MWF_IntroCinematicActive", false];
    missionNamespace setVariable ["MWF_BlockRespawn", false];
};

private _resolveAnchor = {
    private _anchor = missionNamespace getVariable [
        "MWF_MOB_AssetAnchor",
        missionNamespace getVariable [
            "MWF_Intel_Center",
            missionNamespace getVariable [
                "MWF_MOB_Table",
                missionNamespace getVariable ["MWF_MOB", objNull]
            ]
        ]
    ];

    if (isNull _anchor && {!isNil "MWF_MOB_AssetAnchor"}) then { _anchor = MWF_MOB_AssetAnchor; };
    if (isNull _anchor && {!isNil "MWF_Intel_Center"}) then { _anchor = MWF_Intel_Center; };
    if (isNull _anchor && {!isNil "MWF_MOB_Table"}) then { _anchor = MWF_MOB_Table; };
    if (isNull _anchor && {!isNil "mob_deploy_pad"}) then { _anchor = mob_deploy_pad; };

    if (isNull _anchor) then {
        private _markerPos = getMarkerPos "respawn_west";
        if !(_markerPos isEqualTo [0,0,0]) then {
            _anchor = createVehicleLocal ["Logic", _markerPos, [], 0, "CAN_COLLIDE"];
            _cleanupObjects pushBack _anchor;
        };
    };

    if (isNull _anchor) then { _anchor = player; };
    _anchor
};

private _deadline = diag_tickTime + 20;
waitUntil {
    uiSleep 0.05;
    (!isNull findDisplay 46 && {!isNull player} && {alive player}) || {diag_tickTime >= _deadline}
};
if (diag_tickTime >= _deadline) exitWith {
    [false] call _cleanup;
    false
};

private _anchor = call _resolveAnchor;
private _center = getPosATL _anchor;
private _radius = 30;
private _height = 6;
private _duration = 30;
private _startAngle = getDir _anchor;
private _startedAt = diag_tickTime;

_cam = "camera" camCreate (_center vectorAdd [0, -_radius, _height]);
if (isNull _cam) exitWith {
    [false] call _cleanup;
    false
};

showCinemaBorder false;
_cam cameraEffect ["INTERNAL", "BACK"];
_cam camSetFov 0.78;
_cam camCommit 0;
cutText ["", "BLACK FADED", 0];
uiSleep 0.1;
cutText ["", "BLACK IN", 2];

while {
    alive player &&
    {diag_tickTime < (_startedAt + _duration)} &&
    {uiNamespace getVariable ["MWF_IntroCinematicActive", false]}
} do {
    private _elapsed = diag_tickTime - _startedAt;
    private _progress = (_elapsed / _duration) max 0 min 1;
    private _angle = _startAngle + (_progress * 360);
    private _targetCenter = getPosATL _anchor;
    private _camPos = [
        (_targetCenter # 0) + (sin _angle * _radius),
        (_targetCenter # 1) + (cos _angle * _radius),
        (_targetCenter # 2) + _height
    ];

    if (!_gearWipeDone && {_elapsed >= 0.75} && {!isNil "MWF_fnc_applyBaselineLoadout"}) then {
        [player, true] call MWF_fnc_applyBaselineLoadout;
        _gearWipeDone = true;
    };

    _cam camSetPos _camPos;
    _cam camSetTarget _anchor;
    _cam camCommit 0;
    uiSleep 0.01;
};

cutText ["", "BLACK OUT", 1];
uiSleep 1;
[true] call _cleanup;
uiNamespace setVariable ["MWF_IntroCinematicPlayed", true];
true
