/*
    Author: OpenAI / ChatGPT
    Function: fn_playSharedMusic
    Project: Military War Framework

    Description:
    Shared music bridge used by deploy and endgame flows.
    Keeps soundtrack hooks in one place so classnames can be swapped later.
*/
params [
    ["_mode", "PLAY", [""]],
    ["_musicClass", "", [""]]
];

private _modeUpper = toUpper _mode;

if (_modeUpper isEqualTo "STOP") exitWith {
    if (hasInterface) then { 0 fadeMusic 1; playMusic ""; };
    true
};

if (_musicClass isEqualTo "") exitWith { false };

if (isServer && {!hasInterface}) exitWith {
    [_mode, _musicClass] remoteExec ["MWF_fnc_playSharedMusic", 0];
    true
};

if (!hasInterface) exitWith { false };
if (!isNil "MWF_fnc_playConfiguredMusicLocal") exitWith { ["", _musicClass] call MWF_fnc_playConfiguredMusicLocal };
0 fadeMusic 1;
playMusic _musicClass;
true
