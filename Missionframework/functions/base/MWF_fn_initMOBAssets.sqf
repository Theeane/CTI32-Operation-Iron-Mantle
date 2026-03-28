/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_initMOBAssets
    Project: Military War Framework

    Description:
    Server-spawns the MOB asset set from active BLUFOR preset values onto
    MWF_MOB_AssetAnchor. Required assets (table, terminal, siren) always resolve
    to a valid classname via fallback. Optional assets (lamp, roof) are skipped
    when their preset entry is empty or invalid.
*/

if (!isServer) exitWith { objNull };

private _existingTerminal = missionNamespace getVariable ["MWF_Intel_Center", objNull];
if (
    missionNamespace getVariable ["MWF_MOBAssetsInitialized", false]
    && {!isNull _existingTerminal}
) exitWith { _existingTerminal };

private _assetAnchor = missionNamespace getVariable ["MWF_MOB_AssetAnchor", objNull];
if (isNull _assetAnchor && {!isNil "MWF_MOB_AssetAnchor"}) then {
    _assetAnchor = MWF_MOB_AssetAnchor;
};

private _respawnAnchor = missionNamespace getVariable ["MWF_MOB_RespawnAnchor", objNull];
if (isNull _respawnAnchor && {!isNil "MWF_MOB_RespawnAnchor"}) then {
    _respawnAnchor = MWF_MOB_RespawnAnchor;
};

if (isNull _assetAnchor && {!isNull _respawnAnchor}) then {
    _assetAnchor = _respawnAnchor;
};

if (isNull _assetAnchor && {markerColor "MWF_MOB_Marker" isNotEqualTo ""}) then {
    private _anchorPos = getMarkerPos "MWF_MOB_Marker";
    private _tempAnchor = createVehicle ["Land_HelipadEmpty_F", _anchorPos, [], 0, "CAN_COLLIDE"];
    _tempAnchor allowDamage false;
    _tempAnchor enableSimulationGlobal false;
    _assetAnchor = _tempAnchor;
};

if (isNull _assetAnchor && {markerColor "respawn_west" isNotEqualTo ""}) then {
    private _anchorPos = getMarkerPos "respawn_west";
    private _tempAnchor = createVehicle ["Land_HelipadEmpty_F", _anchorPos, [], 0, "CAN_COLLIDE"];
    _tempAnchor allowDamage false;
    _tempAnchor enableSimulationGlobal false;
    _assetAnchor = _tempAnchor;
};

if (isNull _assetAnchor) exitWith {
    diag_log "[MWF MOB] ERROR: MWF_MOB_AssetAnchor missing. MOB assets not spawned.";
    objNull
};

private _resolveRequiredClass = {
    params ["_varName", "_fallback"];
    private _cls = missionNamespace getVariable [_varName, ""];
    if !(_cls isEqualType "") then {
        _cls = "";
    };
    if (_cls isEqualTo "" || {!isClass (configFile >> "CfgVehicles" >> _cls)}) then {
        diag_log format ["[MWF MOB] WARNING: %1 empty/invalid in preset. Using fallback %2.", _varName, _fallback];
        _cls = _fallback;
    };
    _cls
};

private _resolveOptionalClass = {
    params ["_varName"];
    private _cls = missionNamespace getVariable [_varName, ""];
    if !(_cls isEqualType "") then {
        _cls = "";
    };
    if (_cls isEqualTo "" || {!isClass (configFile >> "CfgVehicles" >> _cls)}) then {
        _cls = "";
    };
    _cls
};

private _tableClass    = ["MWF_FOB_Asset_Table",    "Land_CampingTable_small_F"] call _resolveRequiredClass;
private _terminalClass = ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"] call _resolveRequiredClass;
private _sirenClass    = ["MWF_FOB_Asset_Siren",    "Land_Loudspeakers_F"] call _resolveRequiredClass;
private _lampClass     = ["MWF_FOB_Asset_Lamp"] call _resolveOptionalClass;
private _roofClass     = ["MWF_FOB_Asset_Roof"] call _resolveOptionalClass;

private _anchorPos = getPosATL _assetAnchor;
private _anchorDir = getDir _assetAnchor;
private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];

private _spawnAsset = {
    params ["_className", "_posATL", ["_dir", 0]];
    private _obj = createVehicle [_className, _posATL, [], 0, "CAN_COLLIDE"];
    _obj setDir _dir;
    _obj setPosATL _posATL;
    _obj allowDamage false;
    _obj enableSimulationGlobal false;
    _obj setVariable ["MWF_BaseType", "MOB", true];
    _obj setVariable ["MWF_BaseName", _mobName, true];
    _obj
};

private _placeOnTable = {
    params ["_tableObj", "_obj", "_xy", ["_yawOffset", 0], ["_zBias", 0.008]];
    if (isNull _tableObj || {isNull _obj}) exitWith {};

    private _bboxTable = boundingBoxReal _tableObj;
    private _bboxObj = boundingBoxReal _obj;
    private _tableTop = (_bboxTable # 1) # 2;
    private _objBottom = (_bboxObj # 0) # 2;
    private _localPos = [_xy # 0, _xy # 1, _tableTop - _objBottom + _zBias];

    _obj setDir ((getDir _tableObj) + _yawOffset);
    _obj setPosWorld (_tableObj modelToWorldWorld _localPos);
};

private _table = [_tableClass, _anchorPos, _anchorDir] call _spawnAsset;
_table setVariable ["MWF_AssetRole", "TABLE", true];

private _terminal = [_terminalClass, _anchorPos, _anchorDir] call _spawnAsset;
[_table, _terminal, [0.14, -0.10], 0] call _placeOnTable;
_terminal setVariable ["MWF_AssetRole", "TERMINAL", true];
_terminal setVariable ["MWF_isTerminal", true, true];

private _sirenPos = _assetAnchor modelToWorld [0, -3, 0];
private _siren = [_sirenClass, _sirenPos, _anchorDir] call _spawnAsset;
_siren setVariable ["MWF_AssetRole", "SIREN", true];

private _lamp = objNull;
if (_lampClass isNotEqualTo "") then {
    _lamp = [_lampClass, _anchorPos, _anchorDir] call _spawnAsset;
    [_table, _lamp, [-0.18, -0.07], 0] call _placeOnTable;
    _lamp setVariable ["MWF_AssetRole", "LAMP", true];
};

private _roof = objNull;
if (_roofClass isNotEqualTo "") then {
    private _roofPos = _assetAnchor modelToWorld [0, 0, 0];
    _roof = [_roofClass, _roofPos, _anchorDir] call _spawnAsset;
    _roof setVariable ["MWF_AssetRole", "ROOF", true];
};

missionNamespace setVariable ["MWF_MOB_Table", _table, true];
missionNamespace setVariable ["MWF_Intel_Center", _terminal, true];
missionNamespace setVariable ["MWF_Base_Light", _lamp, true];
missionNamespace setVariable ["MWF_MOB_Roof", _roof, true];
missionNamespace setVariable ["MWF_MOB_Siren", _siren, true];
missionNamespace setVariable ["MWF_MOB_AssetAnchor", _assetAnchor, true];

MWF_MOB_Table = _table;
MWF_Intel_Center = _terminal;
MWF_Base_Light = _lamp;
MWF_MOB_Roof = _roof;
MWF_MOB_Siren = _siren;

missionNamespace setVariable [
    "MWF_MOBAssetsLocked",
    [!isNull _table, !isNull _terminal, !isNull _lamp, !isNull _roof, !isNull _siren],
    true
];
missionNamespace setVariable ["MWF_MOBAssetsInitialized", true, true];

if (!isNull _terminal) then {
    diag_log format [
        "[MWF MOB] Runtime assets initialized. Table=%1 Terminal=%2 Lamp=%3 Roof=%4 Siren=%5",
        !isNull _table,
        !isNull _terminal,
        !isNull _lamp,
        !isNull _roof,
        !isNull _siren
    ];
};

_terminal
