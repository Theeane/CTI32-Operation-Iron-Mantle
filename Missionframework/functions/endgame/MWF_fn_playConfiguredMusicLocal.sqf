/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_playConfiguredMusicLocal
    Description: Local music playback helper shared by deploy/endgame soundtrack hooks.
*/
params [["_namespaceVar", "", [""]], ["_fallbackClass", "", [""]]];

if (!hasInterface) exitWith {};
if (_namespaceVar isEqualTo "") exitWith {};

private _trackClass = missionNamespace getVariable [_namespaceVar, _fallbackClass];
if (_trackClass isEqualType "" && {_trackClass isNotEqualTo ""}) then {
    playMusic _trackClass;
};
