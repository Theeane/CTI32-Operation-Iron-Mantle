params [
    ["_terminal", objNull, [objNull]],
    ["_caller", objNull, [objNull]]
];

if (!hasInterface) exitWith { false };
if (isNull _terminal) then {
    _terminal = missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull];
};
if (isNull _terminal) exitWith { false };

missionNamespace setVariable ["MWF_CommandTerminal_Object", _terminal];
if (!isNull _caller) then {
    missionNamespace setVariable ["MWF_CommandTerminal_User", _caller];
};

uiNamespace setVariable ["MWF_RedeployShell_Active", true];
uiNamespace setVariable ["MWF_RedeployShell_ReturnTerminal", _terminal];

["OPEN"] call MWF_fnc_dataHub;
["SET_MODE", "REDEPLOY"] call MWF_fnc_dataHub;
true
