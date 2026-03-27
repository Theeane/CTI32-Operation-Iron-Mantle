/*
    Author: Theane / ChatGPT
    Function: MWF_fn_MOBComputerLogin
    Project: Military War Framework

    Description:
    Compatibility bridge.
    Computer login has been retired; if any legacy call path still invokes this
    function, it now grants immediate terminal access instead of gating gameplay.
*/

params [
    ["_target", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (isNull _caller) exitWith { false };
if (!hasInterface) exitWith { false };
if (!local _caller) exitWith { false };

_caller setVariable ["MWF_Player_Authenticated", true, true];
missionNamespace setVariable ["MWF_system_active", true, true];

if (!isNil "MWF_fnc_updateResourceUI") then {
    [] spawn MWF_fnc_updateResourceUI;
};

if (!isNull _target && {!isNil "MWF_fnc_terminal_main"}) then {
    ["INIT_SCROLL", _target] call MWF_fnc_terminal_main;
    ["INIT_ACE", _target] call MWF_fnc_terminal_main;
};

[
    ["COMMAND NETWORK", "Terminal ready."],
    "success"
] call MWF_fnc_showNotification;

systemChat "Command terminal ready.";
true
