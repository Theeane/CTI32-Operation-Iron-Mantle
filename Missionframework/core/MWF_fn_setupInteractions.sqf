/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Resolves the runtime MOB terminal and injects terminal actions directly.
    Login gating is removed. The function remains lightweight and retry-based
    so clients can catch the server-spawned terminal after replication.
*/

params [["_object", objNull, [objNull]]];

if (!hasInterface) exitWith { false };

private _resolveNamedObject = {
    params ["_varName"];
    private _obj = missionNamespace getVariable [_varName, objNull];
    if (isNull _obj && {!isNil _varName}) then {
        _obj = call compile _varName;
    };
    _obj
};

private _resolveTerminal = {
    params [["_candidate", objNull, [objNull]]];
    private _resolved = _candidate;

    if (isNull _resolved) then {
        _resolved = ["MWF_Intel_Center"] call _resolveNamedObject;
    };

    if (isNull _resolved) then {
        private _assetAnchor = ["MWF_MOB_AssetAnchor"] call _resolveNamedObject;
        if (!isNull _assetAnchor) then {
            private _candidates = nearestObjects [
                getPosATL _assetAnchor,
                ["Land_Laptop_unfolded_F", "RuggedTerminal_01_communications_F", "Land_DataTerminal_01_F"],
                8,
                true
            ];
            if (_candidates isNotEqualTo []) then {
                _resolved = _candidates # 0;
            };
        };
    };

    _resolved
};

private _deadline = diag_tickTime + 30;
_object = [_object] call _resolveTerminal;
while {isNull _object && {diag_tickTime < _deadline}} do {
    uiSleep 1;
    _object = [objNull] call _resolveTerminal;
};

if (isNull _object) exitWith {
    diag_log "[MWF Setup] Terminal setup deferred: no valid MOB terminal object resolved yet.";
    false
};

private _existingActionId = _object getVariable ["MWF_MOB_LoginActionId", -1];
if (_existingActionId >= 0) then {
    [_object, _existingActionId] call BIS_fnc_holdActionRemove;
    _object setVariable ["MWF_MOB_LoginActionId", -1];
};

if (!isNil "MWF_fnc_terminal_main") then {
    ["INIT_SCROLL", _object] call MWF_fnc_terminal_main;
    ["INIT_ACE", _object] call MWF_fnc_terminal_main;
};

_object setVariable ["MWF_MOB_TerminalReady", true, true];
diag_log format ["[MWF Setup] Runtime terminal interactions initialized on %1.", _object];
true
