/*
    Author: Theane / ChatGPT
    Function: fn_infrastructureManager
    Project: Military War Framework

    Description:
    Handles HQ and roadblock destruction tracking and infrastructure integration.
    Updated to preserve persistent destroyed-object registries and feed the threat layer.
*/

if (!isServer) exitWith {};

params [["_mode", "INIT"], ["_params", []]];

// --- MODE: INIT ---
if (_mode == "INIT") exitWith {
    if (missionNamespace getVariable ["MWF_InfrastructureManagerStarted", false]) exitWith {};
    missionNamespace setVariable ["MWF_InfrastructureManagerStarted", true, true];

    diag_log "[MWF INFRA] Infrastructure Manager Initialized.";

    ["MWF_Infra_Destroyed", {
        params [
            ["_type", "ROADBLOCK", [""]],
            ["_position", [], [[]]],
            ["_objectNetId", "", [""]],
            ["_destroyerUid", "", [""]],
            ["_destroyerName", "Unknown", [""]]
        ];

        private _normalizedType = toUpper _type;
        private _registryVar = if (_normalizedType == "HQ") then {"MWF_DestroyedHQs"} else {"MWF_DestroyedRoadblocks"};
        private _destroyedRegistry = + (missionNamespace getVariable [_registryVar, []]);

        if ((_position isEqualType []) && {count _position >= 2}) then {
            _destroyedRegistry pushBackUnique _position;
            missionNamespace setVariable [_registryVar, _destroyedRegistry, true];
        };

        private _supplyReward = if (_normalizedType == "HQ") then {50} else {20};
        private _supplyVar = "MWF_Economy_Supplies";
        private _totalSupplies = missionNamespace getVariable [_supplyVar, missionNamespace getVariable ["MWF_Supplies", 0]];
        _totalSupplies = _totalSupplies + _supplyReward;

        missionNamespace setVariable [_supplyVar, _totalSupplies, true];
        missionNamespace setVariable ["MWF_Supplies", _totalSupplies, true];

        if (!isNil "MWF_fnc_registerThreatIncident") then {
            [
                if (_normalizedType == "HQ") then {"hq_destroyed"} else {"roadblock_destroyed"},
                "",
                if (_normalizedType == "HQ") then {4} else {2},
                format ["%1 destroyed", _normalizedType]
            ] call MWF_fnc_registerThreatIncident;
        } else {
            if (!isNil "MWF_fnc_markThreatDirty") then {
                ["infrastructure_destroyed"] call MWF_fnc_markThreatDirty;
            };
        };

        if (_destroyerUid isNotEqualTo "" && {!isNil "MWF_fnc_recordCampaignEvent"}) then {
            [_destroyerUid, _destroyerName, "HQ_ROADBLOCKS_DESTROYED", 1] call MWF_fnc_recordCampaignEvent;
        };

        if (!isNil "MWF_fnc_saveGame") then {
            ["Infrastructure Destroyed"] call MWF_fnc_saveGame;
        };

        diag_log format ["[MWF INFRA] %1 destroyed. Reward: %2 supplies.", _normalizedType, _supplyReward];

        if (!isNil "CBA_fnc_globalEvent") then {
            ["MWF_Notify", ["Objective Complete", format ["%1 neutralized. Received %2 supplies.", _normalizedType, _supplyReward]]] call CBA_fnc_globalEvent;
        };
    }] call CBA_fnc_addEventHandler;
};

// --- MODE: REGISTER ---
if (_mode == "REGISTER") exitWith {
    _params params [
        ["_object", objNull, [objNull]],
        ["_type", "ROADBLOCK", [""]]
    ];

    if (isNull _object) exitWith {};

    private _normalizedType = toUpper _type;
    _object setVariable ["MWF_InfraType", _normalizedType, true];

    if (!isNil "MWF_fnc_intelManager") then {
        ["SPAWN_INTEL", [getPosWorld _object, _normalizedType]] call MWF_fnc_intelManager;
    };

    _object addEventHandler ["Killed", {
        params ["_unit", "_killer", "_instigator"];
        private _type = _unit getVariable ["MWF_InfraType", "ROADBLOCK"];

        private _actor = if (!isNull _instigator) then { _instigator } else { _killer };
        if (!isNull _actor && {!isPlayer _actor}) then {
            private _veh = vehicle _actor;
            if (!isNull _veh) then {
                private _cmd = effectiveCommander _veh;
                if (!isNull _cmd && {isPlayer _cmd}) then {
                    _actor = _cmd;
                };
            };
        };

        private _uid = if (!isNull _actor && {isPlayer _actor}) then { getPlayerUID _actor } else { "" };
        private _name = if (!isNull _actor && {isPlayer _actor}) then { name _actor } else { "Unknown" };

        ["MWF_Infra_Destroyed", [_type, getPosWorld _unit, netId _unit, _uid, _name]] call CBA_fnc_serverEvent;
    }];

    diag_log format ["[MWF INFRA] Registered %1 at %2.", _normalizedType, getPosWorld _object];
};
