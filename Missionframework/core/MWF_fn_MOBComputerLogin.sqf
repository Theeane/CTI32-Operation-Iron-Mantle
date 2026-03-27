/*
    Author: Theane / ChatGPT
    Function: MWF_fn_MOBComputerLogin
    Project: Military War Framework

    Description:
    Compatibility shim. Computer login has been removed as a gameplay gate.
    Any remaining call path simply grants direct terminal access.
*/

params [
    ["_target", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (!hasInterface) exitWith { false };
if (isNull _caller) then {
    _caller = player;
};
if (isNull _caller) exitWith { false };
if (!local _caller) exitWith { false };

_caller setVariable ["MWF_Player_Authenticated", true, true];
missionNamespace setVariable ["MWF_system_active", true, true];

if (!isNull _target && {!isNil "MWF_fnc_terminal_main"}) then {
    ["INIT_SCROLL", _target] call MWF_fnc_terminal_main;
    ["INIT_ACE", _target] call MWF_fnc_terminal_main;
};

[ ["COMMAND NETWORK", "Terminal access available."], "success" ] call MWF_fnc_showNotification;
true
