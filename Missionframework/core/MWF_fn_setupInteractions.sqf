/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Handles setup interactions for the core framework layer.
    For the MOB computer this routes through the campaign-phase login bridge,
    so a loaded OPEN_WAR campaign never replays tutorial gates for any player.
*/

params [["_object", objNull, [objNull]]];

// Allow callers to omit the MOB terminal object. Prefer the explicitly named
// editor laptop, then fall back to a short-range search around the MOB table,
// and only then around the respawn marker.
if (isNull _object) then {
    _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];
};

if (isNull _object) then {
    private _table = missionNamespace getVariable ["MWF_MOB_Table", objNull];
    if (!isNull _table) then {
        private _candidates = nearestObjects [
            getPosATL _table,
            [
                "Land_Laptop_unfolded_F",
                "RuggedTerminal_01_communications_F",
                "Land_DataTerminal_01_F"
            ],
            8
        ];
        if (_candidates isNotEqualTo []) then {
            _object = _candidates # 0;
        };
    };
};

if (isNull _object) then {
    private _mobPos = getMarkerPos "respawn_west";
    if !(_mobPos isEqualTo [0,0,0]) then {
        private _candidates = nearestObjects [
            _mobPos,
            [
                "Land_Laptop_unfolded_F",
                "RuggedTerminal_01_communications_F",
                "Land_DataTerminal_01_F"
            ],
            25
        ];
        if (_candidates isNotEqualTo []) then {
            _object = _candidates # 0;
        };
    };
};

if (isNull _object) exitWith {};
if (_object getVariable ["MWF_MOB_LoginInit", false]) exitWith {};
_object setVariable ["MWF_MOB_LoginInit", true, true];

[
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

diag_log format ["[MWF Setup] Campaign-phase MOB login interaction added to %1.", _object];
