/*
    Author: Theane / ChatGPT
    Function: fn_spawnInitialFOBAsset
    Project: Military War Framework

    Description:
    Spawns the initial deployable FOB asset at the MOB spawn pad on fresh campaigns.
    Asset type is driven by the lobby parameter MWF_Param_InitialFOBType.
*/

if (!isServer) exitWith { objNull };

if (missionNamespace getVariable ["MWF_HasCampaignSave", false]) exitWith {
    diag_log "[MWF FOB] Initial FOB asset spawn skipped because campaign save already exists.";
    objNull
};

if (!(isNil { missionNamespace getVariable "MWF_InitialFOBAssetRef" })) then {
    private _existingInitial = missionNamespace getVariable ["MWF_InitialFOBAssetRef", objNull];
    if (!isNull _existingInitial) exitWith {
        diag_log "[MWF FOB] Initial FOB asset already exists. Skipping duplicate spawn.";
        _existingInitial
    };
};

private _paramValue = missionNamespace getVariable [
    "MWF_Param_InitialFOBType",
    ["MWF_Param_InitialFOBType", 0] call BIS_fnc_getParamValue
];

private _assetClass = if (_paramValue == 1) then {
    missionNamespace getVariable ["MWF_FOB_Box", "B_Slingload_01_Cargo_F"]
} else {
    missionNamespace getVariable ["MWF_FOB_Truck", "B_Truck_01_Repair_F"]
};

if (_assetClass isEqualTo "") exitWith {
    diag_log "[MWF FOB] Initial FOB asset spawn aborted because resolved asset class was empty.";
    objNull
};

private _spawnPad = missionNamespace getVariable ["MWF_MOB_FobPad", objNull];
private _spawnPos = [];
private _spawnDir = markerDir "respawn_west";

if (!isNull _spawnPad) then {
    _spawnPos = getPosATL _spawnPad;
    _spawnDir = getDir _spawnPad;
} else {
    private _mobMarkerPos = getMarkerPos "respawn_west";
    private _fallbackPads = nearestObjects [_mobMarkerPos, ["Land_HelipadEmpty_F"], 150];

    if ((count _fallbackPads) > 0) then {
        _spawnPad = _fallbackPads select 0;
        _spawnPos = getPosATL _spawnPad;
        _spawnDir = getDir _spawnPad;
    } else {
        _spawnPos = _mobMarkerPos;
    };
};

if !(_spawnPos isEqualType [] && {count _spawnPos >= 2}) exitWith {
    diag_log "[MWF FOB] Initial FOB asset spawn aborted because no valid MOB spawn position was resolved.";
    objNull
};

private _occupiedBy = nearestObjects [_spawnPos, ["Car", "Air", "Ship", "ThingX", "ContainerSupply", "Slingload_base_F"], 8];
_occupiedBy = _occupiedBy select { !isNull _x };

if ((count _occupiedBy) > 0) exitWith {
    diag_log format ["[MWF FOB] Initial FOB asset spawn skipped because the MOB pad is occupied by %1 object(s).", count _occupiedBy];
    objNull
};

private _asset = createVehicle [_assetClass, _spawnPos, [], 0, "NONE"];
if (isNull _asset) exitWith {
    diag_log format ["[MWF FOB] Initial FOB asset spawn failed for class %1.", _assetClass];
    objNull
};

_asset setDir _spawnDir;
_asset setPosATL _spawnPos;
_asset setVariable ["MWF_IsInitialFOBAsset", true, true];
missionNamespace setVariable ["MWF_InitialFOBAssetRef", _asset, true];

[_asset] call MWF_fnc_initFOB;

diag_log format [
    "[MWF FOB] Initial FOB asset spawned: %1 (%2) at %3.",
    if (_paramValue == 1) then {"BOX"} else {"TRUCK"},
    _assetClass,
    _spawnPos
];

_asset
