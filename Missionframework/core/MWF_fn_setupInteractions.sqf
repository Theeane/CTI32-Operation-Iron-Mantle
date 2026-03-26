/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupInteractions
    Project: Military War Framework

    Description:
    Handles setup interactions for the core framework layer. For the MOB computer this
    routes through the campaign-phase login bridge, so a loaded OPEN_WAR campaign never
    replays tutorial gates for any player. Prioritizes the named editor laptop first.
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) then {
    _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];
};

if (isNull _object) then {
    private _searchOrigins = [];

    private _table = missionNamespace getVariable ["MWF_MOB_Table", objNull];
    if (!isNull _table) then { _searchOrigins pushBackUnique (getPosATL _table); };

    private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
    if (!isNull _mainBase) then { _searchOrigins pushBackUnique (getPosATL _mainBase); };

    private _deployPad = missionNamespace getVariable ["MWF_MOB_DeployPad", objNull];
    if (!isNull _deployPad) then { _searchOrigins pushBackUnique (getPosATL _deployPad); };

    private _mobPos = getMarkerPos "respawn_west";
    if !(_mobPos isEqualTo [0,0,0]) then { _searchOrigins pushBackUnique _mobPos; };

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
    } forEach _searchOrigins;
};

if (isNull _object) exitWith {
    diag_log "[MWF Setup] WARNING: No MOB interaction object found for client interaction setup.";
};
if (_object getVariable ["MWF_MOB_LoginInit", false]) exitWith {};
_object setVariable ["MWF_MOB_LoginInit", true];

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
