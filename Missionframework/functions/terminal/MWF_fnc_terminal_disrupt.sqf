/*
    Author: Gemini / ChatGPT
    Purpose: Reveal hidden infrastructure using the current registry/revealed-ID model.
*/
params [
    ["_unit", objNull, [objNull]],
    ["_serverCommit", false, [true]]
];

if (_serverCommit) exitWith {
    if (!isServer || isNull _unit) exitWith {};

    private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
    if (_intel < 150) exitWith {
        [["INSUFFICIENT INTEL", "Encryption crack requires 150 Intel."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    private _registry = +(missionNamespace getVariable ["MWF_InfrastructureRegistry", []]);
    private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
    private _destroyedHQs = +(missionNamespace getVariable ["MWF_DestroyedHQs", []]);
    private _destroyedRoadblocks = +(missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]);
    private _candidates = [];

    {
        if (_x isEqualType [] && {count _x >= 4}) then {
            _x params [
                ["_infraId", "", [""]],
                ["_infraType", "ROADBLOCK", [""]],
                ["_object", objNull, [objNull]],
                ["_storedPos", [0,0,0], [[]]]
            ];

            private _typeUpper = toUpper _infraType;
            private _pos = if (!isNull _object) then { getPosATL _object } else { +_storedPos };
            private _destroyedRegistry = if (_typeUpper isEqualTo "HQ") then { _destroyedHQs } else { _destroyedRoadblocks };

            if (
                _infraId isNotEqualTo "" &&
                {!(_infraId in _revealedIds)} &&
                {_typeUpper in ["HQ", "ROADBLOCK"]} &&
                {_pos isEqualType []} && {(count _pos) >= 2} &&
                {(_destroyedRegistry findIf { _x distance2D _pos < 35 }) < 0}
            ) then {
                _candidates pushBack [_infraId, _typeUpper];
            };
        };
    } forEach _registry;

    if (_candidates isEqualTo []) exitWith {
        [["DATABASE DEPLETED", "No unknown infrastructure located."], "info"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    private _picked = selectRandom _candidates;
    _picked params ["_infraId", "_infraType"];
    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    [_supplies, (_intel - 150) max 0, _notoriety] call MWF_fnc_syncEconomyState;

    _revealedIds pushBackUnique _infraId;
    missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", _revealedIds, true];

    [["TARGET LOCATED", format ["Position marked: %1.", if (_infraType isEqualTo "HQ") then {"Enemy HQ"} else {"Roadblock"}]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    [["INTEL UPDATE", "New enemy infrastructure revealed on map."], "info"] remoteExecCall ["MWF_fnc_showNotification", [0, -1] select isDedicated];

    if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
};

if (!hasInterface || _unit != player) exitWith {};
[_unit, true] remoteExecCall ["MWF_fnc_terminal_disrupt", 2];
