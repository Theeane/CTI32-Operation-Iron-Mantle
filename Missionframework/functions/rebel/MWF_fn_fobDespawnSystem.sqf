/*
    Author: Theane / ChatGPT
    Function: fn_fobDespawnSystem
    Project: Military War Framework

    Description:
    Handles damaged FOB collapse timers and despawn cleanup.

    Modes:
    - START          : start collapse countdown for a damaged FOB
    - DESPAWN        : remove the FOB and attached assets
    - RESTORE_PENDING: restore saved damaged FOB timers after load
*/

if (!isServer) exitWith {false};

params [
    ["_mode", "START", [""]],
    ["_arg1", objNull],
    ["_arg2", 0]
];

private _findTerminalByPos = {
    params ["_targetPosASL", "_targetName", "_targetMarker"];
    private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
    private _best = objNull;
    private _bestDist = 1e10;
    {
        private _obj = _x param [1, objNull];
        private _name = _x param [2, ""];
        private _marker = _x param [0, ""];
        if (!isNull _obj) then {
            if (_targetName != "" && {_name isEqualTo _targetName}) exitWith { _best = _obj; };
            if (_targetMarker != "" && {_marker isEqualTo _targetMarker}) exitWith { _best = _obj; };
            if (_targetPosASL isEqualType [] && {count _targetPosASL >= 2}) then {
                private _dist = (getPosASL _obj) distance2D _targetPosASL;
                if (_dist < _bestDist) then {
                    _best = _obj;
                    _bestDist = _dist;
                };
            };
        };
    } forEach _registry;
    _best
};

if (_mode == "DESPAWN") exitWith {
    private _terminal = _arg1;
    if (isNull _terminal) exitWith {false};

    private _displayName = _terminal getVariable ["MWF_FOB_DisplayName", "FOB"];
    private _marker = _terminal getVariable ["MWF_FOB_Marker", ""];
    private _terminalPos = getPosASL _terminal;

    ["REMOVE", _terminal] remoteExec ["MWF_fnc_fobRepairInteraction", 0, true];
    [_terminal, _marker, true] call MWF_fnc_unregisterFOB;

    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach [
        _terminal getVariable ["MWF_AttachedRoof", objNull],
        _terminal getVariable ["MWF_AttachedSiren", objNull],
        _terminal getVariable ["MWF_AttachedLamp", objNull],
        _terminal getVariable ["MWF_AttachedTable", objNull]
    ];

    deleteVehicle _terminal;

    private _damaged = missionNamespace getVariable ["MWF_DamagedFOBs", []];
    _damaged = _damaged select {
        private _savedPos = _x param [0, []];
        !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance2D _terminalPos <= 5})
    };
    missionNamespace setVariable ["MWF_DamagedFOBs", _damaged, true];
    missionNamespace setVariable ["MWF_FOBAttackState", ["idle"], true];
    missionNamespace setVariable ["MWF_isUnderAttack", false, true];

    [format ["%1 has collapsed and has been lost.", _displayName]] remoteExec ["systemChat", 0];

    private _remainingFOBs = (missionNamespace getVariable ["MWF_FOB_Registry", []]) select { !isNull (_x param [1, objNull]) };
    if ((count _remainingFOBs) == 0) then {
        [] call MWF_fnc_spawnInitialFOBAsset;
        diag_log format ["[MWF Rebel] %1 despawned and no FOBs remained. Spawned replacement deployable FOB asset at MOB.", _displayName];
    };

    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] call MWF_fnc_requestDelayedSave;
    };

    diag_log format ["[MWF Rebel] Damaged FOB despawned: %1", _displayName];
    true
};

if (_mode == "RESTORE_PENDING") exitWith {
    private _pending = +(missionNamespace getVariable ["MWF_PendingDamagedFOBs", []]);
    if (_pending isEqualTo []) exitWith {false};

    missionNamespace setVariable ["MWF_PendingDamagedFOBs", [], true];
    private _unresolved = [];

    {
        _x params [
            ["_posASL", [], [[]]],
            ["_name", "", [""]],
            ["_marker", "", [""]],
            ["_remaining", 0, [0]],
            ["_repairCost", 0, [0]],
            ["_originType", "TRUCK", [""]]
        ];

        if (_remaining > 0) then {
            private _terminal = [_posASL, _name, _marker] call _findTerminalByPos;
            if (isNull _terminal) then {
                _unresolved pushBack _x;
                diag_log format ["[MWF Rebel] Pending damaged FOB restore deferred for %1.", _name];
            } else {
                private _deadline = diag_tickTime + _remaining;
                _terminal setVariable ["MWF_FOB_IsDamaged", true, true];
                _terminal setVariable ["MWF_FOB_RepairCost", _repairCost, true];
                _terminal setVariable ["MWF_FOB_DespawnDeadline", _deadline, true];
                _terminal setVariable ["MWF_isUnderAttack", false, true];
                _terminal allowDamage false;
                _terminal setDamage 0.89;

                private _damaged = missionNamespace getVariable ["MWF_DamagedFOBs", []];
                _damaged = _damaged select {
                    private _savedPos = _x param [0, []];
                    !(_savedPos isEqualType [] && {count _savedPos >= 2} && {_savedPos distance2D (getPosASL _terminal) <= 5})
                };
                _damaged pushBack [getPosASL _terminal, _name, _marker, _deadline, _repairCost, _originType];
                missionNamespace setVariable ["MWF_DamagedFOBs", _damaged, true];

                ["ATTACH", _terminal] remoteExec ["MWF_fnc_fobRepairInteraction", 0, true];
                ["START", _terminal] spawn MWF_fnc_fobDespawnSystem;
            };
        };
    } forEach _pending;

    if (_unresolved isNotEqualTo []) then {
        missionNamespace setVariable ["MWF_PendingDamagedFOBs", _unresolved, true];
    };

    true
};

if (_mode != "START") exitWith {false};

private _terminal = _arg1;
if (isNull _terminal) exitWith {false};
if !(_terminal getVariable ["MWF_FOB_IsDamaged", false]) exitWith {false};

private _ticket = str (serverTime + random 9999);
_terminal setVariable ["MWF_FOB_DespawnTicket", _ticket, true];

[_terminal, _ticket] spawn {
    params ["_fobTerminal", "_ticketId"];
    if (isNull _fobTerminal) exitWith {};

    while {
        !isNull _fobTerminal &&
        alive _fobTerminal &&
        (_fobTerminal getVariable ["MWF_FOB_IsDamaged", false]) &&
        ((_fobTerminal getVariable ["MWF_FOB_DespawnTicket", ""]) isEqualTo _ticketId)
    } do {
        private _deadline = _fobTerminal getVariable ["MWF_FOB_DespawnDeadline", -1];
        if (_deadline >= 0 && {diag_tickTime >= _deadline}) exitWith {
            ["DESPAWN", _fobTerminal] call MWF_fnc_fobDespawnSystem;
        };
        uiSleep 5;
    };
};

true
