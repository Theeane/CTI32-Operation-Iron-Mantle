/*
    Author: Theane / ChatGPT
    Function: fn_zoneHandler
    Project: Military War Framework

    Description:
    Maintains non-persistent zone runtime state such as contested visuals and attack status.
    Includes a lightweight integration hook to mark world/threat state dirty when
    runtime zone pressure meaningfully changes.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ZoneHandlerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ZoneHandlerStarted", true, true];

while {true} do {
    private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
    private _worldNeedsRefresh = false;

    {
        private _zone = _x;

        if (!isNull _zone) then {
            private _zonePos = getPosWorld _zone;
            private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;

            private _friendlyCount = count (allPlayers select {
                alive _x &&
                {(_x distance2D _zonePos) < _zoneRange}
            });

            private _enemyCount = count (allUnits select {
                alive _x &&
                {side _x == east} &&
                {(_x distance2D _zonePos) < _zoneRange} &&
                {!(_x getVariable ["MWF_isQRF", false])}
            });

            private _previousContested = _zone getVariable ["MWF_contested", false];
            private _previousUnderAttack = _zone getVariable ["MWF_underAttack", false];

            private _newContested = (_friendlyCount > 0 && _enemyCount > 0);
            private _newUnderAttack = if (_zone getVariable ["MWF_isCaptured", false]) then {
                (_enemyCount > _friendlyCount && _enemyCount > 0)
            } else {
                (_enemyCount > 0 && _friendlyCount > 0)
            };

            if (_previousContested != _newContested) then {
                _zone setVariable ["MWF_contested", _newContested, true];
                _worldNeedsRefresh = true;
            };

            if (_previousUnderAttack != _newUnderAttack) then {
                _zone setVariable ["MWF_underAttack", _newUnderAttack, true];
                _worldNeedsRefresh = true;
            };

            [_zone] call MWF_fnc_syncZoneMarker;
        };
    } forEach _zones;

    if (_worldNeedsRefresh) then {
        if (!isNil "MWF_fnc_markWorldDirty") then {
            ["zone_runtime"] call MWF_fnc_markWorldDirty;
        } else {
            if (!isNil "MWF_fnc_recalculateWorldState") then {
                [] call MWF_fnc_recalculateWorldState;
            };
        };
    };

    uiSleep 10;
};
