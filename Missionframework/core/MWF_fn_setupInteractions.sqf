/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Handles setup interactions for the core framework layer. For the MOB computer this
    routes through the campaign-phase login bridge, so a loaded OPEN_WAR campaign never
    replays tutorial gates for any player. Interaction registration is local per client,
    because BIS_fnc_holdActionAdd is local UI state.
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

            private _deployPadNs = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];
            if (!isNull _deployPadNs) then {
                _anchorObjects pushBackUnique _deployPadNs;
            };

            if (!isNil "mob_deploy_pad") then {
                _anchorObjects pushBackUnique mob_deploy_pad;
            };

            private _mobTable = missionNamespace getVariable ["MWF_MOB_Table", objNull];
            if (!isNull _mobTable) then {
                _anchorObjects pushBackUnique _mobTable;
            };
            if (!isNil "MWF_MOB_Table") then {
                _anchorObjects pushBackUnique MWF_MOB_Table;
            };

            private _mobObject = missionNamespace getVariable ["MWF_MOB_Object", objNull];
            if (!isNull _mobObject) then {
                _anchorObjects pushBackUnique _mobObject;
            };
            if (!isNil "MWF_MOB") then {
                _anchorObjects pushBackUnique MWF_MOB;
            };

            private _anchorPositions = [];
            {
                if (!isNull _x) then {
                    _anchorPositions pushBackUnique (getPosATL _x);
                };
            } forEach _anchorObjects;

            private _mobPos = getMarkerPos "respawn_west";
            if !(_mobPos isEqualTo [0,0,0]) then {
                _anchorPositions pushBackUnique _mobPos;
            };

            {
                private _candidates = nearestObjects [
                    _x,
                    [
                        "Land_Laptop_unfolded_F",
                        "RuggedTerminal_01_communications_F",
                        "Land_DataTerminal_01_F"
                    ],
                    100
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
    "_this distance _target < 2",
    "_caller distance _target < 2",
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
