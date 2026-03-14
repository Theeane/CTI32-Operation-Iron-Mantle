/*
    Author: Theane / ChatGPT
    Function: fn_zoneHandler
    Project: Military War Framework

    Description:
    Handles runtime zone state updates for all active mission zones.
    This function is intended to run as the authoritative runtime layer after zone registration.
*/

if (!isServer) exitWith {};

private _activeZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
if (_activeZones isEqualTo []) exitWith {
    diag_log "[MWF Zones] fn_zoneHandler aborted. No registered zones found.";
};

missionNamespace setVariable ["MWF_ActiveZones", _activeZones, true];

while {true} do {
    {
        private _zoneRef = _x;
        private _isMarkerZone = _zoneRef isEqualType "";
        private _zoneObject = if (_isMarkerZone) then { objNull } else { _zoneRef };
        private _markerName = if (_isMarkerZone) then { _zoneRef } else { _zoneRef getVariable ["MWF_zoneMarker", ""] };

        if (_isMarkerZone && { !(_markerName in allMapMarkers) }) then {
            continue;
        };

        if (!_isMarkerZone && { isNull _zoneObject }) then {
            continue;
        };

        private _zonePos = if (_isMarkerZone) then { getMarkerPos _markerName } else { getPosWorld _zoneObject };
        private _zoneRange = if (_isMarkerZone) then { (getMarkerSize _markerName) select 0 } else { _zoneObject getVariable ["MWF_zoneRange", 300] };
        private _zoneName = if (_isMarkerZone) then { markerText _markerName } else { _zoneObject getVariable ["MWF_zoneName", markerText _markerName] };

        if (_zoneName isEqualTo "") then {
            _zoneName = if (_isMarkerZone) then { _markerName } else { "Unnamed Zone" };
        };

        private _isCaptured = if (_isMarkerZone) then {
            missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _markerName], false]
        } else {
            _zoneObject getVariable ["MWF_isCaptured", false]
        };

        private _underAttack = if (_isMarkerZone) then {
            missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], false]
        } else {
            _zoneObject getVariable ["MWF_underAttack", false]
        };

        private _playersPresent = allPlayers select {
            alive _x &&
            { (_x distance2D _zonePos) < _zoneRange }
        };

        private _enemyUnits = allUnits select {
            alive _x &&
            { side _x == east } &&
            { (_x distance2D _zonePos) < _zoneRange }
        };

        private _friendlyCount = count _playersPresent;
        private _enemyCount = count _enemyUnits;

        if (_isCaptured) then {
            if (_enemyCount > 0 && { _enemyCount > _friendlyCount }) then {
                if (!_underAttack) then {
                    if (_isMarkerZone) then {
                        missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], true, true];
                    } else {
                        _zoneObject setVariable ["MWF_underAttack", true, true];
                    };

                    if (_markerName != "" && { _markerName in allMapMarkers }) then {
                        _markerName setMarkerColor "ColorYellow";
                    };

                    [format ["%1 is under attack.", _zoneName]] remoteExec ["systemChat", 0];
                };
            } else {
                if (_underAttack && { _enemyCount == 0 }) then {
                    if (_isMarkerZone) then {
                        missionNamespace setVariable [format ["MWF_zoneState_%1_MWF_underAttack", _markerName], false, true];
                    } else {
                        _zoneObject setVariable ["MWF_underAttack", false, true];
                    };

                    if (_markerName != "" && { _markerName in allMapMarkers }) then {
                        _markerName setMarkerColor "ColorBLUFOR";
                    };

                    [format ["%1 is secure again.", _zoneName]] remoteExec ["systemChat", 0];
                };
            };
        } else {
            if (_friendlyCount > 0 && { _enemyCount == 0 }) then {
                if (_markerName != "" && { _markerName in allMapMarkers }) then {
                    _markerName setMarkerColor "ColorYellow";
                };
            };
        };
    } forEach _activeZones;

    uiSleep 10;
};
