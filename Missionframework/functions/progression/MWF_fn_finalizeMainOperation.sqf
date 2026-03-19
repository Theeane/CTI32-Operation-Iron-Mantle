/*
    Author: Theane / ChatGPT
    Function: fn_finalizeMainOperation
    Project: Military War Framework

    Description:
    Applies per-operation cooldown after a successful main operation completion,
    clears the active runtime state, and saves the campaign.

    Params:
    0: STRING - operation key
*/

if (!isServer) exitWith {};

params [
    ["_key", "", [""]]
];

private _registry = [] call MWF_fnc_getMainOperationRegistry;
private _idx = _registry findIf { (_x # 0) isEqualTo _key };
private _cooldownSeconds = 3600;
if (_idx >= 0) then {
    _cooldownSeconds = (_registry # _idx) param [8, 3600, [0]];
};

private _cooldownMap = missionNamespace getVariable ["MWF_MainOperationCooldowns", createHashMap];
if (isNil "_cooldownMap" || { !(_cooldownMap isEqualType createHashMap) }) then {
    _cooldownMap = createHashMap;
};
_cooldownMap set [_key, serverTime + _cooldownSeconds];
missionNamespace setVariable ["MWF_MainOperationCooldowns", _cooldownMap, true];

missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];

[] call MWF_fnc_saveGame;
