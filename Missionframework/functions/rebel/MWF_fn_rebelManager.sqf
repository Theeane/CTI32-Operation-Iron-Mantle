/*
    Author: Theane / ChatGPT
    Function: fn_rebelManager
    Project: Military War Framework

    Description:
    Compatibility wrapper for the rebel system.
*/

if (!isServer) exitWith {};

params [
    ["_mode", "MIGRATE", [""]],
    ["_arg1", objNull],
    ["_arg2", objNull]
];

if (_mode == "REFRESH_ZONES") exitWith {
    diag_log "[KPIN REBEL]: Clean Slate initiated. Despawning leader...";
    ["CLEAR"] call MWF_fnc_rebelLeaderSystem;
    sleep 10;
};

if (_mode == "MIGRATE") exitWith {
    ["TRIGGER", [], "MANUAL_MIGRATE"] spawn MWF_fnc_rebelLeaderSystem;
};

if (_mode == "FOB_ATTACK") exitWith {
    ["START", _arg1, _arg2] spawn MWF_fnc_fobAttackSystem;
};

if (_mode == "FOB_DESPAWN") exitWith {
    ["DESPAWN", _arg1] call MWF_fnc_fobDespawnSystem;
};
