/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_playIntroCinematic
    Project: Military War Framework

    Description:
    Plays a lightweight local 30-second intro cinematic near the MOB or player spawn
    so the rest of the mission can finish settling in. Text is sourced from Stringtable.xml.
    Optional music can be supplied through missionNamespace variable MWF_IntroMusicClass,
    which should point at a valid CfgMusic classname.
*/
if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_IntroCinematicPlayed", false]) exitWith { false };

private _joinWindow = 180;
if ((serverTime > 0) && {serverTime > _joinWindow}) exitWith { false };

uiNamespace setVariable ["MWF_IntroCinematicPlayed", true];

[] spawn {
    waitUntil { !isNull player && {alive player} };
    sleep 0.25;

    private _anchor = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    if (isNull _anchor) then {
        _anchor = player;
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
        [30, -22, 10],
        [-24, -30, 13],
        [-18, 26, 15],
        [12, 34, 12]
    ];
    private _shotPositions = _shotOffsets apply { _anchorPos vectorAdd ([_x, _anchorDir] call _rotateOffset) };
    private _shotFovs = [0.78, 0.74, 0.70, 0.76];

    private _cam = "camera" camCreate (_shotPositions # 0);
    if (isNull _cam) exitWith {};

    showCinemaBorder false;
    _cam cameraEffect ["INTERNAL", "BACK"];
    _cam camSetPos (_shotPositions # 0);
    _cam camSetTarget _anchor;
    _cam camSetFov (_shotFovs # 0);
    _cam camCommit 0;

    cutText ["", "BLACK FADED", 0];
    sleep 0.1;
    cutText ["", "BLACK IN", 2];

    private _introMusicClass = missionNamespace getVariable ["MWF_IntroMusicClass", ""];
    private _startedMusic = false;
    if (_introMusicClass isEqualType "" && {_introMusicClass isNotEqualTo ""} && {!isNil "MWF_fnc_playSharedMusic"}) then {
        _startedMusic = ["PLAY", _introMusicClass] call MWF_fnc_playSharedMusic;
    };

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

    if (_startedMusic && {!isNil "MWF_fnc_playSharedMusic"}) then {
        ["STOP", ""] call MWF_fnc_playSharedMusic;
    };

    _cam cameraEffect ["TERMINATE", "BACK"];
    camDestroy _cam;
    player switchCamera "INTERNAL";
    cutText ["", "BLACK IN", 0.5];
};

true
