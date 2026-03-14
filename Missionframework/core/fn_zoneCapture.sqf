/*
    Author: Theane / ChatGPT
    Function: fn_zoneCapture
    Project: Military War Framework

    Description:
    Handles capture and re-take logic for a mission zone.
    Supports both legacy marker-based zones and logic/object-based zones.
*/

if (!isServer) exitWith {};

params [["_zoneRef", "", ["", objNull]]];

if (
    (_zoneRef isEqualType "" && { _zoneRef isEqualTo "" }) ||
    (_zoneRef isEqualType objNull && { isNull _zoneRef })
) exitWith {};

private _isMarkerZone = _zoneRef isEqualType "";
private _zoneObject = if (_isMarkerZone) then { objNull } else { _zoneRef };
private _markerName = if (_isMarkerZone) then { _zoneRef } else { _zoneRef getVariable ["MWF_zoneMarker", ""] };

if (_isMarkerZone && { !(_markerName in allMapMarkers) }) exitWith {
    diag_log format ["[MWF] fn_zoneCapture aborted. Missing marker: %1", _markerName];
};

if (!_isMarkerZone && { _markerName isEqualTo "" }) exitWith {
    diag_log "[MWF] fn_zoneCapture aborted. Zone object has no marker assigned.";
};

private _zonePos = if (_isMarkerZone) then { getMarkerPos _markerName } else { getPosWorld _zoneObject };
private _zoneRange = if (_isMarkerZone) then { (getMarkerSize _markerName) select 0 } else { _zoneObject getVariable ["MWF_zoneRange", 300] };
private _zoneDisplayName = if (_isMarkerZone) then { markerText _markerName } else { _zoneObject getVariable ["MWF_zoneName", markerText _markerName] };

if (_zoneDisplayName isEqualTo "") then {
    _zoneDisplayName = _markerName;
};

private _statePrefix = if (_isMarkerZone) then {
    format ["MWF_zoneState_%1_", _markerName]
} else {
    format ["MWF_zoneState_%1_", _zoneObject call BIS_fnc_netId]
};

private _fnc_getState = {
    params ["_key", "_default"];

    if (_isMarkerZone) then {
        missionNamespace getVariable [format ["%1%2", _statePrefix, _key], _default]
    } else {
        _zoneObject getVariable [_key, _default]
    };
};

private _fnc_setState = {
    params ["_key", "_value"];

    if (_isMarkerZone) then {
        missionNamespace setVariable [format ["%1%2", _statePrefix, _key], _value, true];
    } else {
        _zoneObject setVariable [_key, _value, true];
    };
};

private _fnc_setMarkerColor = {
    params ["_color"];
    if (_markerName != "" && { _markerName in allMapMarkers }) then {
        _markerName setMarkerColor _color;
    };
};

if ([_statePrefix + "captureLoopStarted", false] call {
    params ["_varName", "_default"];
    missionNamespace getVariable [_varName, _default]
}) exitWith {};

missionNamespace setVariable [_statePrefix + "captureLoopStarted", true, true];

if (isNil { ["MWF_isCaptured", false] call _fnc_getState }) then {
    ["MWF_isCaptured", false] call _fnc_setState;
};

if (isNil { ["MWF_underAttack", false] call _fnc_getState }) then {
    ["MWF_underAttack", false] call _fnc_setState;
};

if (isNil { ["MWF_capProgress", 0] call _fnc_getState }) then {
    ["MWF_capProgress", 0] call _fnc_setState;
};

private _initialEnemies = allUnits select {
    alive _x &&
    { side _x == east } &&
    { (_x distance2D _zonePos) < _zoneRange }
};

private _baselineCount = count _initialEnemies;
if (_baselineCount < 1) then {
    _baselineCount = 5;
};

while { true } do {
    uiSleep 5;

    private _isCaptured = ["MWF_isCaptured", false] call _fnc_getState;
    private _underAttack = ["MWF_underAttack", false] call _fnc_getState;
    private _lastCapTime = ["MWF_lastCapTime", 0] call _fnc_getState;
    private _attackTimer = ["MWF_attackTimer", 0] call _fnc_getState;

    private _currentOpfor = allUnits select {
        alive _x &&
        { side _x == east } &&
        { (_x distance2D _zonePos) < _zoneRange } &&
        { !(_x getVariable ["MWF_isQRF", false]) }
    };

    private _allEnemyUnits = allUnits select {
        alive _x &&
        { side _x == east } &&
        { (_x distance2D _zonePos) < _zoneRange }
    };

    private _playersInZone = allPlayers select {
        alive _x &&
        { (_x distance2D _zonePos) < _zoneRange }
    };

    private _bluforPresent = count _playersInZone;
    private _currentEnemyCount = count _currentOpfor;
    private _totalEnemyCount = count _allEnemyUnits;

    if (!_isCaptured && { _bluforPresent > 0 }) then {
        if (_currentEnemyCount <= (_baselineCount * 0.5) && { _currentEnemyCount > 0 }) then {
            ["ColorYellow"] call _fnc_setMarkerColor;

            if !(["MWF_contestedAnnounced", false] call _fnc_getState) then {
                ["MWF_contestedAnnounced", true] call _fnc_setState;
                [format ["%1 defense is collapsing. Sector is contested.", _zoneDisplayName]] remoteExec ["systemChat", 0];
            };
        };

        if (_currentEnemyCount == 0) then {
            ["MWF_isCaptured", true] call _fnc_setState;
            ["MWF_underAttack", false] call _fnc_setState;
            ["MWF_contestedAnnounced", false] call _fnc_setState;
            ["MWF_lastCapTime", serverTime] call _fnc_setState;
            ["MWF_attackTimer", 0] call _fnc_setState;
            ["MWF_capProgress", 100] call _fnc_setState;

            ["ColorBLUFOR"] call _fnc_setMarkerColor;

            private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
            private _intel = missionNamespace getVariable ["MWF_res_intel", 0];

            _supplies = _supplies + 100;
            _intel = _intel + 5;

            missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
            missionNamespace setVariable ["MWF_res_intel", _intel, true];
            missionNamespace setVariable ["MWF_Supplies", _supplies, true];
            missionNamespace setVariable ["MWF_Intel", _intel, true];

            [format ["%1 has been liberated. +100 Supplies, +5 Intel.", _zoneDisplayName]] remoteExec ["systemChat", 0];

            if (!isNil "MWF_fnc_saveGame") then {
                [] call MWF_fnc_saveGame;
            };
        };
    };

    if (_isCaptured) then {
        if (serverTime > (_lastCapTime + 600)) then {
            if (_totalEnemyCount > _bluforPresent && { _totalEnemyCount > 0 }) then {
                if (!_underAttack) then {
                    ["MWF_underAttack", true] call _fnc_setState;
                    ["MWF_attackTimer", serverTime + 1200] call _fnc_setState;
                    ["ColorYellow"] call _fnc_setMarkerColor;

                    [format ["Counter-attack on %1. Supply flow interrupted.", _zoneDisplayName]] remoteExec ["systemChat", 0];
                };

                if (serverTime > _attackTimer) then {
                    ["MWF_isCaptured", false] call _fnc_setState;
                    ["MWF_underAttack", false] call _fnc_setState;
                    ["MWF_contestedAnnounced", false] call _fnc_setState;
                    ["MWF_capProgress", 0] call _fnc_setState;
                    ["MWF_lastCapTime", 0] call _fnc_setState;
                    ["MWF_attackTimer", 0] call _fnc_setState;

                    ["ColorOPFOR"] call _fnc_setMarkerColor;

                    [format ["%1 has been lost to enemy forces.", _zoneDisplayName]] remoteExec ["systemChat", 0];

                    if (!isNil "MWF_fnc_saveGame") then {
                        [] call MWF_fnc_saveGame;
                    };
                };
            } else {
                if (_underAttack && { _totalEnemyCount == 0 }) then {
                    ["MWF_underAttack", false] call _fnc_setState;
                    ["MWF_attackTimer", 0] call _fnc_setState;

                    ["ColorBLUFOR"] call _fnc_setMarkerColor;

                    [format ["Attack on %1 has been repelled.", _zoneDisplayName]] remoteExec ["systemChat", 0];
                };
            };
        };
    };
};
