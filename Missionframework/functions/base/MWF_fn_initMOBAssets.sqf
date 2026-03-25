/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Stabilizes the editor-placed MOB props without reattaching them.
    Uses the named editor objects when available, falls back to a short search around the
    respawn marker, and then locks the table, laptop, and lamp in place so they cannot be
    damaged or shoved around by physics.
*/

if (!isServer) exitWith { objNull };

private _respawnPos = getMarkerPos "respawn_west";
private _table = missionNamespace getVariable ["MWF_MOB_Table", objNull];
private _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
private _lamp = missionNamespace getVariable ["MWF_Base_Light", objNull];

if (isNull _table && !(_respawnPos isEqualTo [0,0,0])) then {
    private _tables = nearestObjects [_respawnPos, ["Land_CampingTable_small_F"], 20, true];
    if (_tables isNotEqualTo []) then {
        _table = _tables # 0;
    };
};

if (isNull _terminal && !(_respawnPos isEqualTo [0,0,0])) then {
    private _terminals = nearestObjects [
        _respawnPos,
        ["Land_Laptop_unfolded_F", "RuggedTerminal_01_communications_F", "Land_DataTerminal_01_F"],
        20,
        true
    ];
    if (_terminals isNotEqualTo []) then {
        _terminal = _terminals # 0;
    };
};

if (isNull _lamp && !(_respawnPos isEqualTo [0,0,0])) then {
    private _lamps = nearestObjects [_respawnPos, ["Land_Camping_Light_F"], 20, true];
    if (_lamps isNotEqualTo []) then {
        _lamp = _lamps # 0;
    };
};

{
    if (!isNull _x) then {
        detach _x;
        _x allowDamage false;
        _x enableSimulationGlobal false;
    };
} forEach [_table, _terminal, _lamp];

if (!isNull _table) then {
    missionNamespace setVariable ["MWF_MOB_Table", _table, true];
};
if (!isNull _terminal) then {
    missionNamespace setVariable ["MWF_Intel_Center", _terminal, true];
};
if (!isNull _lamp) then {
    missionNamespace setVariable ["MWF_Base_Light", _lamp, true];
};

missionNamespace setVariable [
    "MWF_MOBAssetsLocked",
    [!isNull _table, !isNull _terminal, !isNull _lamp],
    true
];

diag_log format [
    "[MWF MOB] MOB props locked. Table=%1 Terminal=%2 Lamp=%3",
    !isNull _table,
    !isNull _terminal,
    !isNull _lamp
];

if (!isNull _table) exitWith { _table };
if (!isNull _terminal) exitWith { _terminal };
objNull
