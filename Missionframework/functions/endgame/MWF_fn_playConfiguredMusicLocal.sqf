/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_playConfiguredMusicLocal
    Description: Local music playback helper shared by deploy/endgame soundtrack hooks.
    Supports either a missionNamespace variable name or a direct CfgMusic classname fallback.
*/
params [["_namespaceVar", "", [""]], ["_fallbackClass", "", [""]]];

if (!hasInterface) exitWith { false };

private _trackClass = "";
if (_namespaceVar isNotEqualTo "") then {
    if (isClass (configFile >> "CfgMusic" >> _namespaceVar)) then {
        _trackClass = _namespaceVar;
    } else {
        _trackClass = missionNamespace getVariable [_namespaceVar, _fallbackClass];
    };
} else {
    _trackClass = _fallbackClass;
};

if !(_trackClass isEqualType "") exitWith { false };
if (_trackClass isEqualTo "") exitWith { false };
if !(isClass (configFile >> "CfgMusic" >> _trackClass)) exitWith { false };

0 fadeMusic 1;
playMusic _trackClass;
true
