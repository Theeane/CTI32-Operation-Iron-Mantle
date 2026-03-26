/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Stabilizes the editor-placed MOB props and nudges the laptop/lamp slightly upward so
    they sit visibly on top of the table before being locked against damage/physics.
*/

if (!isServer) exitWith { objNull };
if (missionNamespace getVariable ["MWF_MOBAssetsInitialized", false]) exitWith { missionNamespace getVariable ["MWF_MOB_Table", objNull] };

private _respawnPos = getMarkerPos "respawn_west";
private _table = missionNamespace getVariable ["MWF_MOB_Table", objNull];
private _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
private _lamp = missionNamespace getVariable ["MWF_Base_Light", objNull];

if (isNull _table && !(_respawnPos isEqualTo [0,0,0])) then {
    private _tables = nearestObjects [_respawnPos, ["Land_CampingTable_small_F"], 20, true];
    if (_tables isNotEqualTo []) then { _table = _tables # 0; };
};
if (isNull _terminal && !(_respawnPos isEqualTo [0,0,0])) then {
    private _terminals = nearestObjects [_respawnPos, ["Land_Laptop_unfolded_F"], 20, true];
    if (_terminals isNotEqualTo []) then { _terminal = _terminals # 0; };
};
if (isNull _lamp && !(_respawnPos isEqualTo [0,0,0])) then {
    private _lamps = nearestObjects [_respawnPos, ["Land_Camping_Light_F"], 20, true];
    if (_lamps isNotEqualTo []) then { _lamp = _lamps # 0; };
};

private _lockObj = {
    params ["_obj"];
    if (isNull _obj) exitWith {};
    detach _obj;
    _obj allowDamage false;
    _obj enableSimulationGlobal false;
};

[_table] call _lockObj;

if (!isNull _terminal) then {
    private _pos = getPosATL _terminal;
    _terminal setPosATL [_pos # 0, _pos # 1, (_pos # 2) + 0.035];
    [_terminal] call _lockObj;
};

if (!isNull _lamp) then {
    private _pos = getPosATL _lamp;
    _lamp setPosATL [_pos # 0, _pos # 1, (_pos # 2) + 0.03];
    [_lamp] call _lockObj;
};

if (!isNull _table) then { missionNamespace setVariable ["MWF_MOB_Table", _table, true]; };
if (!isNull _terminal) then { missionNamespace setVariable ["MWF_Intel_Center", _terminal, true]; };
if (!isNull _lamp) then { missionNamespace setVariable ["MWF_Base_Light", _lamp, true]; };

missionNamespace setVariable ["MWF_MOBAssetsInitialized", true, true];
missionNamespace setVariable ["MWF_MOBAssetsLocked", [!isNull _table, !isNull _terminal, !isNull _lamp], true];

diag_log format ["[MWF MOB] MOB props stabilized. Table=%1 Terminal=%2 Lamp=%3", !isNull _table, !isNull _terminal, !isNull _lamp];

if (!isNull _table) exitWith { _table };
if (!isNull _terminal) exitWith { _terminal };
objNull
