/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Stabilizes the editor-placed MOB props and places the laptop/lamp on top of the
    table using fixed local offsets before locking them against damage/physics.
*/

if (!isServer) exitWith { objNull };
if (missionNamespace getVariable ["MWF_MOBAssetsInitialized", false]) exitWith { missionNamespace getVariable ["MWF_MOB_Table", objNull] };

private _mobPos = [0, 0, 0];
if (markerColor "MWF_MOB_Marker" isNotEqualTo "") then {
    _mobPos = getMarkerPos "MWF_MOB_Marker";
};
if ((_mobPos isEqualTo [0, 0, 0])) then {
    private _mobArea = missionNamespace getVariable ["MWF_MOB", objNull];
    if (!isNull _mobArea) then {
        _mobPos = getPosATL _mobArea;
    };
};
if ((_mobPos isEqualTo [0, 0, 0])) then {
    _mobPos = getMarkerPos "respawn_west";
};

private _table = missionNamespace getVariable ["MWF_MOB_Table", objNull];
private _terminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
private _lamp = missionNamespace getVariable ["MWF_Base_Light", objNull];

if (isNull _table && !(_mobPos isEqualTo [0, 0, 0])) then {
    private _tables = nearestObjects [_mobPos, ["Land_CampingTable_small_F"], 20, true];
    if (_tables isNotEqualTo []) then { _table = _tables # 0; };
};
if (isNull _terminal && !(_mobPos isEqualTo [0, 0, 0])) then {
    private _terminals = nearestObjects [_mobPos, ["Land_Laptop_unfolded_F"], 20, true];
    if (_terminals isNotEqualTo []) then { _terminal = _terminals # 0; };
};
if (isNull _lamp && !(_mobPos isEqualTo [0, 0, 0])) then {
    private _lamps = nearestObjects [_mobPos, ["Land_Camping_Light_F"], 20, true];
    if (_lamps isNotEqualTo []) then { _lamp = _lamps # 0; };
};

private _lockObj = {
    params ["_obj"];
    if (isNull _obj) exitWith {};
    detach _obj;
    _obj allowDamage false;
    _obj enableSimulationGlobal false;
};

private _placeOnTable = {
    params ["_tableObj", "_obj", "_xy", ["_yawOffset", 0]];
    if (isNull _tableObj || {isNull _obj}) exitWith {};

    private _bboxTable = boundingBoxReal _tableObj;
    private _bboxObj = boundingBoxReal _obj;
    private _tableTop = (_bboxTable # 1) # 2;
    private _objBottom = (_bboxObj # 0) # 2;
    private _localPos = [
        _xy # 0,
        _xy # 1,
        _tableTop - _objBottom + 0.008
    ];

    _obj setDir ((getDir _tableObj) + _yawOffset);
    _obj setPosWorld (_tableObj modelToWorldWorld _localPos);
};

[_table] call _lockObj;

if (!isNull _table && !isNull _terminal) then {
    [_table, _terminal, [0.14, -0.10], 0] call _placeOnTable;
};
if (!isNull _table && !isNull _lamp) then {
    [_table, _lamp, [-0.19, -0.07], 0] call _placeOnTable;
};

[_terminal] call _lockObj;
[_lamp] call _lockObj;

if (!isNull _table) then { missionNamespace setVariable ["MWF_MOB_Table", _table, true]; };
if (!isNull _terminal) then { missionNamespace setVariable ["MWF_Intel_Center", _terminal, true]; };
if (!isNull _lamp) then { missionNamespace setVariable ["MWF_Base_Light", _lamp, true]; };

missionNamespace setVariable ["MWF_MOBAssetsInitialized", true, true];
missionNamespace setVariable ["MWF_MOBAssetsLocked", [!isNull _table, !isNull _terminal, !isNull _lamp], true];

diag_log format ["[MWF MOB] MOB props stabilized. Table=%1 Terminal=%2 Lamp=%3", !isNull _table, !isNull _terminal, !isNull _lamp];

if (!isNull _table) exitWith { _table };
if (!isNull _terminal) exitWith { _terminal };
objNull
