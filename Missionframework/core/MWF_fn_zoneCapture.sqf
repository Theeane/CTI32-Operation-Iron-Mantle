/*
    Author: Theane / ChatGPT
    Function: MWF_fn_zoneCapture
    Project: Military War Framework

    Description:
    Handles capture and loss transitions for a single registered zone object.
*/

if (!isServer) exitWith {};

params [
    ["_zone", objNull, [objNull]]
];

if (isNull _zone) exitWith {};

private _zonePos = getPosWorld _zone;
private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;
private _zoneName = _zone getVariable ["MWF_zoneName", "Unknown Zone"];
private _lossTimerDeadline = 0;
private _supportRolledThisEngagement = false;
private _supportContextKey = format ["zone_%1", _zone getVariable ["MWF_zoneID", netId _zone]];

diag_log format ["[MWF Zone Capture] Started capture loop for zone: %1 at %2.", _zoneName, _zonePos];

while { !isNull _zone } do {
    uiSleep 5;

    private _enemyUnits = allUnits select {
        alive _x &&
        { side _x == east } &&
        { (_x distance2D _zonePos) < _zoneRange } &&
        { !(_x getVariable ["MWF_isQRF", false]) }
    };

    private _friendlyUnits = allPlayers select {
        alive _x &&
        { (_x distance2D _zonePos) < _zoneRange } &&
        {
            private _eyeState = toUpper (_x getVariable ["MWF_UndercoverEyeState", if (_x getVariable ["MWF_isUndercover", false]) then {"GREEN"} else {"OFF"}]);
            private _isUndercover = _x getVariable ["MWF_isUndercover", false];
            (!_isUndercover) || {_eyeState isEqualTo "RED"}
        }
    };

    private _enemyCount = count _enemyUnits;
    private _friendlyCount = count _friendlyUnits;
    private _isCaptured = _zone getVariable ["MWF_isCaptured", false];

    private _isContested = (_enemyCount > 0 && _friendlyCount > 0);
    private _isDefensePressure = (_isCaptured && {_enemyCount > 0});
    private _supportShouldRoll = _isContested || _isDefensePressure;

    _zone setVariable ["MWF_contested", _isContested, true];

    if (_supportShouldRoll) then {
        if (!_supportRolledThisEngagement && {!isNil "MWF_fnc_civRepSupport"}) then {
            ["TRIGGER", [_zonePos, _supportContextKey, _zone]] call MWF_fnc_civRepSupport;
            _supportRolledThisEngagement = true;
        };
    } else {
        _supportRolledThisEngagement = false;
    };

    if (!_isCaptured) then {
        if (_friendlyCount > 0 && { _enemyCount == 0 }) then {
            [_zone, "player", format ["%1 is now under friendly control.", _zoneName]] call MWF_fnc_setZoneOwner;
            _lossTimerDeadline = 0;
        } else {
            if (_friendlyCount > 0 && { _enemyCount > 0 }) then {
                _zone setVariable ["MWF_underAttack", true, true];
                _zone setVariable ["MWF_capProgress", 50, true];
            } else {
                _zone setVariable ["MWF_underAttack", false, true];
                _zone setVariable ["MWF_capProgress", 0, true];
            };
        };
    } else {
        if (_enemyCount > _friendlyCount && { _enemyCount > 0 }) then {
            _zone setVariable ["MWF_underAttack", true, true];

            if (_lossTimerDeadline <= 0) then {
                _lossTimerDeadline = serverTime + 120;
                [format ["%1 is under attack.", _zoneName]] remoteExec ["systemChat", 0];
            };

            if (serverTime >= _lossTimerDeadline) then {
                [_zone, "enemy", format ["Enemy forces retook %1.", _zoneName]] call MWF_fnc_setZoneOwner;
                _lossTimerDeadline = 0;
            };
        } else {
            _zone setVariable ["MWF_underAttack", false, true];
            _lossTimerDeadline = 0;
        };
    };

    [_zone] call MWF_fnc_syncZoneMarker;
};

diag_log format ["[MWF Zone Capture] Capture loop ended for zone: %1.", _zoneName];