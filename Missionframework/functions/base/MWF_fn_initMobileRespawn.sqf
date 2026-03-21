/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_initMobileRespawn
    Project: Military War Framework

    Description:
    Initializes a vehicle as a Mobile Respawn Unit (MRU).
    Registers a dynamic respawn position, exposes redeploy/map state,
    provides temporary-intel storage actions, and tears itself down cleanly
    when the vehicle is destroyed.
*/

params [["_vehicle", objNull, [objNull]]];

if (!isServer) exitWith { false };
if (isNull _vehicle) exitWith {
    diag_log "[MWF] Error: initMobileRespawn called with null vehicle.";
    false
};

private _respawnTruckClass = missionNamespace getVariable ["MWF_Respawn_Truck", ""];
if (_respawnTruckClass isNotEqualTo "" && {typeOf _vehicle isNotEqualTo _respawnTruckClass}) exitWith {
    diag_log format ["[MWF] initMobileRespawn skipped for %1. Active MRU class is %2.", typeOf _vehicle, _respawnTruckClass];
    false
};

private _currentRespawns = missionNamespace getVariable ["MWF_allMobileRespawns", []];
_currentRespawns = _currentRespawns select { !isNull _x };
_currentRespawns pushBackUnique _vehicle;
missionNamespace setVariable ["MWF_allMobileRespawns", _currentRespawns, true];

_vehicle setVariable ["MWF_isMobileRespawn", true, true];
_vehicle setVariable ["MWF_respawnAvailable", true, true];
_vehicle setVariable ["MWF_MRU_DisplayName", "Mobile Respawn Unit", true];
_vehicle setVariable ["MWF_StoredIntelValue", 0, true];

private _existingRespawnId = _vehicle getVariable ["MWF_respawnPositionId", -1];
if (_existingRespawnId isEqualType 0 && {_existingRespawnId >= 0}) then {
    [west, _existingRespawnId] call BIS_fnc_removeRespawnPosition;
};

private _respawnId = [west, _vehicle, "Mobile Respawn Unit"] call BIS_fnc_addRespawnPosition;
_vehicle setVariable ["MWF_respawnPositionId", _respawnId, true];

private _storeActionId = _vehicle addAction [
    "<t color='#FFD27A'>Store Intel</t>",
    {
        params ["_target", "_caller"];
        ["STORE", _target, _caller] remoteExecCall ["MWF_fnc_vehicleIntelTransfer", 2];
    },
    nil,
    2,
    true,
    true,
    "",
    "alive _target && (_target getVariable ['MWF_isMobileRespawn', false]) && ((player getVariable ['MWF_carriedIntelValue', 0]) > 0) && (vehicle player isEqualTo player)"
];
_vehicle setVariable ["MWF_MRU_StoreActionId", _storeActionId];

private _withdrawActionId = _vehicle addAction [
    "<t color='#99DDFF'>Get Intel</t>",
    {
        params ["_target", "_caller"];
        ["WITHDRAW", _target, _caller] remoteExecCall ["MWF_fnc_vehicleIntelTransfer", 2];
    },
    nil,
    1.9,
    true,
    true,
    "",
    "alive _target && (_target getVariable ['MWF_isMobileRespawn', false]) && ((_target getVariable ['MWF_StoredIntelValue', 0]) > 0) && (vehicle player isEqualTo player)"
];
_vehicle setVariable ["MWF_MRU_WithdrawActionId", _withdrawActionId];

private _cleanupCode = {
    params ["_veh"];
    if (!isServer || {isNull _veh}) exitWith {};

    _veh setVariable ["MWF_respawnAvailable", false, true];
    _veh setVariable ["MWF_StoredIntelValue", 0, true];

    private _respawnIdLocal = _veh getVariable ["MWF_respawnPositionId", -1];
    if (_respawnIdLocal isEqualType 0 && {_respawnIdLocal >= 0}) then {
        [west, _respawnIdLocal] call BIS_fnc_removeRespawnPosition;
        _veh setVariable ["MWF_respawnPositionId", -1, true];
    };

    {
        private _actionId = _veh getVariable [_x, -1];
        if (_actionId isEqualType 0 && {_actionId >= 0}) then {
            _veh removeAction _actionId;
            _veh setVariable [_x, -1];
        };
    } forEach ["MWF_MRU_StoreActionId", "MWF_MRU_WithdrawActionId"];

    private _allRespawns = missionNamespace getVariable ["MWF_allMobileRespawns", []];
    _allRespawns = _allRespawns select { !isNull _x && {_x != _veh} };
    missionNamespace setVariable ["MWF_allMobileRespawns", _allRespawns, true];

    if (!isNil "MWF_fnc_unregisterLoadoutZone") then {
        [_veh] call MWF_fnc_unregisterLoadoutZone;
    };

    if (!isNil "MWF_fnc_refreshFOBMarkers") then {
        [] call MWF_fnc_refreshFOBMarkers;
    };
};

_vehicle addEventHandler ["Killed", {
    params ["_veh"];
    [_veh] call (_thisEventHandlerArgs select 0);
}, [_cleanupCode]];

_vehicle addEventHandler ["Deleted", {
    params ["_veh"];
    [_veh] call (_thisEventHandlerArgs select 0);
}, [_cleanupCode]];

if (!isNil "MWF_fnc_refreshFOBMarkers") then {
    [] call MWF_fnc_refreshFOBMarkers;
};

[_vehicle, 25, "MRU", objNull, true] call MWF_fnc_registerLoadoutZone;

missionNamespace setVariable ["MWF_LastMobileRespawn", _vehicle, true];

diag_log format ["[MWF] System: Mobile Respawn initialized on %1", typeOf _vehicle];
true
