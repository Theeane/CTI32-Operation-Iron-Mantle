/*
    Author: Theane / ChatGPT
    Function: fn_zoneHandler
    Project: Military War Framework

    Description:
    Maintains non-persistent zone runtime state such as contested visuals and attack status.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ZoneHandlerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ZoneHandlerStarted", true, true];

while {true} do {
    private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];

    {
        private _zone = _x;

        if (!isNull _zone) then {
            private _zonePos = getPosWorld _zone;
            private _zoneRange = (_zone getVariable ["MWF_zoneRange", 300]) max 150;

            private _friendlyCount = count (allPlayers select {
                alive _x &&
                { (_x distance2D _zonePos) < _zoneRange }
            });

            private _enemyCount = count (allUnits select {
                alive _x &&
                { side _x == east } &&
                { (_x distance2D _zonePos) < _zoneRange }
            });

            _zone setVariable ["MWF_contested", (_friendlyCount > 0 && _enemyCount > 0), true];

            if (_zone getVariable ["MWF_isCaptured", false]) then {
                _zone setVariable ["MWF_underAttack", (_enemyCount > _friendlyCount && _enemyCount > 0), true];
            } else {
                _zone setVariable ["MWF_underAttack", (_enemyCount > 0 && _friendlyCount > 0), true];
            };

            [_zone] call MWF_fnc_syncZoneMarker;
        };
    } forEach _zones;

    uiSleep 10;
};
