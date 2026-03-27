/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Handles setup interactions for the core framework layer. For the MOB computer this
    routes through the campaign-phase login bridge.

    Interaction registration is local per client because BIS_fnc_holdActionAdd is local UI state.
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) then {
    private _deadline = diag_tickTime + 60;

    while {isNull _object && {diag_tickTime < _deadline}} do {
        if (isNull _object) then {
            _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];
        };

        if (isNull _object && {!isNil "MWF_Intel_Center"}) then {
            _object = MWF_Intel_Center;
        };

        if (isNull _object) then {
            private _anchorObjects = [];

            {
                if (!isNil _x) then {
                    private _candidate = missionNamespace getVariable [_x, objNull];
                    if (!isNull _candidate) then {
                        _anchorObjects pushBackUnique _candidate;
                    };
                };
            } forEach ["MWF_MOB_Table", "MWF_MainBase", "MWF_MOB", "MWF_MOB_Object", "MWF_MOB_DeployPad", "MWF_MOB_FobPad"];

            if (!isNil "mob_deploy_pad") then {
                _anchorObjects pushBackUnique mob_deploy_pad;
            };
            if (!isNil "MWF_MOB_Table") then {
                _anchorObjects pushBackUnique MWF_MOB_Table;
            };

            private _anchorPositions = [];
            {
                if (!isNull _x) then {
                    _anchorPositions pushBackUnique (getPosATL _x);
                };
            } forEach _anchorObjects;

            private _mobMarkerPos = if (markerColor "MWF_MOB_Marker" isNotEqualTo "") then { getMarkerPos "MWF_MOB_Marker" } else { [0, 0, 0] };
            if !(_mobMarkerPos isEqualTo [0, 0, 0]) then {
                _anchorPositions pushBackUnique _mobMarkerPos;
            };

            private _respawnMarkerPos = getMarkerPos "respawn_west";
            if ((_anchorPositions isEqualTo []) && {!(_respawnMarkerPos isEqualTo [0, 0, 0])}) then {
                _anchorPositions pushBackUnique _respawnMarkerPos;
            };

            {
                private _candidates = nearestObjects [
                    _x,
                    [
                        "Land_Laptop_unfolded_F",
                        "RuggedTerminal_01_communications_F",
                        "Land_DataTerminal_01_F"
                    ],
                    100,
                    true
                ];
                if (_candidates isNotEqualTo []) exitWith {
                    _object = _candidates # 0;
                };
            } forEach _anchorPositions;
        };

        if (isNull _object) then {
            uiSleep 1;
        };
    };
};

if (isNull _object) exitWith {
    diag_log "[MWF Setup] MOB login interaction setup skipped: no valid computer object found after retries.";
};

private _existingActionId = _object getVariable ["MWF_MOB_LoginActionId", -1];
if (_existingActionId >= 0) then {
    [_object, _existingActionId] call BIS_fnc_holdActionRemove;
};

private _actionId = [
    _object,
    "Login to Command Network",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "alive _caller && {_caller distance _target < 2}",
    "alive _caller && {_caller distance _target < 2} && {!(missionNamespace getVariable ['MWF_BlockRespawn', false])}",
    {
        params ["_target", "_caller"];
        _caller playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1";
        systemChat "Establishing encrypted connection...";
    },
    {},
    {
        params ["_target", "_caller"];
        [_target, _caller] call MWF_fnc_MOBComputerLogin;
        _caller switchMove "";
    },
    {
        params ["_target", "_caller"];
        _caller switchMove "";
        systemChat "Login aborted.";
    },
    [],
    8,
    10,
    false,
    false
] call BIS_fnc_holdActionAdd;

_object setVariable ["MWF_MOB_LoginActionId", _actionId];
diag_log format ["[MWF Setup] Campaign-phase MOB login interaction added locally to %1 (action %2).", _object, _actionId];
