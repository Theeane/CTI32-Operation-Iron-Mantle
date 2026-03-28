/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Spawns the MOB asset set from preset/config onto the dedicated MOB asset anchor.
    This removes the hard dependency on editor-placed tables/laptops/lamps so the
    same asset pipeline can later be reused for other eras and FOBs.
*/

if (!isServer) exitWith { objNull };

private _existingTerminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
if (missionNamespace getVariable ["MWF_MOBAssetsInitialized", false] && {!isNull _existingTerminal}) exitWith { _existingTerminal };

private _resolveNamedObject = {
    params ["_name"];
    private _obj = missionNamespace getVariable [_name, objNull];
    if (isNull _obj && {!isNil _name}) then {
        _obj = call compile _name;
    };
    _obj
};

private _assetAnchor = ["MWF_MOB_AssetAnchor"] call _resolveNamedObject;
private _respawnAnchor = ["MWF_MOB_RespawnAnchor"] call _resolveNamedObject;
private _mobArea = missionNamespace getVariable ["MWF_MOB", objNull];

private _anchorPos = [0, 0, 0];
private _anchorDir = 0;

if (!isNull _assetAnchor) then {
    _anchorPos = getPosATL _assetAnchor;
    _anchorDir = getDir _assetAnchor;
} else {
    if (markerColor "MWF_MOB_Marker" isNotEqualTo "") then {
        _anchorPos = getMarkerPos "MWF_MOB_Marker";
    } else {
        if (!isNull _mobArea) then {
            _anchorPos = getPosATL _mobArea;
            _anchorDir = getDir _mobArea;
        } else {
            if (!isNull _respawnAnchor) then {
                _anchorPos = getPosATL _respawnAnchor;
                _anchorDir = getDir _respawnAnchor;
            } else {
                _anchorPos = getMarkerPos "respawn_west";
            };
        };
    };
};

if (_anchorPos isEqualTo [0, 0, 0]) exitWith {
    diag_log "[MWF MOB] WARNING: Could not resolve a valid MOB asset anchor position.";
    objNull
};

missionNamespace setVariable ["MWF_MOB_AssetAnchor", _assetAnchor, true];
missionNamespace setVariable ["MWF_MOB_RespawnAnchor", _respawnAnchor, true];

private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
private _assetRoof = missionNamespace getVariable ["MWF_FOB_Asset_Roof", ""];
private _assetTable = missionNamespace getVariable ["MWF_FOB_Asset_Table", "Land_CampingTable_small_F"];
private _assetTerminal = missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"];
private _assetSiren = missionNamespace getVariable ["MWF_FOB_Asset_Siren", "Land_Loudspeakers_F"];
private _assetLamp = missionNamespace getVariable ["MWF_FOB_Asset_Lamp", "Land_Camping_Light_F"];

private _canSpawnClass = {
    params ["_class"];
    !(_class isEqualTo "") && {isClass (configFile >> "CfgVehicles" >> _class)}
};

private _spawnAsset = {
    params ["_class", "_offset", ["_dirOffset", 0]];

    if !([_class] call _canSpawnClass) exitWith { objNull };

    private _worldPos = if (!isNull _assetAnchor) then {
        _assetAnchor modelToWorldWorld _offset
    } else {
        [
            (_anchorPos # 0) + (_offset # 0),
            (_anchorPos # 1) + (_offset # 1),
            (_anchorPos # 2) + (_offset # 2)
        ]
    };

    private _obj = createVehicle [_class, _worldPos, [], 0, "CAN_COLLIDE"];
    _obj setDir (_anchorDir + _dirOffset);
    _obj setPosWorld _worldPos;
    _obj setVariable ["MWF_BaseType", "MOB", true];
    _obj setVariable ["MWF_BaseName", _mobName, true];
    _obj allowDamage false;
    _obj enableSimulationGlobal false;
    _obj
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

private _findNearbyAsset = {
    params ["_class", ["_radius", 12]];
    if (_class isEqualTo "") exitWith { objNull };
    private _candidates = nearestObjects [_anchorPos, [_class], _radius, true];
    if (_candidates isEqualTo []) exitWith { objNull };
    _candidates # 0
};

private _roof = if ([_assetRoof] call _canSpawnClass) then { [_assetRoof, [0, 0, 0], 0] call _spawnAsset } else { objNull };
private _table = if ([_assetTable] call _canSpawnClass) then { [_assetTable, [0, 0, 0], 0] call _spawnAsset } else { ["Land_CampingTable_small_F"] call _findNearbyAsset };
private _terminal = if ([_assetTerminal] call _canSpawnClass) then { [_assetTerminal, [0.14, -0.10, 0.78], 0] call _spawnAsset } else { ["Land_Laptop_unfolded_F"] call _findNearbyAsset };
private _lamp = if ([_assetLamp] call _canSpawnClass) then { [_assetLamp, [-0.19, -0.07, 0.78], 0] call _spawnAsset } else { ["Land_Camping_Light_F"] call _findNearbyAsset };
private _siren = if ([_assetSiren] call _canSpawnClass) then { [_assetSiren, [2.0, -1.1, 0], 180] call _spawnAsset } else { objNull };

if (!isNull _table && !isNull _terminal) then {
    [_table, _terminal, [0.14, -0.10], 0] call _placeOnTable;
};
if (!isNull _table && !isNull _lamp) then {
    [_table, _lamp, [-0.19, -0.07], 0] call _placeOnTable;
};

if (!isNull _roof) then { missionNamespace setVariable ["MWF_MOB_Roof", _roof, true]; MWF_MOB_Roof = _roof; publicVariable "MWF_MOB_Roof"; };
if (!isNull _table) then { missionNamespace setVariable ["MWF_MOB_Table", _table, true]; MWF_MOB_Table = _table; publicVariable "MWF_MOB_Table"; };
if (!isNull _terminal) then { missionNamespace setVariable ["MWF_Intel_Center", _terminal, true]; MWF_Intel_Center = _terminal; publicVariable "MWF_Intel_Center"; };
if (!isNull _lamp) then { missionNamespace setVariable ["MWF_Base_Light", _lamp, true]; MWF_Base_Light = _lamp; publicVariable "MWF_Base_Light"; };
if (!isNull _siren) then { missionNamespace setVariable ["MWF_MOB_Siren", _siren, true]; MWF_MOB_Siren = _siren; publicVariable "MWF_MOB_Siren"; };

missionNamespace setVariable ["MWF_MOBAssetsInitialized", true, true];
missionNamespace setVariable ["MWF_MOBAssetsLocked", [!isNull _roof, !isNull _table, !isNull _terminal, !isNull _lamp, !isNull _siren], true];

private _spawnSummary = format [
    "[MWF MOB] MOB assets initialized from anchor. Roof=%1 Table=%2 Terminal=%3 Lamp=%4 Siren=%5 Anchor=%6",
    !isNull _roof,
    !isNull _table,
    !isNull _terminal,
    !isNull _lamp,
    !isNull _siren,
    !isNull _assetAnchor
];
diag_log _spawnSummary;

if (!isNull _terminal) exitWith { _terminal };
if (!isNull _table) exitWith { _table };
objNull
