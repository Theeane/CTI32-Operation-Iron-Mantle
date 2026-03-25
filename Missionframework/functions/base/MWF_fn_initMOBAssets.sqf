/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Stabilizes the editor-placed MOB terminal setup.
    Re-attaches the named laptop and base lamp to the nearest MOB camping table,
    keeps them non-destructible/non-simulated, and exposes stable missionNamespace
    references for later systems.
*/

if (!isServer) exitWith { objNull };

private _respawnPos = getMarkerPos "respawn_west";
private _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
private _lamp = missionNamespace getVariable ["MWF_Base_Light", objNull];
private _table = objNull;

if (isNull _terminal && !(_respawnPos isEqualTo [0,0,0])) then {
    private _terminals = nearestObjects [
        _respawnPos,
        ["Land_Laptop_unfolded_F", "RuggedTerminal_01_communications_F", "Land_DataTerminal_01_F"],
        25,
        true
    ];
    if (_terminals isNotEqualTo []) then {
        _terminal = _terminals # 0;
    };
};

private _tableSearchOrigin = if (!isNull _terminal) then { getPosATL _terminal } else { _respawnPos };
if !(_tableSearchOrigin isEqualTo [0,0,0]) then {
    private _tables = nearestObjects [_tableSearchOrigin, ["Land_CampingTable_small_F"], 10, true];
    if (_tables isNotEqualTo []) then {
        _table = _tables # 0;
    };
};

if (isNull _lamp) then {
    private _lampSearchOrigin = if (!isNull _table) then { getPosATL _table } else { _tableSearchOrigin };
    if !(_lampSearchOrigin isEqualTo [0,0,0]) then {
        private _lamps = nearestObjects [_lampSearchOrigin, ["Land_Camping_Light_F"], 10, true];
        if (_lamps isNotEqualTo []) then {
            _lamp = _lamps # 0;
        };
    };
};

if (!isNull _table) then {
    _table allowDamage false;
    _table enableSimulationGlobal false;
    missionNamespace setVariable ["MWF_MOB_Table", _table, true];
};

if (!isNull _terminal) then {
    detach _terminal;
    _terminal allowDamage false;
    _terminal enableSimulationGlobal false;

    if (!isNull _table) then {
        _terminal attachTo [_table, [0, 0, 0.60]];
        _terminal setVectorDirAndUp [vectorDir _table, vectorUp _table];
        _terminal setVariable ["MWF_AttachedTable", _table, true];
    };

    missionNamespace setVariable ["MWF_Intel_Center", _terminal, true];
};

if (!isNull _lamp) then {
    detach _lamp;
    _lamp allowDamage false;
    _lamp enableSimulationGlobal false;

    if (!isNull _table) then {
        _lamp attachTo [_table, [-0.28, 0.05, -0.08]];
        _lamp setVectorDirAndUp [vectorDir _table, vectorUp _table];
    };

    missionNamespace setVariable ["MWF_Base_Light", _lamp, true];
};

if (!isNull _terminal) then {
    _terminal setVariable ["MWF_AttachedLamp", _lamp, true];
};

diag_log format [
    "[MWF MOB] MOB assets initialized. Terminal=%1 Table=%2 Lamp=%3",
    _terminal,
    _table,
    _lamp
];

if (!isNull _table) exitWith { _table };
if (!isNull _terminal) exitWith { _terminal };
objNull
